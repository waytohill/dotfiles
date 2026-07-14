#!/bin/sh
while true; do
    WEATHER=$(curl -s --max-time 10 --retry 2 'wttr.in/Zouping?format=%c+%t&m')

# 只有当获取到的内容不为空，且不包含 "Unknown" 或 HTML 标签时，才更新缓存
if [ -n "$WEATHER" ] && [[ "$WEATHER" != *"Unknown"* ]] && [[ "$WEATHER" != *"<"* ]]; then
    # 可选：用 sed 去掉加号，美化输出
    WEATHER=$(echo "$WEATHER" | sed 's/\(.\)  */\1 /')
    # 移除 emoji 变体选择器 U+FE0F，避免 dwm 状态栏显示异常
    WEATHER=$(echo "$WEATHER" | sed 's/\xef\xb8\x8f//g')
    echo "$WEATHER" > /tmp/weather_cache
fi
    sleep 3600
done
