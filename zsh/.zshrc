# =========================================================
#  Zsh config (5.9) - cleaned & stable
# =========================================================

# ---------- Powerlevel10k instant prompt ----------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history

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
#  Powerlevel10k
# =========================================================
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ -f ~/.p10k-colors.zsh ]] && source ~/.p10k-colors.zsh

# =========================================================
#  Completion (do this BEFORE plugins that rely on it)
# =========================================================
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/zcompdump"

# =========================================================
#  Plugins
# =========================================================

# --- Syntax highlighting ---
zinit light zdharma-continuum/fast-syntax-highlighting

# --- Autosuggestions ---
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606060'

# --- fzf-tab (fuzzy tab completion) ---
zinit light Aloxaf/fzf-tab

# --- zsh-autopair (auto-close brackets/quotes) ---
zinit light hlissner/zsh-autopair

# --- history-substring-search ---
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- zsh-completions ---
zinit light zsh-users/zsh-completions

# =========================================================
#  Proxy / aliases (migrated from .bashrc)
# =========================================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias x11='startx'
alias wayland='startplasma-wayland'

alias get_idf='. $HOME/esp/esp-idf/export.sh'


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
    if command git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
      local counts ahead behind
      counts=$(command git rev-list --left-right --count @{u}...HEAD 2>/dev/null) || counts=""

      if [[ -n "$counts" ]]; then
        IFS=$' \t' read -r behind ahead <<< "$counts"

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
alias shot='maim "$SCREENSHOT_DIR/$(date +%Y%m%d_%H%M%S).png"'
alias shotw='maim -s "$SCREENSHOT_DIR/$(date +%Y%m%d_%H%M%S)_sel.png"'

# =========================================================
#  fzf (if installed system-wide)
# =========================================================
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh   ]] && source /usr/share/fzf/completion.zsh


# =========================================================
# proxy functions
# =========================================================

function proxy_on() {
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy="http://127.0.0.1:7890"
    export all_proxy="socks5://127.0.0.1:7891"

    echo -e "\033[32m[√] Terminal Proxy is ON (127.0.0.1:7890)\033[0m"
}

function proxy_off() {
    unset http_proxy
    unset https_proxy
    unset all_proxy

    echo -e "\033[31m[x] Terminal Proxy is OFF\033[0m"
}

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
# =========================================================
function setpower() {
    local mode=$1
    local epp_val=""
    local boost_val=""
    local profile_val=""

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

    echo "0. Locking Governor to 'powersave'..."
    echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

    if [[ -f /sys/firmware/acpi/platform_profile ]]; then
        echo "1. Setting ACPI Profile to '$profile_val'..."
        if ! echo "$profile_val" | sudo tee /sys/firmware/acpi/platform_profile > /dev/null 2>&1; then
             echo "   (Note: ACPI profile write skipped)"
        fi
    fi

    echo "2. Setting EPP to '$epp_val'..."
    echo "$epp_val" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference > /dev/null

    echo "3. Setting Boost to '$boost_val'..."
    echo "$boost_val" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null

    echo "4. Injecting TDP Limits..."
    sudo ryzenadj --stapm-limit=$stapm_limit --fast-limit=$fast_limit --slow-limit=$slow_limit --tctl-temp=95 > /dev/null

    echo "Done."
}

# =========================================================
#  Kitty theme switcher
# =========================================================
function ktheme() {
    local themes_dir="$HOME/.config/kitty/themes"
    local current="$themes_dir/current.conf"
    local p10k_dir="$HOME/.config/zsh"

    if [[ -z "$1" ]]; then
        echo "Available themes:"
        for f in "$themes_dir"/*.conf; do
            local name="${f:t:r}"
            [[ "$name" == "current" ]] && continue
            if diff -q "$f" "$current" >/dev/null 2>&1; then
                echo " * $name (active)"
            else
                echo "   $name"
            fi
        done
        echo "Usage: ktheme <name>"
        return 0
    fi

    local target="$themes_dir/${1}.conf"
    if [[ ! -f "$target" ]]; then
        echo "Theme '$1' not found in $themes_dir"
        return 1
    fi

    cp "$target" "$current"

    # Sync p10k colors
    local p10k_theme="$p10k_dir/p10k-colors-${1}.zsh"
    if [[ -f "$p10k_theme" ]]; then
        cp "$p10k_theme" "$HOME/.p10k-colors.zsh"
    fi

    # Sync fzf colors
    case "$1" in
        catppuccin-mocha)
            export FZF_DEFAULT_OPTS='--color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa --color=fg+:#cdd6f4,bg+:#313244,hl+:#89b4fa --color=info:#f9e2af,prompt:#cba6f7,pointer:#89b4fa --color=marker:#a6e3a1,spinner:#f38ba8,header:#585b70'
            ;;
        tokyo-night)
            export FZF_DEFAULT_OPTS='--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7 --color=fg+:#c0caf5,bg+:#24283b,hl+:#7aa2f7 --color=info:#e0af68,prompt:#bb9af7,pointer:#7aa2f7 --color=marker:#9ece6a,spinner:#f7768e,header:#414868'
            ;;
        gruvbox-dark)
            export FZF_DEFAULT_OPTS='--color=fg:#ebdbb2,bg:#282828,hl:#83a598 --color=fg+:#ebdbb2,bg+:#3c3836,hl+:#83a598 --color=info:#fabd2f,prompt:#d3869b,pointer:#83a598 --color=marker:#b8bb26,spinner:#fb4934,header:#928374'
            ;;
        current)
            export FZF_DEFAULT_OPTS='--color=fg:#D0D0D0,bg:#1C232B,hl:#56CCF2 --color=fg+:#FFFFFF,bg+:#2D3748,hl+:#56CCF2 --color=info:#F2C94C,prompt:#9B51E0,pointer:#56CCF2 --color=marker:#27AE60,spinner:#EB5757,header:#606060'
            ;;
    esac

    # Reload kitty config (SIGUSR1)
    local kitty_pid
    kitty_pid=$(pgrep -f "kitty.*--listen" | head -1)
    if [[ -z "$kitty_pid" ]]; then
        kitty_pid=$(pgrep -x kitty | head -1)
    fi
    if [[ -n "$kitty_pid" ]]; then
        kill -SIGUSR1 "$kitty_pid" 2>/dev/null
    fi

    echo "Switched to: $1"
}

# >>> conda initialize >>>
__conda_setup="$('/home/nina/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nina/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/nina/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/nina/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="$HOME/.local/bin:$PATH"

# OpenFOAM config
autoload bashcompinit
bashcompinit
alias of2512="source ${FOAM_INST_DIR}/OpenFOAM-v2512/etc/bashrc"


[ -f ~/.zshrc.local ] && source ~/.zshrc.local
