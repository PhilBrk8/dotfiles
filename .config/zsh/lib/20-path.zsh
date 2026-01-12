# Add directory to PATH if it exists and is not already present
# PATH-related interactive tweaks.
#
# Note:
# - Core PATH setup lives in .zshenv.
# - Here we just enforce uniqueness to prevent PATH bloat.

typeset -gU path PATH
