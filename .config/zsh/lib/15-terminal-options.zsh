# -----------------------------------------------------------------------------
# TERMINAL – where to set it, and why here
# -----------------------------------------------------------------------------
# We set $TERMINAL early so anything initialized later (fzf integrations,
# file-manager wrappers, “open in terminal” helpers, plugin hooks) sees a
# stable value. This file runs in interactive shells only; we keep .zshenv
# minimal for non-interactive/script contexts.
#
# What $TERMINAL is used for:
# - A *hint* to shell tools/scripts about which terminal emulator to launch
#   when they need a new terminal window (this does NOT affect GNOME’s own
#   default terminal; that’s controlled by gsettings).
#
# Fallback logic (portable across Fedora/Ubuntu desktops and servers):
# 1) Prefer Ghostty if installed.
# 2) Debian/Ubuntu’s `x-terminal-emulator` (update-alternatives) if present.
# 3) Common GUI emulators: gnome-terminal, kitty, alacritty, wezterm, foot.
# 4) Headless/server fallback: if no GUI terminal exists but `tmux` is
#    available, use `tmux` so scripts can still open an interactive terminal
#    *inside the current SSH session* (new window/pane depending on script).
# 5) Absolute last resort: fall back to `$SHELL` so callers can at least
#    execute commands inline without spawning a new emulator.
#
# Notes:
# - On Fedora/Ubuntu **servers** reached via SSH, there is no GUI terminal to
#   spawn. You already have a terminal (your SSH session). In that case this
#   fallback chooses `tmux` (if installed) or just `$SHELL`, which is sane.
# - If you later install Ghostty on those hosts, it will automatically become
#   the preferred $TERMINAL on next shell startup.
# - GNOME’s “default terminal” for GUI actions is separate; set via:
#     gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
#     gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
#   `$TERMINAL` is only a convention used by CLI tools.
# -----------------------------------------------------------------------------

if [[ -o interactive ]]; then
  if [[ -z ${TERMINAL-} ]]; then
    # GUI-preferred candidates
    for cand in ghostty x-terminal-emulator gnome-terminal kitty alacritty wezterm foot; do
      if command -v "$cand" >/dev/null 2>&1; then
        export TERMINAL="$cand"
        break
      fi
    done
    # Headless/server fallback: keep scripts working over SSH
    if [[ -z ${TERMINAL-} ]] && command -v tmux >/dev/null 2>&1; then
      export TERMINAL=tmux
    fi
    # Last resort: use the current shell
    if [[ -z ${TERMINAL-} ]]; then
      export TERMINAL="${SHELL:-/bin/sh}"
    fi
  fi
fi
