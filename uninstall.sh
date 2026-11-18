#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
rm -f "$PREFIX/bin/tdm"
rm -rf "$HOME/.local/share/tdm"
read -r -p "Also remove settings? [y/N] " a
[[ "$a" =~ ^[Yy]$ ]] && rm -rf "$HOME/.config/tdm"
echo "TDM removed. Downloaded files are preserved."
