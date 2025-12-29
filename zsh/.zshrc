# =========================================================
#  Zsh config (5.9) - cleaned & stable
# =========================================================

# ---------- Prompt expansion ----------
setopt PROMPT_SUBST

# ---------- Basics ----------
export EDITOR=nvim
export PAGER=less
export TERMINAL=st

export SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# ---------- History ----------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt share_history

# =========================================================
#  Zinit (load ONCE)
# =========================================================
ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"

if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  print -P "%F{33}%F{220}Installing zinit...%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Annexes (required by some zinit features)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# =========================================================
#  Completion (do this BEFORE plugins that rely on it)
# =========================================================
autoload -Uz compinit
# 使用缓存，减少启动开销
compinit -d "$HOME/.cache/zsh/zcompdump"

# =========================================================
#  Plugins (IMPORTANT: choose ONE syntax highlighter)
# =========================================================

# --- Syntax highlighting (pick ONE) ---
# 推荐：fast-syntax-highlighting（更快、zinit 生态更稳）
zinit light zdharma-continuum/fast-syntax-highlighting

# Autosuggestions
zinit light zsh-users/zsh-autosuggestions
# 建议字颜色（你原来灰色理念）
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606060'

# =========================================================
#  Proxy / aliases (migrated from .bashrc)
# =========================================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'

export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890"

# =========================================================
#  vcs_info (git info)
# =========================================================
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{#9B51E0}%b%f %F{#606060}%c%u%f'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '!'

# =========================================================
#  Command timer + computed prompt segments (robust)
# =========================================================
typeset -g timer
typeset -g CMD_TIME=""
typeset -g SSH_SEG=""
typeset -g VENV_SEG=""
typeset -g ROOT_SEG=""
typeset -g GIT_AB_SEG=""

preexec() {
  timer=$EPOCHREALTIME
}

precmd() {
  # ----- timer -----
  if [[ -n "$timer" ]]; then
    local dt
    dt=$(( EPOCHREALTIME - timer ))
    CMD_TIME=$(printf "%.2fs" "$dt")
  else
    CMD_TIME=""
  fi

  # ----- root warning -----
  if (( EUID == 0 )); then
    ROOT_SEG="%F{#EB5757}ROOT%f "
  else
    ROOT_SEG=""
  fi

  # ----- SSH segment -----
  if [[ -n "$SSH_CONNECTION" ]]; then
    SSH_SEG="%F{#F2994A}REMOTE%f "
  else
    SSH_SEG=""
  fi

  # ----- venv segment -----
  if [[ -n "$VIRTUAL_ENV" ]]; then
    VENV_SEG="%F{#9B51E0}(${VIRTUAL_ENV:t})%f "
  else
    VENV_SEG=""
  fi

  # ----- vcs_info (branch + dirty markers) -----
  vcs_info

  # ----- git ahead/behind (relative to upstream) -----
  GIT_AB_SEG=""
  if [[ -n "$vcs_info_msg_0_" ]]; then
    # 只有在 git repo 且有 upstream 时才计算，避免报错/卡顿
    if command git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
      local counts ahead behind
      counts=$(command git rev-list --left-right --count @{u}...HEAD 2>/dev/null) || counts=""

      if [[ -n "$counts" ]]; then
        # 按任意空白分割（空格/Tab都可以）
        IFS=$' \t' read -r behind ahead <<< "$counts"

        # 兜底：确保是整数
        [[ "$behind" == <-> ]] || behind=0
        [[ "$ahead"  == <-> ]] || ahead=0

        (( ahead > 0 || behind > 0 )) && GIT_AB_SEG="%F{#606060}⇡${ahead} ⇣${behind}%f "
      fi
    fi
  fi
}


# =========================================================
#  Prompt
# =========================================================
EXIT_SEG='%(?..%F{#EB5757}✘%?%f )'
JOBS_SEG='%(1j.%F{#606060}⚙%j%f .)'

PROMPT='%F{#606060}[%D{%m-%d %H:%M:%S}]%f '"$EXIT_SEG"'${ROOT_SEG}${SSH_SEG}${VENV_SEG}'\
'%F{#F2D25C}%n%f%F{white}@%f%F{#008043}%m%f %F{#0077C8}%~%f '"$JOBS_SEG"\
'%F{#606060}${CMD_TIME}%f ${vcs_info_msg_0_} ${GIT_AB_SEG}
%F{#56CCF2}> %f'


# =========================================================
#  Aliases
# =========================================================
alias ll='ls -lh --color=auto'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias v='nvim'
alias shot='maim "$SCREENSHOT_DIR/$(date +%Y%m%d_%H%M%).png"'
alias shotw='maim -s "$SCREENSHOT_DIR/$(date +%Y%m%d_%H%M%S)_sel.png"'

# =========================================================
#  fzf (if installed system-wide)
# =========================================================
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh   ]] && source /usr/share/fzf/completion.zsh


# =========================================================
# proxy functions
# =========================================================

# 开启代理
function proxy_on() {
    # 设置 HTTP 和 HTTPS 代理
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    # 设置所有协议代理 (包括 FTP 等)
    export all_proxy="socks5://127.0.0.1:7891"

    echo -e "\033[32m[√] Terminal Proxy is ON (127.0.0.1:7890)\033[0m"
}

# 关闭代理
function proxy_off() {
    unset http_proxy
    unset https_proxy
    unset all_proxy

    echo -e "\033[31m[x] Terminal Proxy is OFF\033[0m"
}

# 进阶：如果你想同时控制 systemd 服务（可选）
# 注意：这就需要 clash 必须配置为服务
function clash_start() {
    systemctl --user start clash
    proxy_on
}

function clash_stop() {
    proxy_off
    systemctl --user stop clash
}
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

eval "$(keychain --eval --quiet id_ed25519)"

# =========================================================
#  Power Control Center (EPP + TDP + Boost)
#  Depends: ryzenadj, sudo
# =========================================================
function setpower() {
    local mode=$1
    local epp_val=""
    local boost_val=""
    local profile_val=""
    
    # 8845HS 功率参数
    local stapm_limit=""
    local fast_limit=""
    local slow_limit=""
    
    if ! command -v ryzenadj &> /dev/null; then
        echo -e "\033[31m[Error]\033[0m 'ryzenadj' not found."
        return 1
    fi

    case $mode in
        p|perf)
            echo -e "\n\033[31m Mode: PERFORMANCE\033[0m"
            epp_val="performance"
            profile_val="performance"
            boost_val="1"
            stapm_limit="54000"
            fast_limit="65000"
            slow_limit="60000"
            ;;
        b|bal)
            echo -e "\n\033[34m  Mode: BALANCE\033[0m"
            epp_val="balance_performance"
            profile_val="balanced"
            boost_val="1"
            stapm_limit="28000"
            fast_limit="35000"
            slow_limit="30000"
            ;;
        s|save)
            echo -e "\n\033[32m Mode: SAVER\033[0m"
            epp_val="power"
            profile_val="low-power"
            boost_val="0"
            stapm_limit="15000"
            fast_limit="18000"
            slow_limit="15000"
            ;;
        stat|status)
            echo -e "\n\033[1;33m--- Current Power State ---\033[0m"
            printf "Governor:   \033[36m%s\033[0m\n" "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
            printf "EPP Hint:   \033[36m%s\033[0m\n" "$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
            if [[ -f /sys/firmware/acpi/platform_profile ]]; then
                printf "ACPI Prof:  \033[36m%s\033[0m\n" "$(cat /sys/firmware/acpi/platform_profile)"
            fi
            printf "Boost:      \033[36m%s\033[0m\n" "$(cat /sys/devices/system/cpu/cpufreq/boost)"
            
            echo -e "\n--- Hardware Limits (ryzenadj) ---"
            sudo ryzenadj -i | grep -E "STAPM LIMIT|PPT LIMIT FAST|PPT LIMIT SLOW" | sed 's/|//g' | sed 's/^ *//'
            
            if [[ -f /sys/class/power_supply/BAT0/power_now ]]; then
                local p_now=$(cat /sys/class/power_supply/BAT0/power_now)
                local p_watt=$(echo "scale=2; $p_now / 1000000" | bc)
                echo -e "\n--- Battery Draw: \033[31m${p_watt} W\033[0m ---"
            fi
            return 0
            ;;
        *)
            echo "Usage: setpower [ p | b | s | stat ]"
            return 1
            ;;
    esac

    echo "-------------------------------------"
    
    # 0. 【关键修复】强制将 Governor 设为 powersave
    # 只有在 powersave 模式下，EPP 才能拥有最高控制权
    echo "0. Locking Governor to 'powersave'..."
    echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

    # 1. 设置 ACPI Platform Profile
    if [[ -f /sys/firmware/acpi/platform_profile ]]; then
        echo "1. Setting ACPI Profile to '$profile_val'..."
        if ! echo "$profile_val" | sudo tee /sys/firmware/acpi/platform_profile > /dev/null 2>&1; then
             echo "   (Note: ACPI profile write skipped)"
        fi
    fi

    # 2. 设置 EPP
    echo "2. Setting EPP to '$epp_val'..."
    echo "$epp_val" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null

    # 3. 设置 Boost
    echo "3. Setting Boost to '$boost_val'..."
    echo "$boost_val" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null

    # 4. 设置 TDP
    echo "4. Injecting TDP Limits..."
    sudo ryzenadj --stapm-limit=$stapm_limit --fast-limit=$fast_limit --slow-limit=$slow_limit --tctl-temp=95 > /dev/null

    echo "Done."
}
