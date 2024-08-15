#!/bin/bash

LOG_DIR="logs"
ARCHIVE_DIR="logs/archive"
DAYS_TO_KEEP=30

# Error handling function
handle_error() {
  echo "Error on line $1"
  exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Rotate and compress logs
rotate_logs() {
  for log_file in "$LOG_DIR"/*.log; do
    if [[ -f "$log_file" ]]; then
      gzip "$log_file"
      mv "$log_file.gz" "$ARCHIVE_DIR"
    fi
  done
}

# Delete old logs
delete_old_logs() {
  find "$ARCHIVE_DIR" -type f -name "*.gz" -mtime +$DAYS_TO_KEEP -delete
}

# Main function
main() {
  rotate_logs
  delete_old_logs
}
