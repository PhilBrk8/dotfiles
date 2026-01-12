# Dotfiles & System Bootstrap  
**Zsh · Fedora-first · Submodules · Ansible**

This repository contains a **professional, reproducible dotfiles and system bootstrap setup** built around:

- a **bare Git dotfiles repository** (overlaying `$HOME`)
- **Git submodules** for complex or upstream-driven configs
- a minimal but extensible **Ansible bootstrap**
- strict separation of **portable config** and **machine-local overrides**

The design favors **clarity, safety, and long-term maintainability** over cleverness.

---

## 🧱 Core Design Principles

### 1. Bare dotfiles repository (no symlinks)
- Git repository lives at `~/.dotfiles` (bare)
- Working tree is `$HOME`
- No symlink managers (stow/chezmoi/etc.)
- Git status stays readable (`status.showUntrackedFiles = no`)

This avoids clutter while keeping Git semantics intact.

---

### 2. Submodules as pinned dependencies
Large or structured configs are included as **Git submodules**, pinned to explicit commits.

Two patterns are used intentionally:

#### A) Upstream-only submodules (no local changes)
Examples:
- `zsh-autosuggestions`
- `powerlevel10k`

Characteristics:
- Track upstream directly (HTTPS)
- Never edited locally
- Updated only via explicit bump

#### B) Forked submodules (customized)
Examples:
- Neovim (`kickstart.nvim`)
- tmux configuration
- ZMK keyboard firmware

Characteristics:
- Submodule URL points to **my fork**
- Original project added as `upstream` remote *inside the submodule*
- Upstream changes are merged/rebased in the fork
- The superproject pins the resulting commit

This guarantees reproducibility **without losing customization**.

---

### 3. Local-only overrides (never versioned)
Machine-specific or sensitive data lives outside Git:

```
~/.config/dotfiles-local/local.zsh
```

- Explicitly ignored
- Sourced by `.zshrc`
- Safe for tokens, hostnames, hardware quirks

---

### 4. Explicit workflows only
Nothing auto-merges.  
Nothing updates implicitly.  
All changes are intentional and auditable.

---

## ✅ Security Guardrails (pre-commit + secret scanning)

This repo is a `$HOME` worktree overlay. That’s powerful, but also increases the risk of accidentally committing secrets or personal state.
To reduce risk, the workflow is guarded both **locally** (pre-commit) and in **CI** (GitHub Actions).

### Local: pre-commit hooks (required)
Hooks are defined in:

- `~/.pre-commit-config.yaml` (versioned)

Install on a machine:

```bash
# install tool (pick one)
pipx install pre-commit
# or: python -m pip install --user pre-commit

# install hooks into this repo
cd ~
pre-commit install

# one-time initial run to normalize formatting + catch issues
pre-commit run --all-files

---

## 🛠️ Tooling

### Enabling VS-Code / Gitlense support for the bare repo at

Whith this, you’re intentionally turning the bare repo into a “separate git dir” repo 
(git dir stored in ~/.dotfiles, worktree is $HOME)

```bash
DOTDIR="$HOME/.dotfiles"

# Make the repo behave like a normal working tree repo (but gitdir is elsewhere)
git --git-dir="$DOTDIR" config --local core.bare false
git --git-dir="$DOTDIR" config --local core.worktree "$HOME"

# Create the marker file that makes tools (VS Code/GitLens) detect the repo
printf "gitdir: %s\n" "$DOTDIR" > "$HOME/.git"
```
You want false for --is-bare-repository, and git status should work normally from ~. 
After that, VS Code + GitLens will typically detect it when you open your home folder.

#### Clone as separate-git-dir for new machines
Even cleaner (for new machines): clone as separate-git-dir from the start
```bash
git clone --separate-git-dir="$HOME/.dotfiles" <REPO_URL> "$HOME"
printf "gitdir: %s\n" "$HOME/.dotfiles" > "$HOME/.git"
```

A bare repo has no index/worktree expectations
Switching to non-bare is fine, but if anything feels odd, git status is the truth test. 
If git status behaves, GitLens will too.

Check for status of the repo:
```bash
git -C "$HOME" rev-parse --is-bare-repository
git -C "$HOME" status
git -C "$HOME" status -sb
git -C "$HOME" config --get core.worktree
git -C "$HOME" config --get core.bare
```

### `dot` — low-level Git wrapper
A thin wrapper around Git for the bare repo.

Examples:
```
dot status
dot add ~/.zshrc
dot commit -m "Update zsh config"
dot push
```

---

### `dotctl` — recommended interface
High-level, **safe-by-default** workflow command.

#### Apply dotfiles + submodules
```
dotctl apply
```

Behavior:
1. Refuses to run if any submodule has uncommitted changes
2. Fast-forwards the dotfiles superproject
3. Syncs submodule URLs
4. Updates submodules to pinned commits
5. Exits with **code 10** if manual intervention is required

This prevents silent breakage.

#### Update a submodule intentionally
```
dotctl bump .config/nvim
dot commit -m "bump nvim config"
dot push
```

#### Check status
```
dotctl status
```

---

## 📁 Repository Layout

```
$HOME/
├── .dotfiles/                  # bare git repository
├── .gitmodules                 # submodule definitions
├── .local/bin/
│   ├── dot
│   └── dotctl
├── .config/
│   ├── nvim/                   # submodule (forked)
│   ├── tmux/                   # submodule (forked)
│   ├── kinesis/Adv360pro/...   # submodule (forked)
│   └── zsh/
│       ├── plugins/
│       │   └── autosuggestions # submodule (upstream)
│       └── powerlevel10k       # submodule (upstream)
├── .config/dotfiles-local/     # NOT versioned
└── bootstrap/
    └── ansible/
```

---

## 🤖 Ansible Bootstrap

The `bootstrap/ansible` directory provides a **layered provisioning model**.

### Layers
- **portable_files**  
  Installs dotfiles repo and runs `dotctl apply`
- **operating_system**  
  OS-level defaults and hardening
- **package_dependencies**  
  dnf / apt packages
- **machine_role_config**  
  Workstation / server / k8s-worker specifics

### Run locally
```
ansible-playbook -i inventory/localhost.yml site.yml
```

Ansible **fails loudly** if:
- dotfiles checkout would overwrite existing files
- submodules are dirty or inaccessible

---

## 🔐 Security Model

- No secrets in Git
- Local overrides explicitly excluded
- Private submodules use SSH
- Public submodules use HTTPS
- Failure modes are visible and explicit

---

## 🔁 Common Workflows

### New machine bootstrap
1. Install Git + Ansible
2. Clone dotfiles repo as bare into `~/.dotfiles`
3. Run Ansible playbook
4. Done

---

### Daily update
```
dotctl apply
```

---

### Sync forked submodule with upstream
Example for Neovim:

```
cd ~/.config/nvim
git fetch upstream
git rebase upstream/main
git push origin
cd ~
dotctl bump .config/nvim
dot commit -m "sync nvim with upstream"
dot push
```

---

## 📜 License
MIT (or your preferred license)

---

## 🧭 Status
Actively used and evolved.  
Designed to scale from laptop → workstation → server.  
Opinionated, but intentionally so.
