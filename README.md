# Dotfiles Bootstrap

This repo centralizes shell, editor, and tooling configuration for a fast, minimal dev environment.

---

## Supported Platforms

| Platform | Package Manager | Notes |
|---|---|---|
| Fedora 43 | `dnf` | Tested on Fedora 43 Workstation |
| Debian / Ubuntu / Pop!_OS | `apt-get` | Tested on Debian 12 (Bookworm) |
| WSL2 | `apt-get` | Debian-based WSL images supported |

---

## Quick Start

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### 1. Run the bootstrapper

Installs packages, tools, zsh, tmux, neovim, and fonts:

```bash
chmod +x setup_env.sh jobs/*.sh
./setup_env.sh
```

- `--dry` to preview which jobs run without executing them.
- Pass a regex to target specific jobs: `./setup_env.sh zsh` runs only `jobs/zsh.sh`.

Jobs run in sorted order:

```
font.sh → lazygit.sh → neovim.sh → node.sh → packages.sh → tmux.sh → zsh.sh
```

The script aborts on the first failure.

---

### 2. Symlink configs with GNU Stow

Install Stow for your distro:

**Debian / Ubuntu / WSL:**
```bash
sudo apt-get install -y stow
```

**Fedora 43:**
```bash
sudo dnf install -y stow
```

Then symlink all modules:

```bash
cd ~/.dotfiles
stow -t $HOME zsh tmux nvim git scripts
```

| Stow command | Effect |
|---|---|
| `stow -t $HOME <module>` | Symlink a module into `$HOME` |
| `stow -D <module>` | Remove a module's symlinks |
| `stow --simulate -t $HOME <module>` | Dry-run preview without applying |

---

### 3. Post-install

- Open a new terminal — zsh + p10k should load immediately.
- Open `nvim` — lazy.nvim auto-installs plugins on first launch. Run `:Mason` to verify LSP servers.
- In tmux, press `prefix + I` to install tmux plugins via TPM.

> **Fedora — default shell:** If `chsh` fails to set zsh as your default shell, ensure `util-linux-user`
> is installed (`sudo dnf install -y util-linux-user`) and re-run `jobs/zsh.sh`.

> **Fedora — SELinux:** If any job script is blocked with `Permission denied` despite correct permissions,
> run `restorecon -v jobs/*.sh` to restore the correct SELinux file context. Fedora 43 ships with
> SELinux enforcing by default; files copied from NTFS/FAT mounts or extracted from zips can lose
> their context.

---

## What's Included

| Module | What it does |
|---|---|
| `zsh` | Oh My Zsh + p10k + autosuggestions + fast-syntax-highlighting |
| `tmux` | tmux config (Ctrl-a prefix) + TPM + tokyo-night theme |
| `nvim` | Neovim (built from source, release-0.11) + lazy.nvim + LSP (clangd, ts_ls, lua_ls) + telescope + treesitter + neo-tree + bufferline + copilot |
| `git` | Global gitconfig with conditional includes for work/personal |
| `scripts` | tmux-sessionizer (Ctrl-P, multi-repo support) + cht.sh helper |
| `jobs` | Installer scripts — each auto-detects Fedora vs Debian at runtime |

---

## Jobs — Package Name Differences

Each job script detects the distro via `/etc/os-release` and selects the correct package manager and
package names automatically. Key differences handled internally:

| Purpose | Debian name | Fedora name |
|---|---|---|
| Build tools | `build-essential` | `gcc gcc-c++ make` |
| Lua headers | `liblua5.1-0-dev` | `lua-devel` |
| Lua runtime | `lua5.1` | `lua` |
| clang-tidy | `clang-tidy` | `clang-tools-extra` |
| `chsh` provider | `passwd` (pre-installed) | `util-linux-user` |
| Font cache | `fontconfig` | `fontconfig` |
| Node.js repo | `deb.nodesource.com` | `rpm.nodesource.com` |
| Package verification | `dpkg -s <pkg>` | `rpm -q <pkg>` |

### How distro detection works

Every job sources `/etc/os-release` and branches on `$ID` and `$ID_LIKE`:

```bash
. /etc/os-release
case "$ID" in
    fedora)                       is_fedora=true ;;
    debian|ubuntu|linuxmint|pop)  is_debian=true ;;
    *)
        # Fallback for derivatives (e.g. RHEL, Rocky, Mint)
        [[ "$ID_LIKE" =~ fedora|rhel ]]   && is_fedora=true
        [[ "$ID_LIKE" =~ debian|ubuntu ]] && is_debian=true
        ;;
esac
```

This means the scripts also work on Fedora derivatives (RHEL, Rocky Linux) and Debian derivatives
(Ubuntu, Pop!_OS, Linux Mint) without modification.

---

## Shell Performance

NVM is lazy-loaded — `nvm`, `node`, `npm`, and `npx` load on first use instead of on every shell
startup. The p10k right prompt is trimmed to only the segments you actually use.

Run `timezsh` to benchmark shell startup time.

> **Fedora note:** `timezsh` requires a fresh login session after install. The `chsh` change takes
> effect when PAM re-reads `/etc/passwd` at login — not immediately after `exec zsh`. Confirm your
> shell was updated with `echo $SHELL` and that `/usr/bin/zsh` is listed in `cat /etc/shells`.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `chsh: PAM authentication failed` | `util-linux-user` missing (Fedora) | `sudo dnf install -y util-linux-user` |
| `Permission denied` running a job (Fedora) | SELinux file context stripped | `restorecon -v jobs/*.sh` |
| `dpkg: command not found` | Running Debian-only job on Fedora | Each job auto-detects distro; re-run via `./setup_env.sh` |
| TPM plugins not installed | No tmux server running during install | Run `prefix + I` inside a live tmux session |
| `fc-cache: command not found` | `fontconfig` not installed | `sudo dnf install -y fontconfig` or `sudo apt-get install -y fontconfig` |
| Neovim build fails | Missing build deps | Re-run `jobs/neovim.sh` — it will install missing deps then retry |
| `lazygit` download fails on ARM | Hardcoded `x86_64` arch (old script) | Updated scripts detect arch via `uname -m` automatically |
