#!/bin/bash

APP_NAME="imagestat"
INSTALL_DIR="/usr/local/bin"
TARGET_PATH="$INSTALL_DIR/$APP_NAME"
SOURCE_FILE=""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing $APP_NAME...${NC}"

# Check sudo
if [ "$EUID" -ne 0 ]; then 
  echo -e "${YELLOW}Please run as root (sudo) to install globally.${NC}"
  echo "Try: sudo ./install.sh"
  exit 1
fi

# Locate source file
if [ -f "imagestat" ]; then
    SOURCE_FILE="imagestat"
elif [ -f "imgstat.sh" ]; then
    SOURCE_FILE="imgstat.sh"
else
    echo "Local script not found. Downloading from GitHub..."
    REMOTE_URL="https://raw.githubusercontent.com/isaac0yen/imgstat/main/imagestat"
    if command -v curl &> /dev/null; then
        curl -fsSL "$REMOTE_URL" -o imagestat
    elif command -v wget &> /dev/null; then
        wget -q "$REMOTE_URL" -O imagestat
    else
        echo -e "${RED}Error: Neither curl nor wget found. Cannot download script.${NC}"
        exit 1
    fi
    
    if [ ! -f "imagestat" ]; then
         echo -e "${RED}Error: Failed to download script.${NC}"
         exit 1
    fi
    SOURCE_FILE="imagestat"
fi

# Check dependencies
MISSING_DEPS=0
if ! command -v identify &> /dev/null; then
    echo -e "${RED}Error: 'identify' (ImageMagick) is not installed.${NC}"
    MISSING_DEPS=1
fi
if ! command -v wget &> /dev/null; then
    echo -e "${RED}Error: 'wget' is not installed.${NC}"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo -e "${YELLOW}Please install missing dependencies first.${NC}"
    exit 1
fi

echo "Installing $SOURCE_FILE to $TARGET_PATH..."
cp "$SOURCE_FILE" "$TARGET_PATH"
chmod +x "$TARGET_PATH"

echo -e "${GREEN}Success! $APP_NAME has been installed.${NC}"
echo -e "Usage: ${GREEN}$APP_NAME [directory]${NC}"
