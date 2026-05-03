#!/bin/bash

# ============================================================
#  a5_to_a4_landscape.sh
#  Combines two A5 PDFs side by side on a single A4 landscape page.
#  Dependencies: pdfjam (texlive-extra-utils)
# ============================================================

set -eo pipefail

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ok()   { echo -e "${GREEN}✔ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
err()  { echo -e "${RED}✘ $1${NC}"; }

echo ""
echo -e "${GREEN}"
cat << 'EOF'
 ░██████     ░███    ░████████    ░██                  ░███       ░████   
░██   ░██   ░██░██   ░██          ░██                 ░██░██     ░██ ██   
      ░██  ░██  ░██  ░███████  ░████████  ░███████   ░██  ░██   ░██  ██   
  ░█████  ░█████████       ░██    ░██    ░██    ░██ ░█████████ ░██   ██   
 ░██      ░██    ░██ ░██   ░██    ░██    ░██    ░██ ░██    ░██ ░█████████ 
░██       ░██    ░██ ░██   ░██    ░██    ░██    ░██ ░██    ░██      ░██   
░████████ ░██    ░██  ░██████      ░████  ░███████  ░██    ░██      ░██   
EOF
echo -e "${NC}"

# ── Dependency check ─────────────────────────────────────────
if command -v pdfjam &>/dev/null; then
    ok "pdfjam found"
else
    err "pdfjam not found."
    echo ""
    echo "Install it with:"
    echo "    sudo apt install texlive-extra-utils"
    echo ""
    exit 1
fi

echo ""

# Strip surrounding quotes and unescape spaces (from drag & drop)
clean_path() {
    local p="$1"
    p="${p/#\~/$HOME}"           # expand ~
    p="${p#\'}" ; p="${p%\'}"    # strip surrounding single quotes
    p="${p#\"}" ; p="${p%\"}"    # strip surrounding double quotes
    p="${p//\\ / }"              # unescape backslash-spaces (drag & drop on some terminals)
    echo "$p"
}

# ── Input: File 1 ─────────────────────────────────────────────
while true; do
    read -rp "Enter path to first A5 PDF:  " FILE1
    FILE1=$(clean_path "$FILE1")
    if [[ -f "$FILE1" ]]; then
        ok "File 1: $FILE1"
        break
    else
        err "File not found: $FILE1"
    fi
done

# ── Input: File 2 ─────────────────────────────────────────────
while true; do
    read -rp "Enter path to second A5 PDF (or press Enter to reuse first): " FILE2
    FILE2=$(clean_path "$FILE2")
    if [[ -z "$FILE2" ]]; then
        FILE2="$FILE1"
        warn "No second file provided — using first file twice"
        break
    elif [[ -f "$FILE2" ]]; then
        ok "File 2: $FILE2"
        break
    else
        err "File not found: $FILE2"
    fi
done

# ── Input: Output file ────────────────────────────────────────
read -rp "Enter output file name [output_A4_landscape.pdf]: " OUTPUT
OUTPUT="${OUTPUT/#\~/$HOME}"
OUTPUT="${OUTPUT:-output_A4_landscape.pdf}"

# Add .pdf extension if missing
[[ "$OUTPUT" != *.pdf ]] && OUTPUT="${OUTPUT}.pdf"

# ── Check if output already exists ───────────────────────────
while [[ -f "$OUTPUT" ]]; do
    warn "File already exists: $OUTPUT"
    read -rp "Overwrite? [y/n] or enter a new name: " ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
        break
    elif [[ -z "$ANSWER" || "$ANSWER" =~ ^[Nn]$ ]]; then
        read -rp "Enter a new output file name: " OUTPUT
        OUTPUT="${OUTPUT/#\~/$HOME}"
        [[ "$OUTPUT" != *.pdf ]] && OUTPUT="${OUTPUT}.pdf"
    else
        OUTPUT=$(clean_path "$ANSWER")
        [[ "$OUTPUT" != *.pdf ]] && OUTPUT="${OUTPUT}.pdf"
    fi
done

# ── Run ───────────────────────────────────────────────────────
LOGFILE=$(mktemp)
if pdfjam --nup 2x1 --landscape --paper a4paper \
    "$FILE1" "$FILE2" --outfile "$OUTPUT" &>"$LOGFILE"; then
    ok "Done! Output saved to: $(realpath "$OUTPUT")"
else
    err "pdfjam failed. Full log:"
    echo ""
    cat "$LOGFILE"
fi
rm -f "$LOGFILE"
