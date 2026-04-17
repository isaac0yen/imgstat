#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

cmd_analyze() {
  local dir="$1"
  local target_option="${2:-1}"
  local json_format="$3"
  echo "Analyzing codebase for remote image references in $dir..." >&2

  # ── Step 1: Extract all http/https URLs from common code files ──────────────
  local all_urls=()
  mapfile -t all_urls < <(find "$dir" \
    -type d \( -name "node_modules" -o -name ".git" -o -name "dist" -o -name "build" -o -name "vendor" -o -name ".next" -o -name "coverage" \) -prune -o \
    -type f \( -name "*.html" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.js" -o -name "*.ts" \
               -o -name "*.vue" -o -name "*.css" -o -name "*.scss" -o -name "*.php" \
               -o -name "*.py" -o -name "*.rb" -o -name "*.svelte" -o -name "*.astro" \) \
    -exec grep -hoE "https?://[^\"')[:space:]]+" {} + 2>/dev/null | sort -u)

  if [[ ${#all_urls[@]} -eq 0 ]]; then
    echo "No remote URLs found in code files." >&2
    return 0
  fi

  echo "Found ${#all_urls[@]} unique URL(s). Classifying..." >&2
  echo "" >&2

  # ── Step 2: Classify each URL via 3-tier pipeline ──────────────────────────
  local image_extensions=("jpg" "jpeg" "png" "gif" "webp" "avif" "svg" "bmp" "tiff" "tif" "ico")

  local queued_urls=()

  for url in "${all_urls[@]}"; do
    # Strip query/fragment to inspect the path cleanly
    local path
    path=$(echo "$url" | sed 's/[?#].*//')
    local lower_path
    lower_path=$(echo "$path" | tr '[:upper:]' '[:lower:]')

    # ── Tier 1: Obvious non-image check (fast, no network) ──────────────────
    if is_obvious_non_image "$url"; then
      printf "  \033[2m⏭  Skip  (pattern match) : %s\033[0m\n" "$url" >&2
      continue
    fi

    # ── Tier 2: Image extension in path (fast, no network) ───────────────────
    local ext
    ext=$(echo "${lower_path##*.}" | sed 's/[^a-z]//g')
    local is_image_ext=false
    for img_ext in "${image_extensions[@]}"; do
      if [[ "$ext" == "$img_ext" ]]; then
        is_image_ext=true
        break
      fi
    done

    if [[ "$is_image_ext" == "true" ]]; then
      printf "  \033[1;32m✓  Queue (extension)     : %s\033[0m\n" "$url" >&2
      queued_urls+=("$url")
      continue
    fi

    # ── Tier 3: HTTP HEAD Content-Type check (network, no body download) ─────
    printf "  \033[33m?  Check (HEAD request)  : %s\033[0m" "$url" >&2
    if check_content_type_is_image "$url"; then
      printf "\r  \033[1;32m✓  Queue (content-type)  : %s\033[0m\n" "$url" >&2
      queued_urls+=("$url")
    else
      printf "\r  \033[2m⏭  Skip  (not image CT)  : %s\033[0m\n" "$url" >&2
    fi
  done

  echo "" >&2

  if [[ ${#queued_urls[@]} -eq 0 ]]; then
    echo "No image URLs found after classification." >&2
    return 0
  fi

  echo "Fetching dimensions for ${#queued_urls[@]} image URL(s)..." >&2
  echo "" >&2

  # ── Step 3: Download & measure queued image URLs ───────────────────────────
  local TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT

  # Output file setup
  local TEMP_RESULTS=$(mktemp)
  trap 'rm -rf "$TEMP_DIR" "$TEMP_RESULTS"' EXIT

  local processed=0

  for url in "${queued_urls[@]}"; do
    # Download the image content only
    wget -q --content-disposition --max-redirect=5 \
      --user-agent="Mozilla/5.0" \
      -P "$TEMP_DIR" "$url" 2>/dev/null || true

    shopt -s nullglob
    local all_files=( "$TEMP_DIR"/* )
    shopt -u nullglob
    local found_image=""

    for file in "${all_files[@]}"; do
      [[ ! -f "$file" ]] && continue
      local mimetype
      mimetype=$(file -b --mime-type "$file" 2>/dev/null || true)
      if [[ "$mimetype" == image/* ]]; then
        found_image="$file"
        break
      fi
    done

    if [[ -n "$found_image" ]]; then
      local dim
      dim=$(get_dimensions "$found_image" || true)
      if [[ -n "$dim" ]]; then
        local w="${dim% *}"
        local h="${dim#* }"
        echo "${url}|${w}|${h}" >> "$TEMP_RESULTS"
        printf "  \033[1;32m📐 %s → %sx%s\033[0m\n" "$url" "$w" "$h" >&2
        processed=$((processed + 1))
      fi
    fi

    # Clean temp dir for next URL to avoid collisions
    rm -rf "${TEMP_DIR:?}"/*
  done

  echo "" >&2
  echo "Analysis complete!" >&2

  if [[ $processed -eq 0 ]]; then
    echo "No matching images with dimension info could be parsed." >&2
    return 0
  fi

  # Depending on Target Option, write file.
  if [[ "$json_format" == "json" ]]; then
    # if it's format json without target, only output json
    if [[ -z "$2" ]]; then
      bash "$(dirname "${BASH_SOURCE[0]}")/format-json.sh" "$dir" "$TEMP_RESULTS" "0"
      return 0
    else
      bash "$(dirname "${BASH_SOURCE[0]}")/format-json.sh" "$dir" "$TEMP_RESULTS" "1"
    fi
  fi

  case "$target_option" in
    1)
      bash "$(dirname "${BASH_SOURCE[0]}")/write-agent.sh" "$dir" "$TEMP_RESULTS"
      ;;
    2)
      bash "$(dirname "${BASH_SOURCE[0]}")/write-cursor.sh" "$dir" "$TEMP_RESULTS"
      ;;
    3)
      bash "$(dirname "${BASH_SOURCE[0]}")/write-windsurf.sh" "$dir" "$TEMP_RESULTS"
      ;;
    4)
      bash "$(dirname "${BASH_SOURCE[0]}")/write-claude.sh" "$dir" "$TEMP_RESULTS"
      ;;
    5)
      bash "$(dirname "${BASH_SOURCE[0]}")/write-agent.sh" "$dir" "$TEMP_RESULTS"
      bash "$(dirname "${BASH_SOURCE[0]}")/write-cursor.sh" "$dir" "$TEMP_RESULTS"
      bash "$(dirname "${BASH_SOURCE[0]}")/write-windsurf.sh" "$dir" "$TEMP_RESULTS"
      bash "$(dirname "${BASH_SOURCE[0]}")/write-claude.sh" "$dir" "$TEMP_RESULTS"
      ;;
    *)
      # default
      bash "$(dirname "${BASH_SOURCE[0]}")/write-agent.sh" "$dir" "$TEMP_RESULTS"
      ;;
  esac

  echo "This file can now be read by autonomous coding agents." >&2
}
