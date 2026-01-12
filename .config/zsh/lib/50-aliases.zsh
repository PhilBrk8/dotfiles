# Aliases grouped by topic.
#
# Trade-offs:
# - Aliases can hide “real” commands; keep names obvious and documented.

# ⚠️  SECURITY WARNING:
# This executes remote code. Fun, but not something you'd enable in a “hardened” profile.
# alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

alias showoff="neofetch --chafa_format symbols --source $HOME/.config/neofetch/sss.png"

# Source alias groups if present
for f in \
    "$alias_dir/commonEdits" \
    "$alias_dir/docker" \
    "$alias_dir/encryption" \
    "$alias_dir/filehandling" \
    "$alias_dir/git" \
    "$alias_dir/media" \
    "$alias_dir/network_admin" \
    "$alias_dir/scripts" \
    "$alias_dir/ssh" \
    "$alias_dir/syncthing" \
    "$alias_dir/sysadmin" \
    "$alias_dir/webdev"; do
    [[ -r "$f" ]] && source "$f"
done
