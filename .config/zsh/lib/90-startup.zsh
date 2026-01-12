# Commands that should run when a new interactive terminal opens.
#
# Trade-offs:
# - Every command here affects perceived shell startup speed.
# - Guard everything with “command -v” and file checks.

# -----------------------------------------------------------------------------
# SSH agent (systemd user service)
# Goal:
# - Do not start agents from shell startup.
# - If a known socket exists and SSH_AUTH_SOCK is unset, use it.
if [[ -z ${SSH_AUTH_SOCK:-} && -n ${XDG_RUNTIME_DIR:-} ]]; then
    typeset sock="$XDG_RUNTIME_DIR/ssh-agent.socket"
    [[ -S "$sock" ]] && export SSH_AUTH_SOCK="$sock"
    unset sock
fi

# Optional: clear screen on start (opt-in)
if [[ -n ${ZSH_CLEAR_ON_START:-} ]]; then
    clear
fi

# zoxide (smarter cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# uv completions
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
fi

# Optional local env bootstrap (guarded)
[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
