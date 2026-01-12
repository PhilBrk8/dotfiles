# Interactive shell options, history, keybindings.
#
# Trade-offs:
# - These settings are interactive-only on purpose (avoid surprising scripts).

setopt NO_BEEP
setopt HIST_VERIFY
setopt EXTENDED_GLOB

# -----------------------------------------------------------------------------
# History (XDG state dir)
# -----------------------------------------------------------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Ignore noisy commands in history (professional, explicit)
zshaddhistory() {
    emulate -L zsh
    local line="${1%%$'\n'}"
    local cmd="${line%% *}"
    case "$cmd" in
    ls | cd | pwd | exit | history) return 1 ;;
    esac
    return 0
}

# -----------------------------------------------------------------------------
# Keybindings (vi-mode) + cursor shape
# -----------------------------------------------------------------------------
KEYTIMEOUT=1
bindkey -v

# Only emit escape sequences on a real TTY.
_cursor_beam() { [[ -t 1 ]] && print -n -- $'\e[5 q'; }
_cursor_block() { [[ -t 1 ]] && print -n -- $'\e[1 q'; }

zle-keymap-select() {
    case "$KEYMAP" in
    vicmd) _cursor_block ;;
    *) _cursor_beam ;;
    esac
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
    _cursor_beam
}
zle -N zle-line-init

autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd _cursor_beam
add-zsh-hook -Uz preexec _cursor_beam
