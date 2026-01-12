# Completion init (compinit) with XDG cache compdump.
#
# Trade-offs:
# - compinit can be slow the first time; we cache results in ~/.cache.

autoload -Uz compinit

ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}-${HOST}-${UID}"
mkdir -p "${ZSH_COMPDUMP:h}" 2>/dev/null || true

if [[ ! -r "$ZSH_COMPDUMP" || "$ZSH_COMPDUMP" -ot "$ZSHDIR/.zshrc" ]]; then
    compinit -i -d "$ZSH_COMPDUMP"
else
    compinit -C -d "$ZSH_COMPDUMP"
fi

# Reuse git completion for dot
compdef dot=git

# Usability defaults (keep minimal)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
