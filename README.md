# Health-check-report

This is but a simple Bash script for collecting key system health information, then displaying the data in but a readable format. It is intended of quick diagnostics and monitoring on Linux systems.
## Purpose
This script was created a bit as part of my learning. This was a little bit for practice in Linux system administration and infrastructure support.
## Environment
This script was developed as well as tested on an Ubuntu-based EC2 instance deployed in AWS.
## What it checks
- ✅ Date and system run-time
- ✅ OS version in addition to kernel.
- ✅ A CPU load plus average (from `top` and `mpstat`).
- ✅ Some disk usage per each mount point (`df -h`)
- ✅ Inode usage on filesystem (`df -i`)
- ✅ Highest memory consuming processes exist. Highest CPU consuming processes exist, too.
- ✅ Status of several system services (`systemctl`)
- ✅ Active network interfaces, and also IP addresses
- ✅ Internet connection (ping and HTTP request)
- ✅ Ports open (via the `ss` tool)
- ✅ Last 10 error-level messages of the journal
- ✅ Errors from system logs (e.g., from `syslog`)
- ✅ Mount points and some file system types (`mount` and `fstab`)
## How to use
Make the script executable: chmod +x system-health-check.sh 

Run the script: ./system-health-check.sh or bash system-health-check.sh

  
