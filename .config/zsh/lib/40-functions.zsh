# Function autoloading.
#
# Goals:
# - Autoload zsh helpers (should resolve via fpath from 05-fpath.zsh).
# - Autoload our own "one file = one function" definitions.
# - Avoid collisions with builtins/aliases/reserved words.
#
# Trade-offs:
# - Multi-function files must be sourced explicitly (e.g. dotfiles bundles).
# - Slightly more logic to keep startup predictable.

emulate -L zsh
setopt null_glob

# -----------------------------------------------------------------------------
# Autoload core zsh helpers (now should resolve via fpath)
# -----------------------------------------------------------------------------
builtin autoload -Uz add-zsh-hook is-at-least 2>/dev/null || true

# -----------------------------------------------------------------------------
# Autoload our functions (functions/<category>/<function>)
# -----------------------------------------------------------------------------
local func_file func_name
for func_file in "$ZSHDIR"/functions/*/*(.N); do
    func_name="${func_file:t}"

    # Skip bundles / helpers / historically collision-prone names.
    case "$func_name" in
    dotfiles | path_prepend | autoload) continue ;;
    esac

    # Skip if name already resolves to something meaningful.
    if whence -w "$func_name" 2>/dev/null | grep -qE ': (builtin|reserved|alias|function)'; then
        [[ -n ${ZSH_DEBUG_STARTUP:-} ]] && print "skip collision: $func_name"
        continue
    fi

    if builtin autoload -Uz "$func_name" 2>/dev/null; then
        [[ -n ${ZSH_DEBUG_STARTUP:-} ]] && print "autoloaded: $func_name"
    fi
done
