#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scan.sh"

cmd_rename() {
  local dir="$1"
  local dry_run="$2" # true or false
  local auto_yes="$3" # true or false
  
  local files
  mapfile -t files < <(scan_images "$dir")
  
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No images found in $dir."
    return 0
  fi
  
  local to_rename=()
  local new_names=()
  
  for file in "${files[@]}"; do
    local dim
    dim=$(get_dimensions "$file" || true)
    if [[ -z "$dim" ]]; then
      continue
    fi
    local w="${dim% *}"
    local h="${dim#* }"
    
    local new_filename
    new_filename=$(format_filename "$file" "$w" "$h")
    
    if [[ -n "$new_filename" ]]; then
      to_rename+=("$file")
      new_names+=("$new_filename")
    fi
  done
  
  if [[ ${#to_rename[@]} -eq 0 ]]; then
    echo "All images already have dimensions in their filenames. Nothing to do."
    return 0
  fi
  
  echo "Found ${#to_rename[@]} file(s) to rename:"
  for i in "${!to_rename[@]}"; do
    echo "  $(basename "${to_rename[$i]}") -> $(basename "${new_names[$i]}")"
  done
  
  if [[ "$dry_run" == "true" ]]; then
    echo
    echo "[Dry Run] No files were changed."
    return 0
  fi
  
  if [[ "$auto_yes" != "true" ]]; then
    echo
    read -r -p "Proceed with renaming? [y/N] " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi
  
  for i in "${!to_rename[@]}"; do
    mv "${to_rename[$i]}" "${new_names[$i]}"
  done
  
  echo "Renaming complete."
}
