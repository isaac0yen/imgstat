#!/usr/bin/env bash

# Recursively find images, ignoring node_modules and .git
# Usage: scan_images "directory"
scan_images() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "Error: Directory '$dir' does not exist." >&2
    exit 1
  fi
  
  # GNU find syntax for ignoring dirs and matching extensions case-insensitively
  find "$dir" -type d \( -name "node_modules" -o -name ".git" \) -prune \
    -o -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \) -print
}
