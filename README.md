
# 📱 Android App Database Extractor

A comprehensive shell script to extract and export SQLite databases from Android applications via ADB backup. Converts app databases to Excel format for easy data analysis.

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Locating Your Extracted Data](#-locating-your-extracted-data)
- [Troubleshooting](#-troubleshooting)
- [Security & Privacy](#-security--privacy)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- ✅ **Automated Database Extraction** - One command to extract all app databases
- ✅ **Excel Export** - Automatically converts SQLite databases to Excel (.xlsx)
- ✅ **Multi-table Support** - Each database table becomes a separate Excel sheet
- ✅ **User-friendly** - Color-coded output with progress indicators
- ✅ **Safe & Non-destructive** - Creates backups without modifying the original app
- ✅ **Cross-platform** - Works on macOS, Linux, and Windows (WSL)
- ✅ **Detailed Logging** - Clear output of what's happening at each step

---

## 📦 Prerequisites

### Required Software

1. **Android Platform Tools (ADB)**
   - macOS: `brew install android-platform-tools`
   - Linux: `sudo apt-get install android-tools-adb`
   - Windows: [Download from Google](https://developer.android.com/studio/releases/platform-tools)

2. **Python 3.7+**
   - macOS: `brew install python3`
   - Linux: `sudo apt-get install python3`
   - Windows: [Download from python.org](https://www.python.org/downloads/)

3. **Python Libraries**
   ```bash
   pip3 install pandas openpyxl
   ```

### Android Device Requirements

- USB Debugging enabled
- Android 4.0+ (Ice Cream Sandwich or later)
- USB cable connection to computer
- App must allow backup (most apps do by default)

### Enabling USB Debugging

1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go to **Settings** → **Developer Options**
4. Enable **USB Debugging**
5. Connect your device and authorize your computer when prompted

---

## 🚀 Installation

### Method 1: Clone Repository

```bash
git clone https://github.com/yourusername/android-db-extractor.git
cd android-db-extractor
chmod +x extract_android_db.sh
```

### Method 2: Direct Download

```bash
curl -O https://raw.githubusercontent.com/yourusername/android-db-extractor/main/extract_android_db.sh
chmod +x extract_android_db.sh
```

### Verify Installation

```bash
./extract_android_db.sh
```

You should see the help message with usage instructions.

---

## 📖 Usage

### Basic Usage

```bash
./extract_android_db.sh <package_name>
```

### Finding Your App's Package Name

**Method 1: List all installed packages**
```bash
adb shell pm list packages
```

**Method 2: Search for a specific app**
```bash
adb shell pm list packages | grep <app_name>
```

**Method 3: Get package of currently running app**
```bash
adb shell dumpsys window | grep mCurrentFocus
```

**Examples:**
```bash
# List all packages containing "messenger"
adb shell pm list packages | grep messenger
# Output: package:com.facebook.orca

# List all packages containing "twitter"
adb shell pm list packages | grep twitter
# Output: package:com.twitter.android
```

### Complete Example

```bash
# Find the package name
adb shell pm list packages | grep myapp

# Extract the database
./extract_android_db.sh com.example.myapp
```

### What Happens During Extraction

1. **Pre-flight Checks** - Verifies ADB, Python, device connection
2. **Device Prompt** - You'll see a prompt on your Android device
3. **Action Required** - Tap "Back up my data" on your device (no password needed)
4. **Extraction** - Script extracts and decompresses the backup
5. **Database Search** - Locates all SQLite databases in the app
6. **Excel Export** - Converts each database to an Excel file
7. **Cleanup** - Optionally removes intermediate files
8. **Summary** - Shows location of exported files

### Expected Output

```
╔════════════════════════════════════════════════════════╗
║       Android App Database Extractor v1.0             ║
╚════════════════════════════════════════════════════════╝

ℹ Running pre-flight checks...
✓ ADB found: Android Debug Bridge version 1.0.41
✓ Python 3 found: Python 3.11.5
✓ Required Python libraries found
✓ Android device connected: ABC123XYZ
✓ App found: com.example.myapp

ℹ Creating backup directory: output/com.example.myapp_20251030_123456
✓ Directory created

ℹ Creating ADB backup...
⚠ ACTION REQUIRED: Tap 'Back up my data' on your device (no password needed)

Now unlock your device and confirm the backup operation...
✓ Backup created: 2.5M

ℹ Decompressing backup...
✓ Decompressed to TAR: 8.3M

ℹ Extracting TAR archive...
✓ Files extracted

ℹ Searching for SQLite databases...
✓ Found: database1
✓ Found: database2

ℹ Exporting databases to Excel...
Found 2 database(s)

Processing: database1
    ✓ table1: 15 rows
    ✓ table2: 234 rows
    ✓ table3: 890 rows
  ✓ Created: database1_export.xlsx

Processing: database2
    ✓ settings: 23 rows
  ✓ Created: database2_export.xlsx

ℹ Cleaning up intermediate files...
Keep raw backup files? (y/N): n
✓ Cleaned up intermediate files

╔════════════════════════════════════════════════════════╗
║                    EXTRACTION COMPLETE                 ║
╚════════════════════════════════════════════════════════╝

✓ Output directory: output/com.example.myapp_20251030_123456

ℹ Exported files:
  database1_export.xlsx (245K)
  database2_export.xlsx (12K)

✓ Done! Check the output directory for your Excel files.
```

---

## 📁 Locating Your Extracted Data

### Where Are My Files?

After running the script, your data is saved in the `output/` directory with a timestamp:

```
output/
└── [package_name]_[timestamp]/
    └── [database_name]_export.xlsx
```

### Finding Your Excel Files

#### Method 1: Use File Explorer (Recommended)

**macOS:**
```bash
# Open the output folder in Finder
open output/
```

**Linux:**
```bash
# Open the output folder
xdg-open output/
```

**Windows:**
```bash
# Open the output folder
explorer output/
```

Or navigate manually:
1. Open your file manager
2. Navigate to the project directory
3. Open the `output/` folder
4. Look for the most recent folder (sorted by date)
5. Your Excel files are inside

#### Method 2: Command Line

```bash
# List all extracted Excel files
ls -lh output/*/*.xlsx

# Example output:
# -rw-r--r--  1 user  staff   245K Oct 30 12:34 output/com.example.myapp_20251030_123456/database_export.xlsx
```

#### Method 3: Open Directly

**macOS:**
```bash
# Open the most recent Excel file
open $(ls -t output/*/*.xlsx | head -1)
```

**Linux:**
```bash
# Open the most recent Excel file
xdg-open $(ls -t output/*/*.xlsx | head -1)
```

This will open the Excel file in your default spreadsheet application (Excel, Numbers, LibreOffice, etc.)

---

### Understanding the Output Structure

#### Typical Output Folder:

```
output/com.example.myapp_20251030_123456/
├── database_export.xlsx        ← Your main data file
├── backup.ab                   ← (Optional) Original backup
├── backup.tar                  ← (Optional) Decompressed backup
└── extracted/                  ← (Optional) Full app extraction
    └── apps/
        └── com.example.myapp/
            ├── db/
            │   └── database    ← Original SQLite database
            ├── f/              ← App files
            └── sp/             ← Shared preferences
```

#### The Important Files:

| File | Description | Keep? |
|------|-------------|-------|
| `*_export.xlsx` | **Your data in Excel format** | ✅ Yes |
| `backup.ab` | Raw Android backup (compressed) | ⚠️ Optional |
| `backup.tar` | Decompressed backup (TAR archive) | ⚠️ Optional |
| `extracted/` | All extracted app files | ⚠️ Optional |

---

### Opening Excel Files

#### macOS:
```bash
# Open in default app
open output/com.example.myapp_*/database_export.xlsx

# Open in specific application
open -a "Microsoft Excel" output/com.example.myapp_*/database_export.xlsx
open -a "Numbers" output/com.example.myapp_*/database_export.xlsx
```

#### Linux:
```bash
# Open with default application
xdg-open output/com.example.myapp_*/database_export.xlsx

# Open with LibreOffice
libreoffice output/com.example.myapp_*/database_export.xlsx
```

#### Windows (WSL):
```bash
# Open with default application
explorer.exe output/com.example.myapp_*/database_export.xlsx
```

---

### Copying Files to Another Location

```bash
# Copy Excel file to Desktop
cp output/com.example.myapp_*/database_export.xlsx ~/Desktop/

# Copy to Documents
cp output/com.example.myapp_*/database_export.xlsx ~/Documents/

# Copy to external drive
cp output/com.example.myapp_*/database_export.xlsx /Volumes/USB_DRIVE/
```

---

### What's Inside the Excel File?

The Excel file contains multiple sheets, one for each database table:

Each sheet contains:
- **Column headers** in the first row
- **One row per record**
- **All data** from that table

Example structure:
```
database_export.xlsx
├── Sheet1: users (50 rows, 5 columns)
├── Sheet2: messages (1,234 rows, 8 columns)
├── Sheet3: settings (15 rows, 3 columns)
└── Sheet4: history (678 rows, 6 columns)
```

---

### Backup Your Data

**After successful extraction, immediately backup your Excel files:**

```bash
# Create a backup folder
mkdir -p ~/Documents/AppBackups/$(date +%Y%m%d)

# Copy Excel files
cp output/*/*.xlsx ~/Documents/AppBackups/$(date +%Y%m%d)/

# Verify backup
ls -lh ~/Documents/AppBackups/$(date +%Y%m%d)/
```

**Or use cloud storage:**
```bash
# Copy to Dropbox
cp output/*/*.xlsx ~/Dropbox/AppBackups/

# Copy to Google Drive (if mounted)
cp output/*/*.xlsx ~/Google\ Drive/AppBackups/

# Copy to iCloud Drive
cp output/*/*.xlsx ~/Library/Mobile\ Documents/com~apple~CloudDocs/AppBackups/
```

---

## 🔧 Troubleshooting

### Problem 1: Device Not Detected

**Symptoms:**
- Error: "No Android device connected"
- `adb devices` shows empty list

**Solutions:**

1. **Check USB connection:**
   - Try a different USB cable
   - Try a different USB port
   - Make sure device is unlocked

2. **Enable USB Debugging:**
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
   - Accept "Allow USB debugging" prompt on device

3. **Restart ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

---

### Problem 2: Backup Failed or No Data Extracted

**Symptoms:**
- Error: "Backup failed or was cancelled"
- Error: "No database files found"
- Backup file is very small (< 100KB)

**Solutions:**

1. **User action required:**
   - Make sure you tapped "Back up my data" on your device (NOT "Cancel")
   - Keep your device screen on during the backup process
   - Don't set a backup password (leave it blank)

2. **App doesn't support backup:**
   - Some apps disable backup in their manifest
   - Try a different app or contact the app developer
   - Check: `adb shell dumpsys package <package_name> | grep backup`

3. **Run script again:**
   - Sometimes the backup times out
   - Simply run the script again and respond quickly to the device prompt

---

### Problem 3: Excel File Empty or Missing

**Symptoms:**
- Excel file exists but has no data
- Excel file won't open
- No Excel files created

**Solutions:**

1. **Check Python libraries:**
   ```bash
   pip3 install --upgrade pandas openpyxl
   python3 -c "import pandas; import openpyxl; print('OK')"
   ```

2. **Verify database files exist:**
   ```bash
   # Check if databases were found
   find output/*/extracted/ -name "*.db"
   find output/*/extracted/ -type f
   ```

3. **Manually check the database:**
   ```bash
   # Find database files
   find output/*/extracted/apps/*/db/ -type f
   
   # Check if it's a valid SQLite database
   file output/*/extracted/apps/*/db/*
   # Should show: "SQLite 3.x database"
   ```

---

## 🔒 Security & Privacy

### Data Safety

- ✅ **Read-only operation** - The script never modifies your Android device
- ✅ **Local extraction** - All data stays on your computer
- ✅ **No network activity** - No data is sent to any servers
- ✅ **User control** - You control what gets backed up and extracted

### Best Practices

1. **Secure your extracted data:**
   - Store Excel files in encrypted folders
   - Delete output folder after copying important files
   - Don't share Excel files containing personal data

2. **Clean up regularly:**
   ```bash
   # Remove all extracted data
   rm -rf output/
   ```

3. **Verify app trustworthiness:**
   - Only extract data from apps you trust
   - Be cautious with sensitive data (banking, passwords, etc.)


---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

This tool is for personal use only. Always respect:
- App Terms of Service
- User privacy and data protection laws
- Copyright and intellectual property rights

Use this tool responsibly and only on apps and data you own or have permission to access.

---

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Search existing [GitHub Issues](https://github.com/yourusername/android-db-extractor/issues)
3. Create a new issue with:
   - Your operating system
   - ADB version (`adb version`)
   - Python version (`python3 --version`)
   - Complete error message
   - Steps to reproduce

---

## 🌟 Acknowledgments

- Android Platform Tools team
- Python pandas and openpyxl developers
- Community contributors

---


```
