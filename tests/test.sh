#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for f in tdm install.sh update.sh uninstall.sh; do bash -n "$ROOT/$f"; done
test -s "$ROOT/locales/vi.sh"
test -s "$ROOT/locales/en.sh"
grep -q aria2c "$ROOT/tdm"
echo "TDM tests passed."
