#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO="https://github.com/khahdihdz/tdm.git"
BRANCH="main"
APP="$HOME/.local/share/tdm"
CFG="$HOME/.config/tdm/config"
BACKUP_ROOT="$HOME/.local/share/tdm-backups"
LANG_CODE="vi"
[[ -f "$CFG" ]] && while IFS='=' read -r key value; do
  [[ "$key" == "LANG" ]] && LANG_CODE="$value"
done < "$CFG"

msg() {
  if [[ "$LANG_CODE" == "en" ]]; then printf '%s\n' "$2"; else printf '%s\n' "$1"; fi
}

pause() { read -r -p "$( [[ "$LANG_CODE" == "en" ]] && echo 'Press Enter to continue...' || echo 'Nhấn Enter để tiếp tục...' )"; }

latest_commit() {
  git ls-remote "$REPO" "refs/heads/$BRANCH" | awk 'NR==1 {print $1}'
}

installed_commit() {
  if git -C "$APP" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$APP" rev-parse HEAD
  else
    printf '%s' "unknown"
  fi
}

check_update() {
  msg "Đang kiểm tra phiên bản trên GitHub..." "Checking GitHub for updates..."
  command -v git >/dev/null 2>&1 || { msg "Thiếu Git. Hãy chạy: pkg install git" "Git is missing. Run: pkg install git"; return 1; }
  local remote local_sha
  remote="$(latest_commit)"
  [[ -n "$remote" ]] || { msg "Không thể lấy thông tin phiên bản từ GitHub." "Unable to retrieve version information from GitHub."; return 1; }
  local_sha="$(installed_commit)"
  printf '\n'
  msg "Commit mới nhất: $remote" "Latest commit: $remote"
  msg "Commit đang cài: $local_sha" "Installed commit: $local_sha"
  if [[ "$local_sha" == "$remote" ]]; then
    msg "Bạn đang sử dụng phiên bản mới nhất." "You are already using the latest version."
  elif [[ "$local_sha" == "unknown" ]]; then
    msg "Không xác định được phiên bản hiện tại; có thể cài bản mới để đồng bộ." "Installed version is unknown; reinstalling the latest copy will synchronize it."
  else
    msg "Có bản cập nhật mới." "An update is available."
  fi
}

perform_update() {
  command -v git >/dev/null 2>&1 || { msg "Thiếu Git. Hãy chạy: pkg install git" "Git is missing. Run: pkg install git"; return 1; }
  local remote current tmp stage backup previous
  remote="$(latest_commit)"
  [[ -n "$remote" ]] || { msg "Không thể kết nối GitHub hoặc không lấy được phiên bản." "Cannot reach GitHub or retrieve the latest version."; return 1; }
  current="$(installed_commit)"
  if [[ "$current" == "$remote" ]]; then
    msg "TDM đã ở phiên bản mới nhất, không cần cập nhật." "TDM is already up to date."
    return 0
  fi

  printf '\n'
  msg "Phiên bản mới: $remote" "New version: $remote"
  read -r -p "$( [[ "$LANG_CODE" == "en" ]] && echo 'Proceed with update? [y/N] ' || echo 'Tiến hành cập nhật? [y/N] ' )" answer
  [[ "$answer" =~ ^[Yy]$ ]] || { msg "Đã hủy cập nhật." "Update cancelled."; return 0; }

  mkdir -p "$BACKUP_ROOT" "$(dirname "$APP")"
  tmp="$(mktemp -d "$HOME/.local/share/tdm-update.XXXXXX")"
  stage="$tmp/tdm"
  previous="$tmp/previous"
  backup="$BACKUP_ROOT/tdm-$(date +%Y%m%d-%H%M%S)"
  trap 'if [[ -d "$previous" && ! -e "$APP" ]]; then mv "$previous" "$APP"; fi; rm -rf "$tmp"' RETURN

  msg "Đang tải bản cập nhật..." "Downloading update..."
  if ! git clone --quiet --depth 1 --branch "$BRANCH" "$REPO" "$stage"; then
    msg "Tải bản cập nhật thất bại. Không thay đổi bản đang cài." "Download failed. The installed copy was not changed."
    return 1
  fi

  for file in tdm install.sh update.sh uninstall.sh; do
    [[ -s "$stage/$file" ]] || { msg "Gói cập nhật thiếu tệp bắt buộc: $file" "Update package is missing required file: $file"; return 1; }
  done
  for file in "$stage"/*.sh "$stage"/tdm; do
    bash -n "$file" || { msg "Phát hiện lỗi cú pháp trong $file. Đã dừng cập nhật." "Syntax error in $file. Update stopped."; return 1; }
  done

  msg "Đang sao lưu bản hiện tại..." "Backing up current installation..."
  cp -a "$APP" "$backup"
  chmod +x "$stage/tdm" "$stage/update.sh" "$stage/uninstall.sh" "$stage/install.sh"

  msg "Đang thay thế chương trình..." "Installing update..."
  mv "$APP" "$previous"
  if ! mv "$stage" "$APP"; then
    mv "$previous" "$APP"
    msg "Không thể cài bản mới. Đã khôi phục bản cũ." "Could not install update. Previous version restored."
    return 1
  fi

  rm -rf "$previous"
  trap - RETURN
  rm -rf "$tmp"
  msg "Cập nhật thành công!" "Update completed successfully!"
  msg "Bản sao lưu được giữ tại:" "Backup saved at:"
  printf '%s\n' "$backup"
  msg "Cấu hình và các tệp đã tải xuống được giữ nguyên." "Settings and downloaded files were preserved."
}

restore_backup() {
  [[ -d "$BACKUP_ROOT" ]] || { msg "Chưa có bản sao lưu." "No backups found."; return 1; }
  local backup
  backup="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -name 'tdm-*' | sort | tail -n 1)"
  [[ -n "$backup" ]] || { msg "Chưa có bản sao lưu." "No backups found."; return 1; }
  printf '\n'
  msg "Bản sao lưu mới nhất:" "Latest backup:"
  printf '%s\n' "$backup"
  read -r -p "$( [[ "$LANG_CODE" == "en" ]] && echo 'Restore this backup? [y/N] ' || echo 'Khôi phục bản sao lưu này? [y/N] ' )" answer
  [[ "$answer" =~ ^[Yy]$ ]] || { msg "Đã hủy khôi phục." "Restore cancelled."; return 0; }

  local tmp="$HOME/.local/share/tdm-restore.$$"
  rm -rf "$tmp"
  cp -a "$backup" "$tmp"
  [[ -s "$tmp/tdm" && -s "$tmp/update.sh" ]] || { rm -rf "$tmp"; msg "Bản sao lưu không hợp lệ." "Backup is invalid."; return 1; }
  local safety="$BACKUP_ROOT/pre-restore-$(date +%Y%m%d-%H%M%S)"
  cp -a "$APP" "$safety"
  rm -rf "$APP"
  mv "$tmp" "$APP"
  chmod +x "$APP/tdm" "$APP/update.sh" "$APP/uninstall.sh"
  msg "Đã khôi phục bản sao lưu." "Backup restored."
  msg "Bản hiện tại trước khi khôi phục được lưu tại:" "Previous installation saved at:"
  printf '%s\n' "$safety"
}

while true; do
  printf '\n'
  msg "========== TDM - CẬP NHẬT ==========" "========== TDM - UPDATER =========="
  msg "1) Kiểm tra cập nhật" "1) Check for updates"
  msg "2) Cập nhật ngay" "2) Update now"
  msg "3) Khôi phục bản sao lưu gần nhất" "3) Restore latest backup"
  msg "0) Quay lại menu chính" "0) Back to main menu"
  read -r -p "> " choice
  case "$choice" in
    1) check_update; pause ;;
    2) perform_update; pause ;;
    3) restore_backup; pause ;;
    0) exit 0 ;;
    *) msg "Lựa chọn không hợp lệ." "Invalid choice."; sleep 1 ;;
  esac
done
