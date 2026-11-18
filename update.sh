#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
APP="$HOME/.local/share/tdm"
if [ -d "$APP/.git" ]; then git -C "$APP" pull --ff-only; else tmp="$(mktemp -d)"; git clone --depth 1 https://github.com/khahdihdz/tdm.git "$tmp/tdm"; cp -R "$tmp/tdm/." "$APP/"; rm -rf "$tmp"; fi
chmod +x "$APP/tdm" "$APP/update.sh" "$APP/uninstall.sh"
echo "TDM updated."
