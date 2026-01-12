# Zish — modular, XDG-friendly Zsh configuration

A pragmatic Zsh setup designed to be:

- **Deterministic**: predictable load order, minimal magic.
- **Safe**: `.zshenv` stays non-interactive and lightweight (ssh/scp/cron-friendly).
- **Modular**: small, focused modules loaded in numeric order.
- **Reproducible**: plugins/themes pinned via git submodules (optional but recommended).
- **Portable**: follows **XDG Base Directory** conventions and guards missing tools.

> Name note: if you want this to read well on GitHub, consider adding a one-liner tagline in the repo description, e.g.  
> “A fast, modular Zsh config with XDG defaults, autoloaded functions, and pinned plugins.”

---

## Directory layout

```
.
├── lib/                 # Core modules, sourced in numeric order
├── functions/           # Autoloadable functions (1 file = 1 function)
├── aliases/             # Alias groups (sourced by lib/50-aliases.zsh)
├── plugins/             # Small, explicit plugins (submodules welcome)
├── powerlevel10k/       # Prompt theme (as submodule or vendored)
├── options/             # Optional feature toggles / future split
└── docs/                # Reference PDFs / notes
```

### `lib/` modules

These are sourced from `.zshrc` in filename order:

- **`00-guard.zsh`**  
  Defines shared paths/vars (e.g. `$ZSHDIR`, `$plugin_dir`, `$alias_dir`) and loads **local-only overrides** early.

- **`05-fpath.zsh`**  
  Bootstraps `fpath` so Zsh can `autoload` its own helper functions (e.g. `add-zsh-hook`, `is-at-least`).  
  Key design detail: Zsh ships helpers in subdirectories (e.g. `.../functions/Misc/`), and `autoload` **does not search recursively**, so these subdirs must be included explicitly.

- **`10-options.zsh`**  
  Shell options (history behavior, globbing, safety toggles). Interactive-only behavior belongs here (not in `.zshenv`).

- **`20-path.zsh`**  
  Interactive PATH tweaks and toolchain-specific PATH bits (anything that shouldn’t affect non-interactive shells).

- **`30-completion.zsh`**  
  Completion setup (`compinit`), compdump path, and completion-related options.

- **`40-functions.zsh`**  
  Autoloads functions from `functions/` using a strict rule: **file name == function name**.  
  This is intentional: it avoids “mystery sourcing” and makes functions discoverable and testable.

- **`50-aliases.zsh`**  
  Sources alias group files from `aliases/` (git/docker/sysadmin/etc.).

- **`60-plugins.zsh`**  
  Loads a short, explicit plugin list with guards.  
  Load-order matters; in particular **`zsh-syntax-highlighting` must be loaded last**.

- **`90-startup.zsh`**  
  Final interactive “session” setup (welcome messages, ssh-agent socket detection, small per-session tweaks).  
  Design principle: **never block startup**, never prompt unexpectedly.

---

## Startup flow

Zsh startup differs between non-interactive, interactive, and login shells. This repo embraces that:

### `.zshenv` — minimal, always
Runs for **every** zsh invocation (interactive + non-interactive).

- Sets XDG paths and conservative environment variables.
- Provides tiny helpers (e.g. `path_prepend`) that are safe everywhere.
- Avoids interactive behavior (no prompts, no heavy sourcing).

### `.zprofile` — login-only
Runs once per login session (e.g. tty login).

- Good for heavier toolchains or environment scripts (Rust, oneAPI, …).
- Keep it guarded and quiet.

### `.zshrc` — interactive shells
Runs for interactive shells only.

- Loads Powerlevel10k (and instant prompt if enabled).
- Sources `lib/*.zsh` modules in numeric order.
- Returns early for non-interactive shells.

---

## Installation

This setup assumes Zsh config lives in:

- `~/.config/zsh` (default) or `${XDG_CONFIG_HOME}/zsh`

Ensure `~/.zshenv` sets `ZDOTDIR`:

```zsh
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${ZDOTDIR:=$XDG_CONFIG_HOME/zsh}"
export ZDOTDIR
```

Then place `.zshrc`, `.zprofile`, and your `lib/` tree under `$ZDOTDIR`.


---

## Plugins and submodules

This repo favors **explicit plugin loading** over frameworks (Oh My Zsh, etc.). You get:

- predictable startup
- fewer hidden side effects
- easy auditing

### Initialize submodules
If you pin plugins/themes as submodules:

```sh
git submodule update --init --recursive
```

### Syntax highlighting (Catppuccin)
The Catppuccin theme file only takes effect if `zsh-syntax-highlighting` is loaded.

In `lib/60-plugins.zsh`:

- load autosuggestions first
- load syntax-highlighting last
- then source the theme file

---

## Usage

### Managing dotfiles with a bare repo (`dot`)
If you keep a bare dotfiles repo (e.g. `~/.files`), a small wrapper function is recommended:

- functions are safer than aliases (argument handling + completion)
- `compdef dot=git` lets you reuse git completion

Common commands:

```sh
dot status
dot add ~/.config/zsh/lib/60-plugins.zsh
dot commit -m "Update plugins ordering"
dot push
```

Tip: prefer **git aliases** for git-only shortcuts; keep shell aliases for cross-tool workflows.

### Adding a new function
Place a file in `functions/<category>/<name>`:

- file name must equal function name
- keep it single-purpose
- include a short header comment (goals/trade-offs)

Example:

```
functions/utils/now
```

```zsh
now() { date -Is }
```

It will be autoloaded by `lib/40-functions.zsh`.

### Adding aliases
Add an alias file under `aliases/` (grouped by topic) and ensure `lib/50-aliases.zsh` sources it.

Good patterns:

- keep aliases small and obvious
- prefer functions for anything with logic
- guard platform-specific commands

---

## Troubleshooting

### Debug module load order
```sh
ZSH_DEBUG_STARTUP=1 zsh -ic 'echo ok'
```

### Check `autoload` and helper functions
If you ever see `autoload: function definition file not found`, it usually means `fpath` is incomplete.

```sh
zsh -ic '
  whence -wa autoload add-zsh-hook is-at-least
  print -l $fpath | grep -E "/Misc$" | head -n 5 || echo "NO Misc FOUND"
'
```

### “One file = one function” rule violations
If a function isn’t found:

- file name and function name must match
- the directory must be in `fpath`
- avoid naming collisions with builtins (e.g. `autoload`, `test`, `time`)

---

## Security and reliability notes

- **Non-interactive safety**: `.zshenv` remains minimal to avoid breaking ssh/scp/cron.
- **No hidden key loading**: prefer system-managed `ssh-agent` (e.g. systemd user service) and `AddKeysToAgent` in `~/.ssh/config`.
- **Guard everything**: only source files if they exist; never block startup.

---

## Suggested “portfolio polish” additions

If you plan to publish this on GitHub, these small additions make it feel professional:

- **`LICENSE`** (MIT/Apache-2.0 are common defaults)
- **`CHANGELOG.md`** (even a short “Notable changes” list helps)
- **`CONTRIBUTING.md`** (how to add functions/plugins, style rules)
- **CI lint** (GitHub Actions):
  - `zsh -n` syntax check for `lib/*.zsh`
  - optional: run a minimal `zsh -ic` smoke test in a container
- **Coding style guide** section:
  - use `emulate -L zsh` in functions/modules with non-trivial logic
  - keep startup quiet (no output unless `ZSH_DEBUG_STARTUP` is set)
  - avoid `local` at top-level (only valid inside functions)

---

## What else is useful context (if you want this README to be even tighter)

If you want the README to be “drop-in for others”, these details help:

- target OS(es): Fedora-only vs “Linux + macOS”
- required packages: `zsh`, `git`, `fzf`, `bat`, `ripgrep`, etc.
- terminal expectations: Kitty/WezTerm/Alacritty + Nerd Font for Powerlevel10k
- how you install this (bare repo, stow, chezmoi, nix-home-manager, …)
- which parts are opinionated (XDG paths, systemd ssh-agent) vs optional
- a short list of “favorite commands” (top 10 functions/aliases)

---

## Credits

- [Powerlevel10k](./powerlevel10k/) prompt
- [zsh-autosuggestions](./plugins/autosuggestions/)
- [zsh-syntax-highlighting](./plugins/zsh-syntax-highlighting/)
- Catppuccin theme for zsh-syntax-highlighting
