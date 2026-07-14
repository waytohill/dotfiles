#!/bin/bash

# --- 1. 获取电源状态 ---
ac_online=0
# 遍历查找 online 文件，兼容各种型号
for supply in /sys/class/power_supply/*/online; do
    if [ -f "$supply" ] && [ "$(cat "$supply")" -eq 1 ]; then
        ac_online=1
        break
    fi
done

# --- 2. 获取电池数据 ---
if [ ! -f /sys/class/power_supply/BAT0/capacity ]; then
    echo "No Bat"
    exit 0
fi
cap=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

# --- 3. 定义颜色 (Nord/Dracula 扩展) ---
C_CRIT="^c#BF616A^"   # < 15% 红色
C_WARN="^c#D08770^"   # < 30% 橙色
C_MID="^c#EBCB8B^"    # < 50% 黄色
C_GOOD="^c#A3BE8C^"   # < 75% 绿色
C_FULL="^c#8BE9FD^"   # > 75% 冰蓝/青色

C_BG_BAR="^c#3B4252^" # 进度条底槽颜色 (深灰，比黑色浅一点)
RESET="^d^"

ICON_CHG="CHG"   # charging
ICON_PLUG="PLUG" # plugged
ICON_BAT="BAT"   # battery

# --- 4. 核心逻辑 ---

# A. 确定颜色
if [ "$cap" -le 15 ]; then color="$C_CRIT"
elif [ "$cap" -le 30 ]; then color="$C_WARN"
elif [ "$cap" -le 50 ]; then color="$C_MID"
elif [ "$cap" -le 75 ]; then color="$C_GOOD"
else color="$C_FULL"; fi

# B. 格式化数字字符串
# 关键步骤：使用 printf "%4s" 强行把数字补齐到 4 个字符宽 (例如 " 80%" 或 "100%")
# 这样我们才能确定要往回退多少像素。
# 假设字体宽度下，4个字符大约占用 32px (根据你的 Source Code Pro size=10 估算)
text_str=$(printf "%4s%%" "$cap")
total_width=45  # 这是整个进度条的像素宽度，需要根据你的字体微调
bar_height=2    # 进度条高度 (2px 很精致)
y_offset=25     # Y轴偏移 (向下移动16px，使其位于文字底部)

start_x=$(( -total_width - 0 ))

# C. 计算进度条像素宽度
# fill_width = cap * total_width / 100
fill_width=$(( cap * total_width / 100))
if [ "$fill_width" -lt 1 ]; then fill_width=1; fi

# D. 构造绘图指令 (魔法所在)
# 逻辑：
# 1. ^r-32,16,32,2^  -> 往回退32px，下移16px，画一个32px宽的深灰色背景槽
# 2. ^r-32,16,W,2^   -> 再次往回退32px，下移16px，画一个 W px宽的彩色进度条

# 注意：status2d 的 rect 指令通常是相对当前位置。
# 如果先画背景槽，光标可能不会动(取决于补丁版本)，也可能动。
# 最稳妥的方法是：画完背景槽后，手动让绘图指令再回退一次。

# [指令1: 背景槽] X偏移 = -total_width
draw_bg="${C_BG_BAR}^r${start_x},${y_offset},${total_width},${bar_height}^"

# [指令2: 进度条] X偏移 = -total_width (因为我们要从头覆盖)
draw_fg="${color}^r${start_x},${y_offset},${fill_width},${bar_height}^"


# --- 5. 最终输出 ---

if [ "$ac_online" -eq 1 ]; then
    # === 接电状态 ===
    # 接电时，我们用黄色或绿色显示文字，但也保留下划线，表示“充能中”
    
    if [[ "$status" == *"harging"* ]] && [[ "$status" != "Not charging" ]]; then
         # 充电：黄色文字 + 黄色进度条
         draw_fg="${C_MID}^r${start_x},${y_offset},${fill_width},${bar_height}^"
         echo "${C_MID}${ICON_CHG}${text_str}${draw_bg}${draw_fg}${RESET}"
    else
         # 满电/未充：绿色文字 + 绿色全满条
         draw_fg="${C_GOOD}^r${start_x},${y_offset},${fill_width},${bar_height}^"
         echo "${C_GOOD}${ICON_PLUG}${text_str}${draw_bg}${draw_fg}${RESET}"
    fi
else
    # === 电池供电 ===
    # 图标 + 文字 + (回退画底槽) + (回退画进度条)
    
    echo "${color}${ICON_BAT}${text_str}${draw_bg}${draw_fg}${RESET}"
fi
