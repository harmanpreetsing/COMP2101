#!/bin/bash

# Function to generate CPU report
function cpureport {
    echo "CPU Report"
    echo "CPU Manufacturer: $(lscpu | grep "Vendor ID" | awk -F':' '{print $2}' | sed 's/^[ \t]*//')"
    echo "CPU Model: $(lscpu | grep | awk -F':' '{print $2}' | sed 's/^[ \t]*//')"
    echo "CPU Architecture: $(lscpu | grep | awk -F':' '{print $2}' | sed 's/^[ \t]*//')"
    echo "CPU Core Count: $(lscpu | grep | awk -F':' '{print $2}' | sed 's/^[ \t]*//')"
    echo "CPU Maximum Speed: $(lscpu | grep | awk -F':' '{print $2}' | sed 's/^[ \t]*//') MHz"
    echo "Cache Sizes:"
    lscpu | grep "L1d\|L1i\|L2\|L3" | awk -F':' '{print $1 ": " $2}' | sed 's/^[ \t]*//'
}
#Function for computer report
function computerreport {
    echo "Computer Report"
    echo "Computer Manufacturer: $(dmidecode -s system-manufacturer)"
    echo "Computer Description/Model: $(dmidecode -s system-product-name)"
    echo "Computer Serial Number: $(dmidecode -s system-serial-number)"
    echo
}

#Function for OS report
function osreport {
    echo "OS Report"
    echo "Linux Distro: $(lsb_release -ds)"
    echo "Distro Version: $(lsb_release -rs)"
    echo
}
# Function for video report
function videoreport {
    echo "Video Report"
    echo "Video Card/Chipset Manufacturer: $(lspci | grep -i | awk -F ':' '{print $3}' | sed 's/^[ \t]*//')"
    echo "Video Card/Chipset Description/Model: $(lspci | grep -i | awk -F ':' '{print $4}' | sed 's/^[ \t]*//')"
    echo
}
# Function for disk report
function diskreport {
    echo "Disk Report"
    echo "Installed Disk Drives:"
    echo "Manufacturer | Model | Size | Partition | Mount Point | Filesystem Size | Filesystem Free Space"
    lsblk -bo NAME,MODEL,SIZE,TYPE,MOUNTPOINT,FSTYPE,FSSIZE,FSUSED | awk -F '|' '/disk/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); printf "%-12s |", $2} NR%7==0 {print ""}'
    echo
}

# Function to generate network report
function networkreport {
    echo "Network Report"
    echo "Installed Network Interfaces:"
    echo "Manufacturer | Model/Description | Link State | Current Speed | IP Addresses | Bridge Master | DNS Servers | Search Domains"
    ip -o link show | awk -F ': ' '/^[0-9]+:/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); printf "%-12s |", $2} NR%2==0 {print ""}'
    echo
}

# Function to display error message
function errormessage {
    local error_message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
   
    echo "Error: $error_message" >&2
    echo "$timestamp: $error_message" >> /var/log/systeminfo.log
}

