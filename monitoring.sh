#!/bin/bash

GRAYLOG_SERVER="36.13.187.28"
GRAYLOG_PORT=1514

# time
INTERVAL=5

# change formate
convert_to_gelf() {
    local device=$1
    local timestamp=$2
    local utilization=$3

    # create json
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

# main
send_iostat_to_graylog() {
    while true; do
        # run iostat
        iostat_output=$(iostat -c | tail -n +4)
        timestamp=$(date +%s)

        # send
        while read -r line; do
            device=$(echo "$line" | awk '{print $1}')
            utilization=$(echo "$line" | awk '{print $NF}')
            convert_to_gelf "$device" "$timestamp" "$utilization"
        done <<< "$iostat_output"

        sleep $INTERVAL
    done
}

# run main
send_iostat_to_graylog
