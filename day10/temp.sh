#!/bin/bash

THRESHOLD_CPU=80
THRESHOLD_MEM=80

get_system_metrics() {
    echo -e "\n CPU Usage: "
    echo      "------------"
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/')
    MEMORY_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')
    DISK_SPACE=$(df -h / | awk '/\//{print $(NF-1)}')

    echo "CPU_USAGE=$CPU_USAGE"
    echo "MEMORY_USAGE=$MEMORY_USAGE"
    echo "DISK_SPACE=$DISK_SPACE"

    echo -e "\n Network Stats: "
    echo      "----------------"
    NETWORK_STATS=$(netstat -i)
    echo "$NETWORK_STATS"

    echo -e "\n Top Processes: "
    echo      "----------------"
    TOP_PROCESSES=$(top -bn 1 | head -n 10)
    echo "$TOP_PROCESSES"
}

get_log_analysis() {
    echo -e "\n Error Logs: "
    echo      "-------------"
    ERROR_LOGS=$(grep -iE "error|critical" /var/log/syslog | tail -n 20)
    echo "$ERROR_LOGS"

    echo -e "\n Recent Logs: "
    echo      "--------------"
    RECENT_LOGS=$(tail -n 20 /var/log/syslog)
    echo "$RECENT_LOGS"
}

perform_health_checks() {
    echo -e "\n Service Status: "
    echo      "-----------------"
    SERVICE_STATUS_APACHE=$(systemctl is-active apache2)
    SERVICE_STATUS_MYSQL=$(systemctl is-active mysql)

    echo "SERVICE_STATUS_APACHE=$SERVICE_STATUS_APACHE"
    echo "SERVICE_STATUS_MYSQL=$SERVICE_STATUS_MYSQL"

    echo -e "\n Connectivity: "
    echo      "---------------"
    if ping -c 1 google.com >/dev/null 2>&1; then
        CONNECTIVITY_STATUS="Connected"
    else
        CONNECTIVITY_STATUS="Disconnected"
    fi
    echo "Connectivity Status: $CONNECTIVITY_STATUS"
}

# Check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/')
if (( $(echo "$CPU_USAGE >= $THRESHOLD_CPU" | bc -l) )); then
    echo "High CPU usage detected: $CPU_USAGE%"
fi

# Check Memory usage
MEMORY_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')
if (( $(echo "$MEMORY_USAGE >= $THRESHOLD_MEM" | bc -l) )); then
    echo "High memory usage detected: $MEMORY_USAGE%"
fi

# Create report file
REPORT_FILE="/tmp/system_report_$(date +'%Y%m%d_%H%M%S').txt"
echo "System Report $(date)" >> $REPORT_FILE
get_system_metrics >> $REPORT_FILE
get_log_analysis >> $REPORT_FILE
perform_health_checks >> $REPORT_FILE

# Menu for user selection
echo "Select an option:
1. Check system metrics
2. View logs
3. Check service status
4. Exit"

read -r choice

case $choice in
    1) get_system_metrics ;;
    2) get_log_analysis ;;
    3) perform_health_checks ;;
    4) exit ;;
    *) echo "Invalid option" ;;
esac
