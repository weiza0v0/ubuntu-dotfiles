# 更改历史

每项记录包含：日期、改动内容、决策原因、踩坑/注意事项、如何恢复。

---

## 2026-05-30: skill 增加 subagent 上下文管理策略

- **改动**: dotfiles-maintenance skill 新增 Context Management 章节
- **原因**: 项目文件多，在主会话直接操作容易压缩上下文
- **要点**: 非简单操作（搜索、多步修改、审计）全部用 Explore/general-purpose subagent；只有读单文件、单行修改、git commit/push 留在主会话

## 2026-05-30: 创建 dotfiles-maintenance skill

- **改动**: 新建 `.claude/skills/dotfiles-maintenance/SKILL.md`，覆盖仓库结构、添加配置/软件、conda 维护、GNOME 设置、Clash Verge、键盘映射、git 密钥清理、常见故障
- **触发词**: dotfiles、stow 包、添加配置、安装软件、conda、gnome、clash、密钥泄漏 等
- **要点**: 软链接到 `~/.claude/skills/dotfiles-maintenance` 后自动生效

## 2026-05-30: 修复 conda OpenSSL legacy provider 警告

- **改动**: `zsh/.zsh.d/env.zsh` 添加 `export OPENSSL_MODULES="$HOME/.apps/anaconda3/lib/ossl-modules"`
- **原因**: conda 自带 OpenSSL 3.0，系统 OpenSSL 3.5，conda activate 时出现 `legacy provider` 警告
- **注意**: 此变量必须在 conda 初始化前设置

## 2026-05-30: bin stow 包模块化管理 ~/.local/bin

- **改动**: 创建 `bin/.local/bin/` 目录，内含 `lazygit`、`nvim`、`fzf`、`yazi`、`ya` 的相对符号链接（→ `../../.apps/<name>/bin/<binary>`）
- **原因**: 之前 install.sh 手动 `ln -sf`，不够模块化；改为 stow 管理后一键部署
- **注意**: `fcitx5-switch.sh` 是真实脚本文件放在 bin 包里，不是符号链接；`toggle-caps` 是 setuid 二进制，移到 `scripts/`，不走 stow

## 2026-05-30: ~/apps → ~/.apps 重命名

- **改动**: 所有软件从 `~/apps/` 移到 `~/.apps/`，主目录仅保留 XDG 标准目录
- **原因**: 贯彻"主目录只显示标准目录"策略
- **踩坑**: 
  1. conda 内部 873 个文件硬编码了旧路径 `apps/anaconda3`，导致 `conda activate` 报 `bad interpreter`
  2. 修复: `grep -rIl 'OLD_PATH' ~/.apps/anaconda3/ | xargs -r sed -i 's|OLD_PATH|NEW_PATH|g'` + 清除 zsh 缓存 `rm -rf ~/.cache/fsh ~/.zcompdump*`
  3. **如果 conda 路径再次变动**: 重复上述 mass sed + 清缓存即可

## 2026-05-30: README 重写

- **改动**: 222 行 WSL 专题 → 58 行精确描述当前仓库结构、部署方式、stow 管理命令

## 2026-05-30: 修复 .gitignore 误伤 claude/ stow 包

- **改动**: `.gitignore` 中 `claude` → `/.claude/*` + `!/.claude/skills/`
- **原因**: `claude` 无锚定会匹配任意路径含 `.claude` 的目录，导致 `claude/.claude/settings.json` 被忽略
- **规则**: 用 `/.dirname` 锚定到仓库根目录；用 `!` 对已忽略的目录内容做白名单

## 2026-05-30: Clash Verge 离线安装包

- **改动**: 下载 clash-verge v2.5.1 deb (80MB) 放到 `clash-verge/clash-verge.deb`
- **更新方式**: 查 `https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest`，下载新 deb 替换

## 2026-05-30: Git 密钥泄漏处理

- **事件**: GitHub push 被 block，因为早期 commit 中 README 包含 GitHub PAT
- **修复流程**:
  1. `git filter-branch -f --tree-filter "sed -i 's|SECRET|REPLACED|g' FILE" -- --all`
  2. `git reflog expire --expire=now --all && git gc --prune=now --aggressive`
  3. `git push -u origin main --force`
- **教训**: 
  - 不要在任何文件里写 token/密钥
  - `.gitignore` 必须在首次 commit 前就配好敏感文件
  - filter-branch 的 sed 模式要精确匹配，否则无效

## 2026-05-30: 虚拟机清理 + 磁盘空间回收

- **改动**: 销毁 VM、删除镜像、卸载 7 个虚拟化包 + 4 个孤儿依赖；清理 pip cache (4.1G)、trash (447M)、tracker3 cache (778M)、apt cache (113M)
- **磁盘回收**: 总计释放约 12G

## 初始状态 (2026-05-30)

- **仓库初始化**: 45 个配置文件、14 个 stow 包、一键安装脚本
- **Stow 包**: zsh, tmux, nvim, yazi, bash, conda, fastfetch, ghostty, htop, lazygit, flameshot, fsearch, fcitx5, starship, pavucontrol, ipython, vscode, gnome, bin, claude
- **远程**: `git@github.com:weiza0v0/ubuntu-dotfiles.git`
