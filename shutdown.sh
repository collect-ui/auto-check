#!/bin/bash

# 配置文件路径
CONFIG_FILE="conf/application.properties"

# 从配置文件中提取所有 server_port 值
SERVER_PORTS=$(grep -Po '(?<=server_port=)\d+' "$CONFIG_FILE")

if [ -z "$SERVER_PORTS" ]; then
    echo "Error: server_port not found in $CONFIG_FILE"
    exit 1
fi

# 将端口值转换为数组
IFS=$'\n' read -d '' -r -a SERVER_PORTS_ARRAY <<< "$SERVER_PORTS"

# 遍历每个端口
for SERVER_PORT in "${SERVER_PORTS_ARRAY[@]}"; do
    echo "Server port found: $SERVER_PORT"

    # 查找使用该端口的进程
    PID=$(lsof -t -i:"$SERVER_PORT" | head -n 1)

    if [ -z "$PID" ]; then
        echo "No process found using port $SERVER_PORT"
        continue
    fi

    echo "Process found with PID: $PID"

    # 终止进程
    kill -9 "$PID"

    if [ $? -eq 0 ]; then
        echo "Process $PID terminated successfully"
    else
        echo "Failed to terminate process $PID"
    fi
done