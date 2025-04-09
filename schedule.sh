#!/usr/bin/env bash
set -euo pipefail

# デフォルト値
DEFAULT_SLEEP_TIME="23:00:00"
DEFAULT_WAKE_TIME="07:00:00"

# 使用する値
SLEEP_TIME="$DEFAULT_SLEEP_TIME"
WAKE_TIME="$DEFAULT_WAKE_TIME"

# ── ヘルプ表示関数 ─────────────────────────────────────────
usage() {
    cat <<EOF
Usage: [--sleep or -s HH:MM] [--wake or -w HH:MM]

  --sleep HH:MM   スリープ時刻を指定 (デフォルト: $DEFAULT_SLEEP_TIME)
  --wake  HH:MM   ウェイク時刻を指定 (デフォルト: $DEFAULT_WAKE_TIME)
  -h, --help      このヘルプを表示

例:
  $0                             # → sleep 23:00:00, wake 07:00:00
  $0 --sleep 22:30               # → sleep 22:30:00, wake 07:00:00
  $0 --wake 06:45                # → sleep 23:00:00, wake 06:45:00
  $0 --sleep 22:30 --wake 06:45  # → sleep 22:30:00, wake 06:45:00
EOF
    exit 1
}
# ───────────────────────────────────────────────────────────────

# ── 時間のバリデーション関数 ───────────────────────────────────────────────
validate_time() {
    local time="$1"

    # 時間と分に分割
    IFS=':' read -r hour_str minute_str <<< "$time"

    # 値が数字かチェック(1,2桁のもok)
    if [[ ! "$hour_str" =~ ^[0-9]{1,2}$ || ! "$minute_str" =~ ^[0-9]{1,2}$ ]]; then
        echo "時刻の形式が正しくありません。\n（例: 07:05 または 7:05 など）" >&2
        exit 1
    fi

    # 10進数として評価
    local hour=$((10#$hour_str))
    local minute=$((10#$minute_str))

    # 時間の範囲チェック
    if (( hour < 0 || hour > 23 )); then
        echo "時間は 0~23 の範囲で指定してください。" >&2
        exit 1
    fi

    # 分の範囲チェック
    if (( minute < 0 || minute > 59 )); then
        echo "分は 0~59 の範囲で指定してください。" >&2
        exit 1
    fi

    # ゼロ埋め
    printf -v FORMATTED_TIME "%02d:%02d" "$hour" "$minute"

    echo "$FORMATTED_TIME"
}
# ───────────────────────────────────────────────────────────────

# ── 引数パース ───────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --sleep|-s)
            if [[ -n "${2-}" && ! "$2" =~ ^- ]]; then
                validated_value=$(validate_time "$2")
                SLEEP_TIME="${validated_value}:00"
                shift 2
            else 
                echo "エラー: --sleep（または -s）の後には時刻を指定してください" >&2
                usage
            fi
            ;;
        --wake|-w)
            if [[ -n "${2-}" && ! "$2" =~ ^- ]]; then
                validated_value=$(validate_time "$2")
                WAKE_TIME="${validated_value}:00"
                shift 2
            else
                echo "エラー: --wake（または -w）の後には時刻を指定してください" >&2
                usage
            fi
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done
# ───────────────────────────────────────────────────────────────

echo "sleep time = ${SLEEP_TIME}"
echo "wake time = ${WAKE_TIME}"

sudo pmset repeat shutdown MTWRFSU "$SLEEP_TIME" wakeorpoweron MTWRFSU "$WAKE_TIME"

echo "スケジューる成功しました" >&2