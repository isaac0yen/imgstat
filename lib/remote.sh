#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

cmd_remote() {
  local url="$1"
  local dry_run="$2"
  
  if [[ "$dry_run" == "true" ]]; then
    echo "[Dry Run] Would fetch $url to extract dimensions. Nothing will be downloaded."
    return 0
  fi
  
  echo "Fetching images from $url..."
  
  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT
  
  # 1. Fetch direct URL (handles direct images without extensions like Cloudinary)
  wget -q --content-disposition -P "$TEMP_DIR" "$url" || true
  
  # 2. Shallow scrape for linked images (handles HTML pages)
  wget -q -nd -r -l 1 -A jpeg,jpg,bmp,gif,png,webp,avif -P "$TEMP_DIR" "$url" || true
  
  local all_files=( "$TEMP_DIR"/* )
  local found_images=()
  
  # Filter only actual images
  for file in "${all_files[@]}"; do
    if [[ ! -f "$file" ]]; then continue; fi
    local mimetype
    mimetype=$(file -b --mime-type "$file" 2>/dev/null || true)
    if [[ "$mimetype" == image/* ]]; then
      found_images+=("$file")
    fi
  done
  
  if [[ ${#found_images[@]} -eq 0 ]]; then
    echo "No images found at $url."
    return 0
  fi
  
  printf "%-50s | %-15s\n" "Filename" "Dimensions"
  printf "%.s-" {1..70}
  echo
  
  for file in "${found_images[@]}"; do
    local dim
    dim=$(get_dimensions "$file" || true)
    if [[ -n "$dim" ]]; then
      local w="${dim% *}"
      local h="${dim#* }"
      printf "%-50s | %s x %s\n" "$(basename "$file")" "$w" "$h"
    else
      printf "%-50s | %-15s\n" "$(basename "$file")" "Error reading"
    fi
  done
}
