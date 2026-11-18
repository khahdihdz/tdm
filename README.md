# TDM — Termux Download Manager
Bilingual Vietnamese / English download manager for Termux. No root required.

## One-command install / Cài đặt bằng một lệnh

Open Termux and run:

```bash
pkg update -y && pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/khahdihdz/tdm/main/install.sh | bash
```

TDM tự tạo thư mục tải xuống mặc định tại `~/storage/downloads/tdm` khi cài đặt và mỗi lần khởi chạy. Bạn có thể đổi thư mục trong mục Cài đặt.

After installation, start TDM with:

```bash
tdm
```

## Manual install / Cài đặt thủ công

```bash
pkg update -y && pkg install -y git
git clone https://github.com/khahdihdz/tdm.git
cd tdm && bash install.sh
tdm
```

Features: aria2 segmented downloads (up to 16 connections per server), resumable transfers, batch URL lists, queue, history, file listing, settings, VI/EN interface. Menu 3 integrates the maintained TVDL script for YouTube, Facebook, Instagram, X (Twitter), and Xiaohongshu, including quality selection, playlists, audio-only downloads, video information, and login cookies. TVDL uses the shared TDM download folder on first integration. Actual speed and platform availability depend on the source service, network, and device.

GitHub Pages hosts the bilingual project website only. The actual download manager runs locally on Android inside Termux.

License: MIT.
