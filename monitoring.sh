#!/bin/bash

# Graylogサーバーの情報
GRAYLOG_SERVER="graylog.example.com"
GRAYLOG_PORT=12201

# iostatコマンドの実行間隔（秒）
INTERVAL=5

# iostatコマンドの出力をパースしてGELFフォーマットに変換する関数
convert_to_gelf() {
    local device=$1
    local timestamp=$2
    local utilization=$3

    # GELFフォーマットのJSONを作成
    local json=$(cat <<EOF
{
    "version": "1.1",
    "host": "$(hostname)",
    "short_message": "iostat",
    "timestamp": $timestamp,
    "_device": "$device",
    "_utilization": $utilization
}
EOF
    )

    echo -n "$json" | gzip | nc -w 1 -u $GRAYLOG_SERVER $GRAYLOG_PORT
}

# iostatコマンドの出力をパースしてGraylogサーバーに送信するメインの処理
send_iostat_to_graylog() {
    while true; do
        # iostatコマンドの実行
        iostat_output=$(iostat -c | tail -n +4)
        timestamp=$(date +%s)

        # 各行をパースしてGELFフォーマットに変換し、Graylogサーバーに送信
        while read -r line; do
            device=$(echo "$line" | awk '{print $1}')
            utilization=$(echo "$line" | awk '{print $NF}')
            convert_to_gelf "$device" "$timestamp" "$utilization"
        done <<< "$iostat_output"

        sleep $INTERVAL
    done
}

# メインの処理を実行
send_iostat_to_graylog
