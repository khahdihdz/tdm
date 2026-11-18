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

Features: aria2 segmented downloads (up to 16 connections per server), resumable transfers, faster yt-dlp fragment downloads (8 concurrent fragments), batch URL lists, queue, history, file listing, settings, VI/EN interface. Actual speed depends on the source server, network, and device.

GitHub Pages hosts the bilingual project website only. The actual download manager runs locally on Android inside Termux.

License: MIT.
