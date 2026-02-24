#!/usr/bin/env bash

# Check if required command is available
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed." >&2
    exit 1
  fi
}

# Get Image Dimensions using ImageMagick 'identify'
# Usage: get_dimensions "file.jpg"
# Outputs: width height
get_dimensions() {
  local file="$1"
  # -ping is faster because it doesn't read the whole image data if possible
  if ! dim=$(identify -ping -format "%w %h" "$file" 2>/dev/null); then
    return 1
  fi
  echo "$dim"
}

# Generate the target filename if it doesn't already have the dimensions
# Usage: format_filename "file.jpg" "800" "600"
# Outputs: target_file.jpg (or nothing if it shouldn't be renamed)
format_filename() {
  local file="$1"
  local w="$2"
  local h="$3"
  
  local filename
  filename=$(basename -- "$file")
  local ext="${filename##*.}"
  local name="${filename%.*}"
  
  # If file has no extension
  if [[ "$name" == "$filename" ]]; then
    ext=""
  fi
  
  local dim_suffix="${w}x${h}"
  
  # Check if already ends with -WxH
  if [[ "$name" == *-*x* ]]; then
    local current_suffix="${name##*-}"
    if [[ "$current_suffix" == "$dim_suffix" ]]; then
      # Already correct
      return 0
    fi
  fi
  
  local new_name
  if [[ -n "$ext" ]]; then
    new_name="${name}-${dim_suffix}.${ext}"
  else
    new_name="${name}-${dim_suffix}"
  fi
  
  local dirname
  dirname=$(dirname -- "$file")
  
  echo "$dirname/$new_name"
}
