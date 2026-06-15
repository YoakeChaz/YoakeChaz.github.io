#!/usr/bin/env bash
# ===========================================================================
# Godot 4.6 headless auto-validation loop (macOS) — no manual F5 needed.
#
# Usage (from anywhere; the script finds the project relative to itself):
#   bash "_verify/verify.sh"
#
# It will:
#   1. Locate the Godot 4.x CLI (inside Godot.app, or $GODOT_PATH).
#   2. Headless-import the project (builds .godot/, surfaces resource/uid errors).
#   3. Run validate.gd headless to catch GDScript/scene/resource load errors.
#   4. Run screenshot.gd (windowed) to capture one PNG of Main.tscn.
#
# All output is written into _verify/ :
#   log.txt              full run log (validation + engine stderr)
#   shot_<timestamp>.png one screenshot of the running main scene
# ===========================================================================
set -uo pipefail

# --- Resolve paths (works with spaces and CJK characters in the path) ------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERIFY_DIR="$SCRIPT_DIR"
TS="$(date +%Y%m%d_%H%M%S)"
LOG="$VERIFY_DIR/log.txt"
SHOT="$VERIFY_DIR/shot_$TS.png"

# --- Find the Godot 4.x CLI binary -----------------------------------------
find_godot() {
  if [[ -n "${GODOT_PATH:-}" && -x "${GODOT_PATH:-}" ]]; then
    echo "$GODOT_PATH"; return 0
  fi
  local candidates=(
    "/Applications/Godot.app/Contents/MacOS/Godot"
    "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
    "/Applications/Godot_mono.app/Contents/MacOS/Godot"
    "$HOME/Applications/Godot_mono.app/Contents/MacOS/Godot"
  )
  local c
  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { echo "$c"; return 0; }
  done
  # Spotlight fallback: find any installed Godot.app by bundle id.
  if command -v mdfind >/dev/null 2>&1; then
    local app
    app="$(mdfind 'kMDItemCFBundleIdentifier == "org.godotengine.godot"' 2>/dev/null | head -n1)"
    if [[ -n "$app" && -x "$app/Contents/MacOS/Godot" ]]; then
      echo "$app/Contents/MacOS/Godot"; return 0
    fi
  fi
  # PATH fallback.
  command -v godot >/dev/null 2>&1 && { command -v godot; return 0; }
  return 1
}

GODOT="$(find_godot)" || {
  echo "ERROR: Godot 4.x CLI not found." >&2
  echo "Set GODOT_PATH and retry, e.g.:" >&2
  echo '  GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot" bash "_verify/verify.sh"' >&2
  exit 2
}

mkdir -p "$VERIFY_DIR"
: > "$LOG"
log() { echo "$@" | tee -a "$LOG"; }

log "=================================================="
log " Godot verify run  $TS"
log " Godot binary : $GODOT"
log " Project      : $PROJECT_DIR"
log " Output dir   : $VERIFY_DIR"
"$GODOT" --version 2>&1 | tee -a "$LOG"
log "=================================================="

# --- STEP 1: headless import (Godot 4.4+ supports --import) -----------------
log ""
log "### STEP 1: headless import ###"
"$GODOT" --headless --path "$PROJECT_DIR" --import 2>&1 | tee -a "$LOG"

# --- STEP 2: headless script/scene/resource validation ---------------------
log ""
log "### STEP 2: script / scene / resource validation ###"
"$GODOT" --headless --path "$PROJECT_DIR" --script "res://_verify/validate.gd" 2>&1 | tee -a "$LOG"
VALIDATE_RC=${PIPESTATUS[0]}

# --- STEP 3: screenshot (windowed render; Metal first, GL Compat fallback) -
log ""
log "### STEP 3: screenshot ###"
export VERIFY_SHOT="$SHOT"
"$GODOT" --path "$PROJECT_DIR" --rendering-driver metal \
  --script "res://_verify/screenshot.gd" 2>&1 | tee -a "$LOG"
if [[ ! -f "$SHOT" ]]; then
  log "Metal did not produce a screenshot; retrying with GL Compatibility..."
  "$GODOT" --path "$PROJECT_DIR" --rendering-method gl_compatibility \
    --rendering-driver opengl3 --script "res://_verify/screenshot.gd" 2>&1 | tee -a "$LOG"
fi

# --- STEP 4: summary -------------------------------------------------------
log ""
log "### SUMMARY ###"
ERR_COUNT="$(grep -c -E 'SCRIPT ERROR|VERIFY_FAIL|^ERROR:|Cannot open|does not exist' "$LOG" 2>/dev/null || true)"
[[ -z "$ERR_COUNT" ]] && ERR_COUNT=0
if [[ "$VALIDATE_RC" -eq 0 ]]; then
  log "Validation : PASS (no script/scene/resource load errors)"
else
  log "Validation : FAIL (see VERIFY_FAIL lines above)"
fi
if [[ -f "$SHOT" ]]; then
  log "Screenshot : OK  -> $SHOT"
else
  log "Screenshot : MISSING (render may have failed; check log above)"
fi
log "Error-ish log lines: $ERR_COUNT"
log "Full log: $LOG"
log "Done."

exit "$VALIDATE_RC"
