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

# Returns 0 (true) if the URL is obviously NOT an image.
# Uses domain and path-extension heuristics — no network call needed.
# Usage: is_obvious_non_image "https://..."
is_obvious_non_image() {
  local url="$1"

  # Strip query string / fragment for path inspection
  local path
  path=$(echo "$url" | sed 's/[?#].*//')

  # --- Known non-image domains ---
  local non_image_domains=(
    "fonts.googleapis.com"
    "fonts.gstatic.com"
    "googletagmanager.com"
    "google-analytics.com"
    "www.google-analytics.com"
    "youtube.com"
    "www.youtube.com"
    "youtu.be"
    "vimeo.com"
    "www.vimeo.com"
    "maps.google.com"
    "maps.googleapis.com"
    "plausible.io"
    "cdn.rawgit.com"
    "ajax.googleapis.com"
    "cdnjs.cloudflare.com"
  )
  local domain
  domain=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|')
  for d in "${non_image_domains[@]}"; do
    if [[ "$domain" == "$d" ]]; then
      return 0
    fi
  done

  # --- Non-image path extensions ---
  local lower_path
  lower_path=$(echo "$path" | tr '[:upper:]' '[:lower:]')
  local non_image_exts=(".js" ".mjs" ".css" ".scss" ".json" ".xml" ".html"
    ".woff" ".woff2" ".ttf" ".eot" ".otf"
    ".pdf" ".zip" ".tar" ".gz"
    ".mp4" ".mp3" ".ogg" ".webm" ".avi" ".mov"
    ".txt" ".md" ".csv"
  )
  for ext in "${non_image_exts[@]}"; do
    if [[ "$lower_path" == *"$ext" ]]; then
      return 0
    fi
  done

  # --- Non-image URL path fragments ---
  local non_image_patterns=("/api/" "/feed" "/rss" "/sitemap" "/graphql" "/oauth" "/auth/" "/login" "/logout")
  for pat in "${non_image_patterns[@]}"; do
    if [[ "$lower_path" == *"$pat"* ]]; then
      return 0
    fi
  done

  return 1
}

# Returns 0 (true) if the URL's HTTP Content-Type header indicates an image.
# Uses a lightweight HEAD request — no body downloaded.
# Usage: check_content_type_is_image "https://..."
check_content_type_is_image() {
  local url="$1"
  local content_type
  content_type=$(curl -sI --max-time 8 --location \
    -H "User-Agent: Mozilla/5.0" \
    "$url" 2>/dev/null \
    | grep -i '^content-type:' \
    | tail -1 \
    | tr -d '\r')
  if [[ "$content_type" == *"image/"* ]]; then
    return 0
  fi
  return 1
}
