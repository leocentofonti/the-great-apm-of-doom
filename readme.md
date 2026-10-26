# NSSA-220 Project 1: Application Performance Monitoring (APM)

## Overview

This project involves building an **Application Performance Monitoring (APM)** tool in Bash to monitor the performance of six pre-compiled C applications running on a Linux virtual machine. 

The APM tool is designed to spawn specified application processes, regularly gather process-level and system-level performance metrics, handle process termination gracefully via signal traps, and output clean numeric CSV data for subsequent statistical analysis and reporting.

---

## Project Objectives

* **Process Management:** Programmatically launch, track, and terminate child processes and associated applications within Bash.
* **Performance Metric Harvesting:** Monitor CPU utilization, memory utilization, network bandwidth rates, disk access rates, and available disk capacity using core Linux utilities (`ps`, `ifstat`, `iostat`, `df`).
* **Data Structuring:** Output standardized CSV files suitable for importing into spreadsheet applications (e.g., Excel) for trend plotting and analytical evaluation.
* **System Engineering Skills:** Gain practical experience with system administration, performance auditing, resource bottleneck identification, and script automation.

---

## Virtual Machine & Environment Specifications

When generating the official 15-minute run data Rocky Linux on rles must be used.

### Prerequisites & Dependency Installation

Ensure system packages are up to date and install the `sysstat` package (which provides `iostat`):

```bash
sudo dnf install -y sysstat
```

---

## APM Tool Requirements & Specifications

### 1. Functional Requirements

1. **Sampling Frequency:** Collect process and system metrics every $5\text{ seconds}$.
2. **Process Metrics:** 
   * Monitor percentage CPU utilization (`%CPU`) and percentage memory utilization (`%MEM`) per target process using `ps`.
3. **System Metrics:**
   * **Network Bandwidth:** Measure Receive ($\text{RX}$) and Transmit ($\text{TX}$) data rates in $\text{kB/s}$ over a $1\text{-second}$ sampling window on the primary network interface (`ens???`) using `ifstat`.
   * **Disk Access Rates:** Measure disk write speed in $\text{kB/s}$ on the primary block device (`sda`) using `iostat`.
   * **Disk Capacity:** Measure available disk space in Megabytes ($\text{MB}$) on the root mount (`/` or `/dev/mapper/rl-root`) using `df`.
4. **Execution Window:** The script must run continuously for **15 minutes** ($900\text{ seconds}$) until manually interrupted/terminated by the user (e.g., via `Ctrl+C`). Do **not** program an auto-exit timer into the script.

### 2. Mandatory Architectural Structure

The Bash script must include at least the following four functions:

1. **`spawn_apps` (or similar):** Spawns the $6$ pre-compiled C applications and any required background monitoring helper processes.
2. **`collect_proc_metrics`:** Iterates through active target processes, queries `ps`, and appends formatted metrics to process-specific CSV files.
3. **`collect_sys_metrics`:** Queries `ifstat`, `iostat`, and `df`, parses numeric values, and appends formatted metrics to `system_metrics.csv`.
4. **`cleanup` (Exit Trap Function):** Intercepts termination signals (e.g., `SIGINT`, `SIGTERM`) and reliably kills all child applications and spawned background processes to prevent dangling processes.

---

## Output CSV Formats

> **CRITICAL:** Output files must contain **numeric values only** (no unit suffixes such as `kB`, `%`, or `M`) to allow seamless CSV importing and Excel charting.

### Process-Level Output Files (`<proc_name>_metrics.csv`)
A dedicated CSV file must be created for each of the $6$ monitored applications.

* **Filename Pattern:** `<proc_name>_metrics.csv`
* **Format:**
  ```csv
  <seconds_since_start>,<%CPU>,<%memory>
  ```
* **Example:**
  ```csv
  0,0.0,0.1
  5,12.5,1.2
  10,25.0,1.2
  ```

### System-Level Output File (`system_metrics.csv`)
All system-wide metrics are written to a single consolidated file.

* **Filename:** `system_metrics.csv`
* **Format:**
  ```csv
  <seconds_since_start>,<RX_rate_kBps>,<TX_rate_kBps>,<disk_writes_kBps>,<avail_disk_MB>
  ```
* **Example:**
  ```csv
  0,1.2,0.5,0.0,32400
  5,15.4,8.2,120.5,32398
  10,14.1,7.9,84.0,32395
  ```

---

## Targeted Command Line Reference

| Metric Category | Tool | Sample Command Concept | Extracted Data |
| :--- | :--- | :--- | :--- |
| **Process CPU & Memory** | `ps` | `ps -p <PID> -o %cpu,%mem` | `%CPU`, `%MEM` |
| **Network Bandwidth** | `ifstat` | `ifstat -i ens33 1 1` | $\text{RX kB/s}$, $\text{TX kB/s}$ |
| **Disk Writes** | `iostat` | `iostat -d sda` | Disk write rate ($\text{kB/s}$) |
| **Available Disk Space** | `df` | `df -m /` | Available space ($\text{MB}$) |

---

## Execution Instructions

1. **Identify the System IP:**
   Obtain the actual assigned IP address (non-loopback, non-`127.0.0.1`) using `ifconfig` or `ip addr`.
   
2. **Configure Script Parameters:**
   Update the hardcoded IP address variable inside the APM script if switching test environments.

3. **Make Executable and Run:**
   ```bash
   chmod +x apm.sh
   ./apm.sh
   ```

4. **15-Minute Data Collection:**
   Allow the script to run continuously for $15\text{ minutes}$.

5. **Stop Execution:**
   Press `Ctrl+C` in the terminal. The `cleanup` exit trap will automatically terminate all spawned C binaries and background utilities.

---

## Project Deliverables & Submission Checklist

Submit a single `.zip` file to MyCourses containing:

* [ ] **APM Bash Script:** Complete, commented Bash script adhering to structure and signal trap guidelines.
* [ ] **Process Metric Output Files:** $6$ CSV files named `<proc_name>_metrics.csv`.
* [ ] **System Metric Output File:** $1$ CSV file named `system_metrics.csv`.
* [ ] **Written Report:** Completed project report formatted according to the course template, featuring Excel plots for CPU, memory, network, and disk metrics alongside analysis and observations.

---
