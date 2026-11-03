#!/bin/bash

PIDS=()

cleanup() {
	for PID in "${PIDS[@]}"
	do
		kill "$PID" 2>/dev/null
	done
	wait
}

spawn_apps() {
	local NIC_IP
	local APP

	NIC_IP=$(ifconfig ens192 | awk '$1 == "inet" {print $2; exit}')

	if [[ -z "$NIC_IP" ||  "$NIC_IP" == 127.* ]]
	then
		echo "Could not find a useable IPv4 address on ens192" >&2
		return 1
	fi

	for APP in APM1 APM2 APM3 APM4 APM5 APM6
	do
		if [[ ! -f "./$APP" || ! -x  "./$APP" ]]
		then
			echo "Missing or non-executable file: ./$APP" >&2
			return 1
		fi

		"./$APP" "$NIC_IP" &
		PIDS+=("$!")
		echo "Started $APP with PID ${PIDS[-1]}"
	done
}

collect_process_metrics() {
	local PROCESSES=("APM1" "APM2" "APM3" "APM4" "APM5" "APM6")

	while true
	do
		for PROC in "${PROCESSES[@]}"
		do
			OUTPUT_FILE="${PROC}_metrics.csv"

			CPU=$( ps -C "$PROC" -o %cpu --no-headers | awk '{ sum+=$1 } END { print sum+0 }' )
			MEM=$( ps -C "$PROC" -o %mem --no-headers | awk '{ sum+=$1 } END { print sum+0 }' )

			echo "$SECONDS,$CPU,$MEM" >> "$OUTPUT_FILE"
		done
		sleep 5
	done
}

collect_system_metrics() {
	local OUTPUT_FILE="system_metrics.csv"
	local NETWORK RX TX DISK DISK_CAPACITY

	echo "Time,RX Data Rate,TX Data Rate,Disk Writes,Disk Capacity" > "$OUTPUT_FILE"

	while true
	do
		DISK=$(iostat -d  -y sda 1 1 | awk '$1 == "sda" {print $4}')
		NETWORK=$(ifstat -t 1 ens192 | awk '$1 == "ens192" {print $7 "," $9}')
		RX=$(echo "$NETWORK" | cut -d ',' -f 1)
		TX=$(echo "$NETWORK" | cut -d ',' -f 2)
		DISK_CAPACITY=$(df -m / | awk 'NR == 2 {print $4}')

		echo "$SECONDS,$RX,$TX,$DISK,$DISK_CAPACITY" >> "$OUTPUT_FILE"
		sleep 5
	done
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

spawn_apps || exit 1

collect_process_metrics &
PIDS+=("$!")

collect_system_metrics & 
PIDS+=("$!")

wait
