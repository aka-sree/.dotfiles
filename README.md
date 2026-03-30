# Dotfiles

Shell, editor, and tooling config — works with both **bash** and **zsh**.

## Supported Platforms

- Fedora 43+ (`dnf`)
- Debian / Ubuntu / Pop!_OS (`apt-get`)
- WSL2 (Debian-based)

## Quick Start

```bash
git clone git@github.com:aka-sree/.dotfiles.git ~/sree/.dotfiles
cd ~/sree/.dotfiles
```

### 1. Bootstrap tools

```bash
chmod +x setup_env.sh jobs/*.sh
./setup_env.sh
```

Run a specific job: `./setup_env.sh bash` or `./setup_env.sh tmux`

Preview without executing: `./setup_env.sh --dry`

### 2. Symlink configs

```bash
./install.sh
```

This links `~/.bashrc`, `~/.zshrc`, `~/.shell_common.sh`, `~/.tmux.conf`, and `~/.config/nvim`.

### 3. Post-install

- Open `nvim` — lazy.nvim auto-installs plugins on first launch.
- In tmux, press `prefix + I` to install TPM plugins.
- Restart your terminal or run `exec bash` / `exec zsh`.

## Structure

```
bashrc              # Bash config (prompt, completion, keybindings)
zsh/.zshrc          # Zsh config (oh-my-zsh, p10k, plugins)
shell_common.sh     # Shared aliases, functions, NVM lazy-loading
tmux/.tmux.conf     # Tmux config (Ctrl-a prefix, tokyo-night theme)
nvim/.config/nvim/  # Neovim (lazy.nvim, LSP, telescope, treesitter)
git/.gitconfig      # Git config with conditional work/personal includes
scripts/            # tmux-sessionizer (Ctrl-P), cht.sh helper
jobs/               # Installer scripts (auto-detect Fedora vs Debian)
install.sh          # Symlink everything into $HOME
setup_env.sh        # Run job scripts with filtering and dry-run
```

## Key Bindings

| Key | Action |
|-----|--------|
| `Ctrl-P` | tmux-sessionizer (pick a repo, open a session) |
| `Ctrl-a` | tmux prefix |
| `Space` | nvim leader |

## Shell Performance

NVM is lazy-loaded — `nvm`, `node`, `npm`, `npx` load on first use.

Benchmark: `timeshell` (bash/zsh)
