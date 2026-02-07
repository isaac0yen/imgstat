# imagestat

[![npm version](https://img.shields.io/npm/v/imgstat.svg)](https://www.npmjs.com/package/imgstat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**imagestat** is a powerful bash utility that recursively scans directories for images, downloads them, and automatically renames them to include their dimensions (e.g., `image-1920x1080.jpg`).

## Features

- **Recursive Scanning**: Finds images deep within subdirectories.
- **Smart Renaming**: `My Photo.jpg` -> `my-photo-800x600.jpg`
- **Smart Ignores**: Skips `node_modules`, `.git`, `dist`, etc.
- **URL Download**: Optionally download images first.

## Installation

### Option 1: NPM (Node.js)
The easiest way if you have Node.js installed:
```bash
npm install -g imgstat
```
*Note: Requires a bash environment (Linux, macOS, WSL, or Git Bash).*

### Option 2: Universal Install Script (Linux/macOS)
One-line install from your terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/isaac0yen/imgstat/main/install.sh | sudo bash
```

### Option 3: Debian/Ubuntu (.deb)
If you prefer a package manager:
1. Download the latest `.deb` from the [Releases page](https://github.com/isaac0yen/imgstat/releases).
2. Install it:
   ```bash
   sudo apt install ./imagestat_1.0_all.deb
   ```

### Option 4: Manual
```bash
git clone https://github.com/isaac0yen/imgstat.git
cd imgstat
sudo ./install.sh
```

### Windows
1.  **Recommended**: Use **WSL** (Ubuntu) and follow "Option 2".
2.  **Git Bash**: Clone the repo and run `./imagestat` directly.

## Usage

```bash
imagestat [directory]
```

**Download and process:**
```bash
imagestat -u https://example.com/images my-folder
```