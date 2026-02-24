#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scan.sh"

cmd_inspect() {
  local dir="$1"
  echo "Inspecting directory: $dir"
  
  local files
  mapfile -t files < <(scan_images "$dir")
  
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No images found in $dir."
    return 0
  fi
  
  printf "%-50s | %-15s\n" "Filename" "Dimensions"
  printf "%.s-" {1..70}
  echo
  
  for file in "${files[@]}"; do
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
