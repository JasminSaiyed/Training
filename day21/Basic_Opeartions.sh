#!/bin/bash

LOG_FILE="logs/system_log_$(date +'%Y%m%d_%H%M%S').log"

# Check disk usage
echo "-------------------------------------------------------------------------------" >> $LOG_FILE
echo "Check disk usage" >> $LOG_FILE
echo "-------------------------------------------------------------------------------" >> $LOG_FILE
df -h >> $LOG_FILE

if [ $? -ne 0 ]; then
    echo "Error checking disk usage" >> $LOG_FILE
    exit 1
fi

# Check memory usage
echo "-------------------------------------------------------------------------------" >> $LOG_FILE
echo "Check memory usage" >> $LOG_FILE
echo "-------------------------------------------------------------------------------" >> $LOG_FILE
free -h >> $LOG_FILE

if [ $? -ne 0 ]; then
    echo "Error checking memory usage" >> $LOG_FILE
    exit 1
fi

# Check CPU load
echo "-------------------------------------------------------------------------------" >> $LOG_FILE
echo "Check CPU load" >> $LOG_FILE
echo "-------------------------------------------------------------------------------" >> $LOG_FILE
top -bn1 | grep "Cpu(s)" >> $LOG_FILE

if [ $? -ne 0 ]; then
    echo "Error checking CPU load" >> $LOG_FILE
    exit 1
fi
