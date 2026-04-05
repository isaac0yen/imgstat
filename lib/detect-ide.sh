#!/usr/bin/env bash

# IDE Detection Script for imgstat
# Identifies the environment and exports the correct routes for rule generation

# 1. Initialize variables
IDE_NAME="Generic"
RULE_PATH="AGENTS.md"
SUPPORTS_IMAGES=false

# 2. Check for Cursor specifically (it often sets CURSOR_CLI)
if [[ "$TERM_PROGRAM" == "cursor" ]] || [[ -n "$CURSOR_CLI" ]]; then
    IDE_NAME="Cursor"
    RULE_PATH=".cursor/rules/"
    SUPPORTS_IMAGES=false

# 3. Check for Windsurf
elif [[ "$TERM_PROGRAM" == "windsurf" ]] || [[ -n "$WINDSURF_CLI" ]]; then
    IDE_NAME="Windsurf"
    RULE_PATH=".windsurf/rules/"
    SUPPORTS_IMAGES=false

# 4. Check for VS Code / GitHub Copilot
elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
    IDE_NAME="VS Code"
    RULE_PATH=".github/copilot-instructions.md"
    SUPPORTS_IMAGES=false

# 5. Check for Kiro
elif [[ -n "$KIRO_SESSION_ID" ]] || [[ "$TERM_PROGRAM" == "kiro" ]]; then
    IDE_NAME="Kiro"
    RULE_PATH=".kiro/steering/"
    SUPPORTS_IMAGES=false

# 6. Check for iTerm2 (Good for imgstat image rendering)
elif [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ -n "$ITERM_SESSION_ID" ]]; then
    IDE_NAME="iTerm2"
    RULE_PATH=".agents/rules/"
    SUPPORTS_IMAGES=true

# 7. Check for Apple Terminal
elif [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    IDE_NAME="Apple Terminal"
    RULE_PATH="AGENTS.md"
    SUPPORTS_IMAGES=false

# 8. Windows-specific checks (WSL/Git Bash)
elif [[ -n "$WSLENV" ]] || [[ "$(uname -r)" == *"microsoft"* ]]; then
    # Check for Cursor on Windows
    if command -v tasklist.exe &> /dev/null && tasklist.exe 2>/dev/null | grep -qi "Cursor.exe"; then
        IDE_NAME="Cursor (Windows)"
        RULE_PATH=".cursor/rules/"
        SUPPORTS_IMAGES=false
    # Check for VS Code on Windows
    elif command -v tasklist.exe &> /dev/null && tasklist.exe 2>/dev/null | grep -qi "Code.exe"; then
        IDE_NAME="VS Code (Windows)"
        RULE_PATH=".github/copilot-instructions.md"
        SUPPORTS_IMAGES=false
    else
        IDE_NAME="WSL ($SHELL)"
        RULE_PATH="AGENTS.md"
        SUPPORTS_IMAGES=false
    fi

# 9. Fallback/Standard Check
else
    IDE_NAME="Generic Shell ($SHELL)"
    RULE_PATH="AGENTS.md"
fi

# Export the results for use in other scripts
export IMGSTAT_IDE="$IDE_NAME"
export IMGSTAT_PATH="$RULE_PATH"
export IMGSTAT_SUPPORTS_IMAGES="$SUPPORTS_IMAGES"

# Return values (for sourcing)
echo "$IDE_NAME|$RULE_PATH|$SUPPORTS_IMAGES"
