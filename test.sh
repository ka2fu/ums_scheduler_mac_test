#!/usr/bin/env bash
set -euo pipefail

# ── plistにパスを注入 ───────────────────────────────────────────────
SCRIPT_PATH="$HOME/umsr-automation-scheduler-scripts/open_chrome.sh"
TEMPLATE="launchd/umsr-automation-scheduler.open-chrome.plist.template"
DEST=~/Library/LaunchAgents/umsr-automation-scheduler.open-chrome.plist

# オープンスクリプトを配置
mkdir -p ~/umsr-automation-scheduler-scripts
cp scripts/open_chrome.sh ~/umsr-automation-scheduler-scripts/open_chrome.sh
chmod +x ~/umsr-automation-scheduler-scripts/open_chrome.sh

# launchddをロード
mkdir -p ~/Library/LaunchAgents
sed "s|__SCRIPT_PATH__|$SCRIPT_PATH|g" "$TEMPLATE" > "$DEST"
# launchctl unload "$DEST" 2>/dev/null || true
# launchctl load   "$DEST"
launchctl bootout gui/$(id -u) "$DEST" 2>/dev/null
launchctl bootstrap gui/$(id -u) "$DEST"


echo "LaunchAgent をインストールしました: $DEST"
# ───────────────────────────────────────────────────────────────