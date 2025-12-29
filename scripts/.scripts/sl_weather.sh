#!/bin/bash
# 假设你的 cache 内容是 "Sunny 25°C" 这种格式
# 我们只提取温度数字进行判断
data=$(cat /tmp/weather_cache | tr -d '\n')
temp=$(echo "$data" | grep -oE '[0-9]+' | head -1)

# 天气 Emoji 映射 (根据你的 cache 里的文字关键词，这里是简单示例)
# 你需要在生成 cache 的脚本里就把 emoji 加上，或者在这里 grep 关键词
# 假设 cache 里已经是 "☁️ 25°C" 或纯文字

COLOR_HOT="^c#FF79C6^" # 热
COLOR_COLD="^c#8BE9FD^" # 冷
COLOR_NICE="^c#F1FA8C^" # 适宜

if [ -z "$temp" ]; then
    echo "$data"
elif [ "$temp" -le 15 ]; then
    echo "${COLOR_COLD}${data}^d^"
elif [ "$temp" -ge 30 ]; then
    echo "${COLOR_HOT}${data}^d^"
else
    echo "${COLOR_NICE}${data}^d^"
fi
