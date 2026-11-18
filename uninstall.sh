#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

printf '\nTDM - Uninstaller\n'
read -r -p "Are you sure you want to uninstall TDM? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

if [[ -n "${PREFIX:-}" ]]; then
  rm -f "$PREFIX/bin/tdm"
fi
rm -rf "$HOME/.local/share/tdm"

read -r -p "Also remove TDM settings? [y/N] " remove_settings
if [[ "$remove_settings" =~ ^[Yy]$ ]]; then
  rm -rf "$HOME/.config/tdm"
fi

echo "TDM removed. Downloaded files are preserved."
