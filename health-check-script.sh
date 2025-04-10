#!/bin/bash

#File for log
LOG_FILE="/tmp/health_report_$(date +%F).log"

#Print stdout and stderr to a log file
exec > "$LOG_FILE" 2>&1

#Print of the current date at and time
echo "Script started at: $(date)"

#Print kernel version
uname -a

#Print OS version
cat /etc/os-release

#Print time since system start
uptime

#Print current load on the CPU
cpu_load_top=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
echo "CPU Load (top): $cpu_load_top%"

#Print average load on the CPU
cpu_load_mpstat=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF}')
echo "CPU Load (mpstat): $cpu_load_mpstat%"

#Print usual average load upon system from /proc/loadavg
loadavg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
echo "Load Average: $loadavg"

#Print free memory
free_memory=$(free -m | awk 'NR==2{printf "Free memory: %sMB\n", $4}')
echo "$free_memory"

#Obtain entire disk usage of information, without some temporary filesystems.
DISK_USAGE=$(df -h --exclude-type=tmpfs --exclude-type=devtmpfs)
echo "$DISK_USAGE"

#Function to check inode usage
check_inodes() {
    df -i | tail -n +2 | while read -r fs total used free pct mount; do
        clean_pct=${pct%\%}

        echo -e "Filesystem: $fs\nTotal inodes: $total\nUsed inodes: $used\nFree inodes: $free\nUsed percentage: $pct\nMounted on: $mount\n"

        if [[ "$clean_pct" =~ ^[0-9]+$ ]]; then
            (( clean_pct >= 90 )) && echo "Warning: Inode usage on $mount is above 90%!"
        else
            echo "Skipping: Unable to determine inode percentage for $mount"
        fi
    done
}

check_inodes

#Top ten processes via CPU consumption
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11

#Of top ten processes for memory usage shown
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11

#Check status of SSH
systemctl status ssh

#Print listing of each of the active services
systemctl list-units --type=service --state=active

# Print all IP addresses
check_ips() {
    echo "Checking IP addresses..."
    ip -o -4 addr show | awk '{print $2, $4}'
    echo "IPv6 Addresses:"
    ip -o -6 addr show | awk '{print $2, $4}'
}

check_ips

# Check connections
check_connection() {
    echo "Checking internet connectivity..."

    # Check using ping
    if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
        echo "Ping to 8.8.8.8 successful!"
    else
        echo "Warning: Ping to 8.8.8.8 failed!"
    fi

    # Check using curl
    if curl -s --max-time 5 https://www.google.com > /dev/null; then
        echo "Connection to Google successful!"
    else
        echo "Warning: Unable to connect to Google!"
    fi
}

check_connection

# Check open ports
echo "Checking open ports..."
ss -tuln

#Print from last ten error messages
echo "Print last 10 error messages:"
journalctl -p 3 -n 10

#Print errors of syslog
echo "Print errors from syslog:"
grep -i error /var/log/syslog

#Checking mount points
echo "Checking mount points:"
mount | column -t
cat /etc/fstab
