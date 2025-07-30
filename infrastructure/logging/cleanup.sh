#!/bin/sh

# DICE Log Cleanup Script
# Automatically cleans up old log files to prevent disk space issues
# Used by the log-cleaner service in the ELK stack

set -e

# Configuration
LOG_DIR="/var/log/dice"
RETENTION_DAYS=7
MAX_LOG_SIZE="100M"

echo "🧹 DICE Log Cleanup Service - $(date)"
echo "📁 Log Directory: $LOG_DIR"
echo "⏰ Retention: $RETENTION_DAYS days"
echo "📏 Max Size: $MAX_LOG_SIZE"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to clean up old log files
cleanup_old_files() {
    echo "🗑️  Removing log files older than $RETENTION_DAYS days..."
    
    # Remove old log files
    find "$LOG_DIR" -name "*.log" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.log.*" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
    
    echo "✅ Old log files cleanup completed"
}

# Function to compress large log files
compress_large_files() {
    echo "📦 Compressing large log files..."
    
    # Find and compress log files larger than max size
    find "$LOG_DIR" -name "*.log" -type f -size +$MAX_LOG_SIZE -exec gzip {} \; 2>/dev/null || true
    
    echo "✅ Large files compression completed"
}

# Function to clean up empty directories
cleanup_empty_dirs() {
    echo "📂 Removing empty directories..."
    
    find "$LOG_DIR" -type d -empty -delete 2>/dev/null || true
    
    echo "✅ Empty directories cleanup completed"
}

# Function to show disk usage
show_disk_usage() {
    echo "💾 Current disk usage:"
    du -sh "$LOG_DIR" 2>/dev/null || echo "Cannot determine disk usage"
    
    # Show number of files
    file_count=$(find "$LOG_DIR" -type f | wc -l)
    echo "📄 Total files: $file_count"
}

# Main cleanup process
echo "🚀 Starting log cleanup process..."

# Show initial state
show_disk_usage

# Perform cleanup operations
cleanup_old_files
compress_large_files  
cleanup_empty_dirs

# Show final state
echo "📊 Final state:"
show_disk_usage

echo "✅ Log cleanup completed successfully at $(date)" 