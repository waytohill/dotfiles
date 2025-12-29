#!/bin/bash

# --- 1. 获取 RAM ---
load=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)

# --- 2. 颜色定义 ---
C_IDLE="^c#88C0D0^"
C_WORK="^c#81A1C1^"
C_BUSY="^c#B48EAD^"
C_CRIT="^c#BF616A^"
C_BG_BAR="^c#3B4252^"
RESET="^d^"

# --- 3. 颜文字逻辑 (手动视觉对齐版) ---
# 这里的关键是：我在短的颜文字里直接加了空格，让它们看起来一样长
if [ "$load" -lt 10 ]; then
    color=$C_IDLE
    face="( ´∀\`)"  # 手动补宽
elif [ "$load" -lt 40 ]; then
    color=$C_WORK
    face="(*´∀\`)"  # 手动补宽
elif [ "$load" -lt 80 ]; then
    color=$C_BUSY
    face="(\`ε´ )"
else
    color=$C_CRIT
    face="( \`д´)"
fi

# --- 4. 绘图与居中控制 ---

# bar_width: 进度条的像素宽度
# 建议：设为比文字总宽度稍微短一点点，看起来更精致
bar_width=55

# text_pixel_width: 估算的文字总像素宽度
# 取决于字体大小。Source Code Pro 10pt 下，8个字符大约是 60-64px
# 这里的数字越大，进度条就会越往左偏；数字越小，进度条越往右偏。
# **通过修改这个数字来控制左右居中！**
text_pixel_width=72

bar_height=3
y_offset=25

# 计算填充长度
fill_width=$(( load * bar_width / 100 ))
if [ "$fill_width" -lt 1 ]; then fill_width=1; fi

# --- 5. 居中计算公式 ---
# 逻辑：
# 1. 光标现在在文字最右边。
# 2. 我们需要往回退 (TextWidth/2 + BarWidth/2) 的距离，才能让条的左边对齐。
#    或者更简单：退回 (TextWidth) 回到开头，再向右移 (TextWidth - BarWidth) / 2
# 
# 简化公式： 回退距离 = TextWidth - (TextWidth - BarWidth) / 2
#           = (TextWidth + BarWidth) / 2

offset=$(( (text_pixel_width + bar_width) / 2 ))
x_pos=-${offset}

draw_bg="${C_BG_BAR}^r${x_pos},${y_offset},${bar_width},${bar_height}^"
draw_fg="${color}^r${x_pos},${y_offset},${fill_width},${bar_height}^"

# --- 6. 输出 ---
# 使用 printf 强行占位 8 个字符，保证下一个模块不贴上来
echo "RAM${color}$(printf "%s" "$face")${draw_bg}${draw_fg}${RESET}"
