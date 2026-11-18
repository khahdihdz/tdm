#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
[ -n "$PREFIX" ] && command -v pkg >/dev/null 2>&1 || { echo "Run inside Termux."; exit 1; }
pkg update -y
pkg install -y bash curl wget aria2 git
APP="$HOME/.local/share/tdm"
mkdir -p "$APP" "$HOME/.config/tdm" "$HOME/downloads"
if [ -f tdm ]; then cp -R . "$APP/"; else git clone --depth 1 https://github.com/khahdihdz/tdm.git "$APP"; fi
chmod +x "$APP/tdm" "$APP/update.sh" "$APP/uninstall.sh"
cat > "$PREFIX/bin/tdm" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
exec "$HOME/.local/share/tdm/tdm" "$@"
EOF
chmod 755 "$PREFIX/bin/tdm"
[ -f "$HOME/.config/tdm/config" ] || printf 'LANG=vi\nDOWNLOAD_DIR=%s\nSPLIT=8\nRETRIES=5\n' "$HOME/downloads" > "$HOME/.config/tdm/config"
echo "TDM installed. Run: tdm"
echo "If needed, run: termux-setup-storage"
