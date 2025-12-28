#!/bin/bash

# 1. 启动 xss-lock
# 作用：当你合上盖子或手动 systemctl suspend 时，自动调用 slock
# --transfer-sleep-lock 确保在锁屏完成前系统不会挂起
xss-lock --transfer-sleep-lock -- slock &

# 2. 启动 xidlehook (空闲检测)
# 逻辑：
# - 没放声音时：
#   - 5分钟 (300秒) -> 锁屏 (slock)
#   - 10分钟 (600秒) -> 关闭屏幕电源 (xset dpms force off)
#   - 20分钟 (1200秒) -> 系统挂起 (systemctl suspend)
# - 放声音时：不执行任何操作

xidlehook \
  --not-when-audio \
  --not-when-fullscreen \
  --timer 600 \
    'slock' \
    '' \
  --timer 600 \
    'xset dpms force off' \
    'xset dpms force on' \
  --timer 1200 \
    'systemctl suspend' \
    '' &
