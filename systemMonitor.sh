#!/bin/bash

# Thresholds (adjust as needed)
CPU_THRESHOLD=90
MEMORY_THRESHOLD=90
DISK_THRESHOLD=90

# Function to check CPU usage
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if [ $(echo "$cpu_usage >= $CPU_THRESHOLD" | bc) -eq 1 ]; then
        echo "CPU usage is high! Current usage: $cpu_usage%"
    fi
}

# Function to check memory usage
check_memory() {
    local memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100}')
    if [ $(echo "$memory_usage >= $MEMORY_THRESHOLD" | bc) -eq 1 ]; then
        echo "Memory usage is high! Current usage: $memory_usage%"
    fi
}

# Function to check disk usage
check_disk() {
    local disk_usage=$(df -h | awk '$NF=="/"{printf "%d", $5}' | sed 's/%//')
    if [ $disk_usage -ge $DISK_THRESHOLD ]; then
        echo "Disk usage is high! Current usage: $disk_usage%"
    fi
}

# Main function
main() {
    echo "System Monitoring Script"
    echo "------------------------"
    while true; do
        echo "Timestamp: $(date)"
        check_cpu
        check_memory
        check_disk
        echo "----------------------------------------"
        sleep 300  # Adjust sleep time as needed (300 seconds = 5 minutes)
    done
}

# Run main function
main