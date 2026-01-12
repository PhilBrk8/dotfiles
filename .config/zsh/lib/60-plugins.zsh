# Plugin loading (small, explicit, guarded).
#
# Trade-offs:
# - Plugins cost startup time. Keep the list short and guard missing files.

# Colors / UX
[[ -r "$plugin_dir/256color.zsh" ]] && source "$plugin_dir/256color.zsh"

# Autosuggestions (now safe because we autoloaded is-at-least in 40-functions)
if [[ -r "$plugin_dir/autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$plugin_dir/autosuggestions/zsh-autosuggestions.zsh"
fi

# Web search helpers
[[ -r "$plugin_dir/web_search.plugin.zsh" ]] && source "$plugin_dir/web_search.plugin.zsh"

# fzf plugin (your own)
[[ -r "$plugin_dir/fzf_plugin.zsh" ]] && source "$plugin_dir/fzf_plugin.zsh"

# -----------------------------------------------------------------------------
# Syntax highlighting (MUST be loaded last)
#
# Why:
# - zsh-syntax-highlighting wraps ZLE widgets and should come after other plugins.
# - The Catppuccin theme file only has an effect if the plugin is loaded.
# -----------------------------------------------------------------------------

# Plugin core (recommended as git submodule: plugins/zsh-syntax-highlighting)
if [[ -r "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # Theme (only meaningful if the plugin core is loaded)
    [[ -r "$plugin_dir/catppuccin_mocha-zsh-syntax-highlighting.zsh" ]] &&
        source "$plugin_dir/catppuccin_mocha-zsh-syntax-highlighting.zsh"
else
    # Optional: If you want a hint when the submodule is missing, uncomment:
    # [[ -n ${ZSH_DEBUG_STARTUP:-} ]] && print "missing: zsh-syntax-highlighting"
    :
fi
