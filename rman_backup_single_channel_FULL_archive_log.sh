#!/bin/bash

# Define the backup directory with a date and time suffix for versioning
BACKUP_DIR="/mnt/oracle"
DATE_SUFFIX=$(date +%Y-%m-%d_%H-%M-%S)
DEST_DIR="$BACKUP_DIR/$DATE_SUFFIX"

# Define log file with timestamp
LOG_FILE="$DEST_DIR/rman_backup_${DATE_SUFFIX}.log"

# Ensure the backup directory exists
if [ ! -d "$DEST_DIR" ]; then
  echo "Creating backup directory: $DEST_DIR"
  mkdir -p "$DEST_DIR"
fi

# Redirect RMAN output and errors to the log file
{
  # RMAN commands using heredoc
  rman target / <<EOF
    run {
      allocate channel ch1 type disk format '$DEST_DIR/%U';
      backup database include current controlfile;
      backup archivelog all delete input;
      release channel ch1;
    }
EOF
} &> "$LOG_FILE"

# Check the return code of the RMAN commands
if [ $? -eq 0 ]; then
  echo "RMAN backup completed successfully. Log: $LOG_FILE"
else
  echo "RMAN backup failed. See log for details: $LOG_FILE"
fi
