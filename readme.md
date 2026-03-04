## Dotfiles Bootstrap

This repo centralizes shell, editor, and tooling configuration for a fast, minimal dev environment.

### Quick Start

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
```

**1. Run the bootstrapper** (installs packages, tools, zsh, tmux, neovim, fonts):

```bash
chmod +x setup_env.sh jobs/*.sh
./setup_env.sh
```

- `--dry` to preview which jobs run without executing them.
- Pass a regex to target specific jobs: `./setup_env.sh zsh` runs only `jobs/zsh.sh`.

Jobs run in sorted order: `font.sh` → `lazygit.sh` → `neovim.sh` → `node.sh` → `packages.sh` → `tmux.sh` → `zsh.sh`. The script aborts on the first failure.

**2. Symlink configs with GNU Stow:**

```bash
sudo apt-get install -y stow
cd ~/.dotfiles
stow -t $HOME zsh tmux nvim git scripts
```

- Remove a module: `stow -D <module>`
- Preview: `stow --simulate -t $HOME zsh tmux nvim git scripts`

**3. Post-install:**

- Open a new terminal — zsh + p10k should load immediately.
- Open `nvim` — lazy.nvim auto-installs plugins on first launch. Run `:Mason` to verify LSP servers.
- In tmux, press `prefix + I` to install tmux plugins via TPM.

### What's Included

| Module    | What it does                                                       |
|-----------|--------------------------------------------------------------------|
| `zsh`     | Oh My Zsh + p10k + autosuggestions + fast-syntax-highlighting      |
| `tmux`    | tmux config (Ctrl-a prefix) + TPM + tokyo-night theme              |
| `nvim`    | Neovim (lazy.nvim) + LSP (clangd, ts_ls, lua_ls) + telescope + treesitter + neo-tree + bufferline + copilot |
| `git`     | Global gitconfig with conditional includes for work/personal       |
| `scripts` | tmux-sessionizer (Ctrl-P, multi-repo support) + cht.sh helper     |
| `jobs`    | Installer scripts for packages, node, fonts, lazygit, tmux, zsh   |

### Shell Performance

NVM is lazy-loaded — `nvm`, `node`, `npm`, and `npx` load on first use instead of every shell. The p10k right prompt is trimmed to only segments you actually use. Run `timezsh` to benchmark.
