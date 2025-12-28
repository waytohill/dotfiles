#!/bin/sh

# === 配置区域 ===
# 将这里换成你实际的网卡名称
LAN_IF="lo"
WIFI_IF="wlp2s0"

# === 逻辑区域 ===

# 1. 检查有线网卡状态
# /sys/class/net/.../operstate 文件里存着 "up" 或 "down"
if grep -q "up" "/sys/class/net/$LAN_IF/operstate" 2>/dev/null; then
    # 如果有线连接，输出：图标 + "Eth"
    # 颜色：蓝色 (#56CCF2)
    echo "^c#56CCF2^Eth^c#585858^"

# 2. 如果有线没连，检查无线网卡状态
elif grep -q "up" "/sys/class/net/$WIFI_IF/operstate" 2>/dev/null; then
    # 尝试获取 WiFi 名称 (SSID)
    # 如果你没装 iwgetid，可以用 nmcli 或直接显示 "WiFi"
    SSID=$(iwgetid -r)
    if [ -z "$SSID" ]; then
        SSID="WiFi"
    fi
    # 如果无线连接，输出：图标 + SSID
    # 颜色：淡紫色 (#B799FF)
    echo "$SSID"

# 3. 都没有连接
else
    # 颜色：红色 (#EB5757)
    echo "n/a"
fi
