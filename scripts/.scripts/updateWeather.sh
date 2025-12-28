#!/bin/sh
while true; do
    WEATHER=$(curl -s --max-time 10 --retry 2 'wttr.in/Dalian?format=%c+%t+%l')

# 只有当获取到的内容不为空，且不包含 "Unknown" 或 HTML 标签时，才更新缓存
if [ -n "$WEATHER" ] && [[ "$WEATHER" != *"Unknown"* ]] && [[ "$WEATHER" != *"<"* ]]; then
    # 可选：用 sed 去掉加号，美化输出
    echo "$WEATHER" > /tmp/weather_cache
fi
    sleep 3600
done
