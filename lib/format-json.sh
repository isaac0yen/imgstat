#!/usr/bin/env bash

# Inputs
# $1: Directory path
# $2: Temp file containing results in format: url|width|height
# $3: Optional. Target flag meaning we must write to file instead of stdout.

DIR="$1"
RESULTS_FILE="$2"
HAS_TARGET="$3"

JSON_FILE=""
if [[ "$HAS_TARGET" == "1" ]]; then
  JSON_FILE="$DIR/image_dimensions.json"
fi

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

TEMP_JSON=$(mktemp)

echo "{" > "$TEMP_JSON"
echo "  \"generated_at\": \"$NOW\"," >> "$TEMP_JSON"
echo "  \"images\": [" >> "$TEMP_JSON"

FIRST_ITEM=true

while IFS='|' read -r url w h; do
  if [ "$FIRST_ITEM" = "true" ]; then
    FIRST_ITEM=false
  else
    echo "    ," >> "$TEMP_JSON"
  fi
  # We escape the URL safely
  # Assuming url doesn't have quotes for now, but good practice
  SAFE_URL=$(echo -n "$url" | sed 's/"/\\"/g')
  echo -n "    { \"path\": \"$SAFE_URL\", \"width\": $w, \"height\": $h }" >> "$TEMP_JSON"
done < "$RESULTS_FILE"

echo "" >> "$TEMP_JSON"
echo "  ]" >> "$TEMP_JSON"
echo "}" >> "$TEMP_JSON"

if [[ -n "$JSON_FILE" ]]; then
  mv "$TEMP_JSON" "$JSON_FILE"
  echo "Wrote JSON dimension report to: $JSON_FILE"
else
  cat "$TEMP_JSON"
  rm -f "$TEMP_JSON"
fi
