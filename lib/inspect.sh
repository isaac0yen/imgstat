#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scan.sh"

cmd_inspect() {
  local dir="$1"
  local format="$2"
  echo "Inspecting directory: $dir" >&2
  
  local files
  mapfile -t files < <(scan_images "$dir")
  
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No images found in $dir." >&2
    return 0
  fi
  
  if [[ "$format" == "json" ]]; then
    local temp_res=$(mktemp)
    for file in "${files[@]}"; do
      local dim
      dim=$(get_dimensions "$file" || true)
      if [[ -n "$dim" ]]; then
        local w="${dim% *}"
        local h="${dim#* }"
        echo "${file}|${w}|${h}" >> "$temp_res"
      fi
    done
    bash "$(dirname "${BASH_SOURCE[0]}")/format-json.sh" "." "$temp_res" "0"
    rm -f "$temp_res"
    return 0
  fi
  
  printf "%-50s | %-15s\n" "Filename" "Dimensions" >&2
  printf "%.s-" {1..70} >&2
  echo >&2
  
  for file in "${files[@]}"; do
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
