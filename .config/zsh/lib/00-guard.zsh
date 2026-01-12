# Early interactive guard + shared vars.
#
# Purpose:
# - Provide stable paths for the rest of the modules.
# - Load local-only overrides early (secrets, per-machine tweaks).

ZSHDIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
plugin_dir="$ZSHDIR/plugins"
alias_dir="$ZSHDIR/aliases"

# Local-only overrides (NOT versioned)
[[ -r "$HOME/.config/dotfiles-local/local.zsh" ]] && source "$HOME/.config/dotfiles-local/local.zsh"
