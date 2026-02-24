#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/inspect.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/rename.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/remote.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/analyze.sh"

cmd_ui() {
  local options=("Inspect local directory" "Rename local files" "Analyze remote URL" "Analyze codebase (.agent/rules)" "Quit")
  local selected=0

  # Hide cursor
  tput civis
  
  while true; do
    echo -ne "\033[1;36mimgstat\033[0m: The tool for embedding image dimensions in filenames.\n"
    echo "Select an operation mode (Use Up/Down arrows and Enter):"
    
    for i in "${!options[@]}"; do
      if [[ $i -eq $selected ]]; then
        echo -e "\033[1;32m> ${options[$i]}\033[0m"
      else
        echo "  ${options[$i]}"
      fi
    done
    
    read -rsn1 key || true
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 -t 0.1 seq || true
      case "$seq" in
        "[A") # Up arrow
          ((selected--)) || true
          if [[ $selected -lt 0 ]]; then selected=$((${#options[@]} - 1)); fi
          ;;
        "[B") # Down arrow
          ((selected++)) || true
          if [[ $selected -ge ${#options[@]} ]]; then selected=0; fi
          ;;
      esac
    elif [[ $key == "" ]]; then # Enter key
      # Clear menu lines before proceeding
      tput cuu $((${#options[@]} + 2))
      tput ed
      break
    fi
    
    # Go up and clear to redraw
    tput cuu $((${#options[@]} + 2))
    tput ed
  done
  
  # Restore cursor
  tput cnorm
  
  case "$selected" in
    0)
      read -e -p "Enter directory to inspect [./]: " dir
      dir="${dir:-./}"
      cmd_inspect "$dir"
      ;;
    1)
      read -e -p "Enter directory to rename [./]: " dir
      dir="${dir:-./}"
      cmd_rename "$dir" "false" "false"
      ;;
    2)
      read -e -p "Enter URL to analyze: " url
      if [[ -z "$url" ]]; then
        echo "URL cannot be empty."
      else
        cmd_remote "$url" "false"
      fi
      ;;
    3)
      read -e -p "Enter codebase directory to analyze [./]: " dir
      dir="${dir:-./}"
      cmd_analyze "$dir"
      ;;
    4)
      echo "Exiting."
      ;;
  esac
}
