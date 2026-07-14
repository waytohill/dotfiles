#!/bin/sh
# Toggle trayer window visibility with auto-hide timeout.
# Requires: xdo

STATE_FILE="/tmp/trayer_hidden"
PID_FILE="/tmp/trayer_autohide.pid"

# 自动隐藏超时时间（秒）：120 = 2分钟，300 = 5分钟
AUTO_HIDE_SECONDS=120

WIN=$(xdo id -N trayer 2>/dev/null | head -n1)
[ -z "$WIN" ] && WIN=$(xdo id -n trayer 2>/dev/null | head -n1)
[ -z "$WIN" ] && WIN=$(xdo id -c trayer 2>/dev/null | head -n1)

kill_autohide_timer() {
	if [ -f "$PID_FILE" ]; then
		pid=$(cat "$PID_FILE")
		kill "$pid" 2>/dev/null
		rm -f "$PID_FILE"
	fi
}

start_autohide_timer() {
	kill_autohide_timer
	(
		sleep "$AUTO_HIDE_SECONDS"
		# 如果窗口仍显示，则自动隐藏
		if [ ! -f "$STATE_FILE" ]; then
			xdo hide "$WIN" 2>/dev/null && touch "$STATE_FILE"
		fi
		rm -f "$PID_FILE"
	) &
	echo $! > "$PID_FILE"
}

if [ -z "$WIN" ]; then
	# trayer 未运行；启动并显示
	TRAYER_HEIGHT=32
	TRAYER_DISTANCE=24
	trayer --edge top --align right --SetDockType true --SetPartialStrut false \
	    --expand true --widthtype request --heighttype pixel --height "$TRAYER_HEIGHT" \
	    --distance "$TRAYER_DISTANCE" --distancefrom top \
	    --transparent true --alpha 0 --tint 0x272e33 --margin 10 --iconspacing 6 &
	rm -f "$STATE_FILE"

	# 等待窗口创建完成，然后显示并启动自动隐藏计时器
	(
		sleep 1
		WIN=$(xdo id -N trayer 2>/dev/null | head -n1)
		[ -z "$WIN" ] && WIN=$(xdo id -n trayer 2>/dev/null | head -n1)
		[ -z "$WIN" ] && WIN=$(xdo id -c trayer 2>/dev/null | head -n1)
		[ -n "$WIN" ] && xdo show "$WIN" && start_autohide_timer
	) &
	exit 0
fi

if [ -f "$STATE_FILE" ]; then
	# 当前隐藏 -> 显示
	xdo show "$WIN"
	rm -f "$STATE_FILE"
	start_autohide_timer
else
	# 当前显示 -> 隐藏
	xdo hide "$WIN"
	touch "$STATE_FILE"
	kill_autohide_timer
fi
