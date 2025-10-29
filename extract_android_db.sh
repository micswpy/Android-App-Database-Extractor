#!/bin/bash

################################################################################
# Android App Database Extractor
# 
# Description: Extracts SQLite databases from Android apps via ADB backup
# Author: Your Name
# Date: 2025-10-30
# Usage: ./extract_android_db.sh <package_name>
# Example: ./extract_android_db.sh kr.cybermedice.tonguetrainer
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() { echo -e "${BLUE}ℹ ${NC}$1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Print header
print_header() {
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║       Android App Database Extractor v1.0             ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
}

# Check if package name provided
if [ -z "$1" ]; then
    print_header
    print_error "No package name provided!"
    echo ""
    echo "Usage: $0 <package_name>"
    echo ""
    echo "Example:"
    echo "  $0 kr.cybermedice.tonguetrainer"
    echo ""
    echo "To find your app's package name:"
    echo "  adb shell pm list packages | grep <app_name>"
    echo ""
    exit 1
fi

PACKAGE_NAME="$1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="output/${PACKAGE_NAME}_${TIMESTAMP}"
BACKUP_FILE="${OUTPUT_DIR}/backup.ab"
TAR_FILE="${OUTPUT_DIR}/backup.tar"
EXTRACTED_DIR="${OUTPUT_DIR}/extracted"

print_header

################################################################################
# Step 1: Pre-flight Checks
################################################################################

print_info "Running pre-flight checks..."

# Check if adb is installed
if ! command -v adb &> /dev/null; then
    print_error "ADB not found! Please install Android Platform Tools."
    exit 1
fi
print_success "ADB found: $(adb version | head -n1)"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 not found! Please install Python 3."
    exit 1
fi
print_success "Python 3 found: $(python3 --version)"

# Check if required Python libraries are installed
if ! python3 -c "import pandas" 2>/dev/null; then
    print_error "pandas library not found! Install with: pip3 install pandas openpyxl"
    exit 1
fi
print_success "Required Python libraries found"

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    print_error "No Android device connected!"
    echo ""
    echo "Please:"
    echo "  1. Connect your device via USB"
    echo "  2. Enable USB debugging in Developer Options"
    echo "  3. Authorize your computer on the device"
    echo ""
    exit 1
fi
print_success "Android device connected: $(adb devices | grep device$ | awk '{print $1}')"

# Check if app is installed
if ! adb shell pm list packages | grep -q "^package:${PACKAGE_NAME}$"; then
    print_error "App '${PACKAGE_NAME}' not found on device!"
    echo ""
    echo "Installed apps:"
    adb shell pm list packages | grep -i "$(echo $PACKAGE_NAME | cut -d. -f3-)" || echo "  No similar apps found"
    echo ""
    exit 1
fi
print_success "App found: ${PACKAGE_NAME}"

echo ""

################################################################################
# Step 2: Create Backup
################################################################################

print_info "Creating backup directory: ${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
print_success "Directory created"

echo ""
print_info "Creating ADB backup..."
print_warning "ACTION REQUIRED: Tap 'Back up my data' on your device (no password needed)"
echo ""

adb backup -apk -noshared "${PACKAGE_NAME}" -f "${BACKUP_FILE}"

# Check if backup was created
if [ ! -f "${BACKUP_FILE}" ] || [ ! -s "${BACKUP_FILE}" ]; then
    print_error "Backup failed or was cancelled!"
    exit 1
fi

BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
print_success "Backup created: ${BACKUP_SIZE}"

################################################################################
# Step 3: Decompress Backup
################################################################################

echo ""
print_info "Decompressing backup..."

# Skip first 24 bytes (Android backup header) and decompress
dd if="${BACKUP_FILE}" bs=1 skip=24 2>/dev/null | python3 -c "import zlib,sys; sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read()))" > "${TAR_FILE}"

if [ ! -f "${TAR_FILE}" ] || [ ! -s "${TAR_FILE}" ]; then
    print_error "Decompression failed!"
    exit 1
fi

TAR_SIZE=$(du -h "${TAR_FILE}" | cut -f1)
print_success "Decompressed to TAR: ${TAR_SIZE}"

################################################################################
# Step 4: Extract TAR Archive
################################################################################

echo ""
print_info "Extracting TAR archive..."
mkdir -p "${EXTRACTED_DIR}"
tar -xf "${TAR_FILE}" -C "${EXTRACTED_DIR}"
print_success "Files extracted"

################################################################################
# Step 5: Find Database Files
################################################################################

echo ""
print_info "Searching for SQLite databases..."

# Find all .db files and the 'db' directory
DB_FILES=$(find "${EXTRACTED_DIR}" -type f \( -name "*.db" -o -path "*/db/*" \) 2>/dev/null)

if [ -z "$DB_FILES" ]; then
    print_warning "No database files found!"
    print_info "Extracted contents:"
    ls -R "${EXTRACTED_DIR}"
    exit 0
fi

echo "$DB_FILES" | while read -r db_file; do
    # Check if it's a valid SQLite database
    if file "$db_file" | grep -q "SQLite"; then
        print_success "Found: $(basename $db_file)"
    fi
done

################################################################################
# Step 6: Export to Excel
################################################################################

echo ""
print_info "Exporting databases to Excel..."

# Create a temporary Python script file
cat > /tmp/export_db.py << 'PYTHON_SCRIPT'
import sys
import os
import sqlite3
import pandas as pd
from pathlib import Path

def export_database_to_excel(db_path, output_dir):
    """Export all tables from a SQLite database to Excel"""
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
        tables = [row[0] for row in cursor.fetchall()]
        
        if not tables:
            print(f"  No tables found in {os.path.basename(db_path)}")
            conn.close()
            return
        
        db_name = Path(db_path).stem
        excel_file = os.path.join(output_dir, f'{db_name}_export.xlsx')
        
        with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
            for table in tables:
                try:
                    df = pd.read_sql_query(f'SELECT * FROM "{table}"', conn)
                    sheet_name = table[:31]
                    df.to_excel(writer, sheet_name=sheet_name, index=False)
                    print(f'    ✓ {table}: {len(df)} rows')
                except Exception as e:
                    print(f'    ✗ Error with {table}: {e}')
        
        conn.close()
        print(f'  ✓ Created: {os.path.basename(excel_file)}')
        
    except Exception as e:
        print(f'  ✗ Error processing {os.path.basename(db_path)}: {e}')

# Get arguments
if len(sys.argv) < 3:
    print("Usage: export_db.py <extracted_dir> <output_dir>")
    sys.exit(1)

extracted_dir = sys.argv[1]
output_dir = sys.argv[2]

# Find all SQLite databases
db_files = []
for root, dirs, files in os.walk(extracted_dir):
    for file in files:
        file_path = os.path.join(root, file)
        try:
            with open(file_path, 'rb') as f:
                if f.read(16).startswith(b'SQLite format 3'):
                    db_files.append(file_path)
        except:
            pass

if db_files:
    print(f'Found {len(db_files)} database(s)')
    print()
    for db_file in db_files:
        print(f'Processing: {os.path.basename(db_file)}')
        export_database_to_excel(db_file, output_dir)
        print()
else:
    print('No SQLite databases found')
PYTHON_SCRIPT

# Run the Python script with proper arguments
python3 /tmp/export_db.py "${EXTRACTED_DIR}" "${OUTPUT_DIR}"

# Clean up temp file
rm -f /tmp/export_db.py

################################################################################
# Step 7: Cleanup
################################################################################

echo ""
print_info "Cleaning up intermediate files..."

# Ask user if they want to keep raw files
read -p "Keep raw backup files? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    rm -f "${BACKUP_FILE}" "${TAR_FILE}"
    rm -rf "${EXTRACTED_DIR}"
    print_success "Cleaned up intermediate files"
else
    print_info "Kept all files"
fi

################################################################################
# Step 8: Summary
################################################################################

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                    EXTRACTION COMPLETE                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
print_success "Output directory: ${OUTPUT_DIR}"
echo ""
print_info "Exported files:"
ls -lh "${OUTPUT_DIR}"/*.xlsx 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
echo ""
print_success "Done! Check the output directory for your Excel files."
echo ""