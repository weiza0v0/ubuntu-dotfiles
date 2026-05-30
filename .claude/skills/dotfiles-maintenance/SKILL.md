---
name: dotfiles-maintenance
description: This skill should be used when the user asks about dotfiles management, adding new configs or software, GNU Stow, system maintenance, conda troubleshooting, GNOME settings, Clash Verge, Kanata keyboard mapping, git secrets cleanup, or Ubuntu home directory organization. Use when the user mentions "dotfiles", "stow 包", "添加配置", "安装软件", "装个", "下载安装包", "主目录", "conda", "gnome", "clash", "提交到 git", or "密钥泄漏".
---

# Dotfiles & Ubuntu System Maintenance

This skill covers the maintenance of a modular, GNU Stow-based dotfiles repository at `~/.dotfiles` (remote: `git@github.com:weiza0v0/ubuntu-dotfiles.git`).

## Repository Structure

```
~/.dotfiles/
├── zsh/          .zshrc, .zimrc, .zsh.d/
├── tmux/         .tmux.conf, plugin config
├── nvim/         Lazy.nvim config
├── bash/         .bashrc, .profile
├── bin/          .local/bin symlinks (stow-managed)
├── claude/       Claude Code settings
├── vscode/       Code/User/settings.json
├── gnome/        Glib/GTK settings
├── ghostty/      Terminal config + shaders
├── clash-verge/  Configs + offline .deb
├── conda/        .condarc
├── fcitx5/       Chinese input method
├── scripts/      install.sh, kanata.kbd, gnome-dconf.ini, toggle-caps
└── (other packages: fastfetch, htop, lazygit, flameshot, fsearch,
     starship, pavucontrol, ipython, yazi, condaEnvs)
```

**Key principle:** `stow pkg` creates symlinks at `$HOME` mirroring the directory structure inside the package.

## Context Management: Always Use Subagents

This repo has 20+ stow packages, hundreds of config files, and long scripts. Doing everything in the main conversation will compress context quickly. **For any non-trivial work, delegate to subagents.**

### When to spawn a subagent

| Task type | Subagent | Why |
|-----------|----------|-----|
| Find which files reference a path/pattern | `Explore` agent | Avoid loading every file into main context |
| Check all stow packages for consistency | `Explore` agent | 20+ directories, too many to read inline |
| Add a new stow package (multi-step) | `general-purpose` agent | mkdir + mv + edit install.sh + stow + commit = 5+ files |
| Update install.sh for new software | `general-purpose` agent | Edits span multiple sections of a long script |
| Investigate a conda/gnome/stow issue | `Explore` agent | Research first, then report back before acting |
| Mass-update paths across the repo | `general-purpose` agent | Bulk sed/grep across many files |
| Audit .gitignore coverage | `Explore` agent | Cross-reference stow packages vs gitignore rules |

### What stays in main conversation

- Reading a single known file path
- Simple one-line edits
- Git commit/push (after agent has staged changes)
- Final review before pushing

### Subagent prompt template

When spawning an agent for dotfiles work, always include:
1. The repo path (`~/.dotfiles`)
2. The stow package structure convention (`pkg/.config/app/file` → `~/.config/app/file`)
3. The relevant constraints (home directory policy, .gitignore rules, never run `conda init`)
4. Whether to only research or also make changes

## Home Directory Policy

Only XDG standard directories remain visible:
```
Desktop/  Documents/  Downloads/  Music/  Pictures/
Public/   Templates/  Videos/    snap/ (forced by snapd)
```
All user software, configs, and data go under dot-prefixed (hidden) paths.

## Adding a New Config to Dotfiles

1. Create the stow package directory with proper nesting:
   ```bash
   mkdir -p ~/.dotfiles/<pkg>/<path-from-home>
   ```
2. Move the config file into the package:
   ```bash
   mv ~/<path-from-home>/config ~/.dotfiles/<pkg>/<path-from-home>/
   ```
3. Add to `scripts/install.sh`:
   - `clean_conflict` line for the target path (if it may exist on new machines)
   - `stow -vR --dir=. --target="$HOME" <pkg>` line in the stow section
4. Apply immediately: `cd ~/.dotfiles && stow -vR <pkg>`
5. Commit and push.

## Adding New User Software

Software installs to `~/.apps/<name>/` (hidden), binaries exposed via the `bin` stow package:

1. Install/copy software to `~/.apps/<name>/`
2. Create a relative symlink in `bin/.local/bin/`:
   ```bash
   cd ~/.dotfiles
   ln -sf ../../.apps/<name>/bin/<binary> bin/.local/bin/<binary>
   ```
3. `stow -vR bin` deploys the symlink to `~/.local/bin/`
4. Setuid binaries (e.g., toggle-caps) go to `scripts/` and are installed to `/usr/local/bin` with `chmod 4755` by install.sh.

## .gitignore Rules

Sensitive/excluded files:
- `secrets.zsh` — API keys, sourced by `.zshrc`
- `clash-verge/profiles.yaml` — subscription token
- `/.claude` — root-anchored (only repo root `.claude/`, not nested like `pkg/.claude/`)
- `fcitx5/.config/fcitx5/conf/cached_layouts` — auto-generated cache
- `ipython/` runtime data — `db/`, `log/`, `pid/`, `security/`, `history.sqlite`

Use `/.dirname` to anchor patterns to repo root, preventing accidental matches in package subdirectories.

## Conda Management

**Install location:** `~/.apps/anaconda3/` (since the `apps→.apps` rename).

**Lazy loading** (in `zsh/.zsh.d/env.zsh`): Conda is NOT initialized at shell start. The `conda()` wrapper function defers `source conda.sh` until first invocation, saving ~350ms startup time.

**NEVER run `conda init`** — it hardcodes absolute paths into `.zshrc`, which breaks if the install directory moves.

**If conda directory is moved/renamed:** Mass-replace all hardcoded paths (text files only, skip binaries):
```bash
grep -rIl 'OLD_PATH' ~/.apps/anaconda3/ | xargs -r sed -i 's|OLD_PATH|NEW_PATH|g'
```
Key files: `etc/profile.d/conda.sh` (CONDA_EXE, _CONDA_EXE), `bin/*` shebangs.

**OpenSSL legacy provider warning fix:** Added to `env.zsh`:
```bash
export OPENSSL_MODULES="$HOME/.apps/anaconda3/lib/ossl-modules"
```

## GNOME Settings

- **Export:** `dconf dump / > scripts/gnome-dconf.ini`
- **Import** (in install.sh): `dconf load / < scripts/gnome-dconf.ini`
- The binary dconf database (`~/.config/dconf/user`) is NOT tracked in git.

## Clash Verge

- Offline deb at `clash-verge/clash-verge.deb` (v2.5.1, ~80MB).
- Config YAMLs are committed; `profiles.yaml` is gitignored (contains subscription token).
- To update: check `https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest`, download new deb, commit.

## Keyboard (Kanata + toggle-caps)

- **Kanata:** Config at `scripts/kanata.kbd` → `/etc/kanata.kbd`, runs via systemd service at `/etc/systemd/system/kanata.service`.
- **toggle-caps:** Setuid ELF binary at `scripts/toggle-caps` → installed to `/usr/local/bin/toggle-caps` with `chmod 4755`. Not stowed (system-level, needs root).

## Git: Removing Secrets from History

If a secret is committed and GitHub blocks the push:

```bash
# 1. Rewrite history to remove the secret
git filter-branch -f --tree-filter \
  "if [ -f FILE ]; then sed -i 's|SECRET|REPLACEMENT|g' FILE; fi" -- --all

# 2. Expire reflogs and prune
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 3. Force push
git push -u origin main --force
```

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `conda` command not found after path change | Stale compiled zsh cache (`~/.cache/fsh/`) | `rm -rf ~/.cache/fsh ~/.zcompdump* && exec zsh` |
| `__conda_exe: bad interpreter` | conda binary shebangs have old install path | Run the mass `sed` path replacement (see Conda section) |
| `stow` creates wrong symlinks | Existing real files block stow | `clean_conflict` backs up to `.bak_YYYYMMDD` before stowing |
| Already-stowed files are real files, not symlinks | Previous stow was undone manually | Re-run `stow -vR <pkg>` |
| OpenSSL legacy provider warning on `conda activate` | Conda OpenSSL 3.0 vs system 3.5 mismatch | Set `OPENSSL_MODULES` env var (see Conda section) |
