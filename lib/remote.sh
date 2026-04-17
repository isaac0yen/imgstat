#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

cmd_remote() {
  local url="$1"
  local dry_run="$2"
  local format="$3"
  
  if [[ "$dry_run" == "true" ]]; then
    echo "[Dry Run] Would fetch $url to extract dimensions. Nothing will be downloaded." >&2
    return 0
  fi
  
  echo "Fetching images from $url..." >&2
  
  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT
  
  # 1. Fetch direct URL (handles direct images without extensions like Cloudinary)
  wget -q --timeout=10 --tries=2 --content-disposition -P "$TEMP_DIR" "$url" || true
  
  # 2. Shallow scrape for linked images (handles HTML pages)
  wget -q --timeout=10 --tries=2 -nd -r -l 1 -A jpeg,jpg,bmp,gif,png,webp,avif -P "$TEMP_DIR" "$url" || true
  
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
    echo "No images found at $url." >&2
    return 0
  fi
  
  if [[ "$format" == "json" ]]; then
    local temp_res=$(mktemp)
    for file in "${found_images[@]}"; do
      local dim
      dim=$(get_dimensions "$file" || true)
      if [[ -n "$dim" ]]; then
        local w="${dim% *}"
        local h="${dim#* }"
        # Provide base filename since it matches expected JSON output
        echo "$(basename "$file")|${w}|${h}" >> "$temp_res"
      fi
    done
    bash "$(dirname "${BASH_SOURCE[0]}")/format-json.sh" "." "$temp_res" "0"
    rm -f "$temp_res"
    return 0
  fi
  
  printf "%-50s | %-15s\n" "Filename" "Dimensions" >&2
  printf "%.s-" {1..70} >&2
  echo >&2
  
  for file in "${found_images[@]}"; do
    local dim
    dim=$(get_dimensions "$file" || true)
    if [[ -n "$dim" ]]; then
      local w="${dim% *}"
      local h="${dim#* }"
      printf "%-50s | %s x %s\n" "$(basename "$file")" "$w" "$h"
    else
      printf "%-50s | %-15s\n" "$(basename "$file")" "Error reading" >&2
    fi
  done
}
