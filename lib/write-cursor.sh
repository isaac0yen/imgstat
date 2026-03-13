#!/usr/bin/env bash

# Inputs
# $1: Directory path
# $2: Temp file containing results in format: url|width|height

DIR="$1"
RESULTS_FILE="$2"

RULES_DIR="$DIR/.cursor/rules"
RULES_FILE="$RULES_DIR/image_dimensions.mdc"

mkdir -p "$RULES_DIR"

cat << 'EOF' > "$RULES_FILE"
---
description: image dimension context for all assets in this project
alwaysApply: true
---

when working with images in this project, always refer to this file.
never guess dimensions. never use vision tokens to infer size.

| file | width | height |
|------|-------|--------|
EOF

while IFS='|' read -r url w h; do
  echo "| $url | $w | $h |" >> "$RULES_FILE"
done < "$RESULTS_FILE"

echo "Wrote cursor rules to: $RULES_FILE"
