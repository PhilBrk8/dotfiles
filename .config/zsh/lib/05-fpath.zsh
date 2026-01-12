# -----------------------------------------------------------------------------
# fpath bootstrap (MUST run early)
#
# Why:
# - Many plugins and even your own lib files rely on zsh "helper functions"
#   such as `add-zsh-hook` and `is-at-least`.
# - Those helpers are shipped as function files that Zsh loads via $fpath.
#
# Goal:
# - Ensure $fpath contains system function roots AND their first-level subdirs
#   (e.g. Misc/, Completion/), because Zsh does not search recursively.
# - Ensure our own function directories are present as well.
#
# Trade-offs:
# - Slightly more work at shell startup.
# - Much more predictable startup: fewer “autoload: function definition file not found”.
# -----------------------------------------------------------------------------

typeset -gUa fpath

typeset -ga _fp_add
_fp_add=()

# -----------------------------------------------------------------------------
# System function dirs (Zsh ships helpers in subdirs like Misc/)
# -----------------------------------------------------------------------------
typeset root
for root in \
  /usr/local/share/zsh/site-functions \
  /usr/share/zsh/site-functions \
  /usr/share/zsh/functions \
  /usr/share/zsh/${ZSH_VERSION}/functions \
  /usr/share/zsh/*/functions(/N); do

  [[ -d "$root" ]] || continue
  _fp_add+=("$root")

  # One level of subdirs is enough for add-zsh-hook/is-at-least/etc.
  _fp_add+=("$root"/*(/N))
done

# -----------------------------------------------------------------------------
# Our function dirs
# -----------------------------------------------------------------------------
if [[ -d "$ZSHDIR/functions" ]]; then
  _fp_add+=("$ZSHDIR/functions")
  _fp_add+=("$ZSHDIR/functions"/**/*(/N))
fi

# Prepend additions (typeset -U keeps first occurrence => our ordering wins).
fpath=("${_fp_add[@]}" "${fpath[@]}")

unset _fp_add root
