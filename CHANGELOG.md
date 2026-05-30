# 维护变更历史

> 每次维护操作（安装软件、添加配置、系统修改）后追加一条记录。

## 2026-05-30

- **初始化仓库** — 45 个配置文件、14 个 stow 包、一键安装脚本 `install.sh`
- **重组主目录** — `~/apps` → `~/.apps`；仅保留 XDG 标准目录可见
- **模块化 bin 管理** — 创建 `bin` stow 包，`~/.local/bin/` 全部通过相对 symlink 指向 `~/.apps/<name>/bin/`
- **清理虚拟化** — 删除 Multipass VM/镜像，卸载全部虚拟化软件包，移除 `scripts/create-vm.sh` 等
- **安装 Clash Verge** — v2.5.1 deb 放入 `clash-verge/`，配置文件管理
- **修复 conda** — `apps→.apps` 后批量替换 873 处硬编码路径；添加 `OPENSSL_MODULES` 修复 OpenSSL legacy provider 警告
- **重写 README** — 精简为 58 行，包含目录结构、部署步骤、stow 管理命令
- **.gitignore 完善** — secrets.zsh、profiles.yaml、`/.claude/*`（保留 skills）、ipython 运行时数据
- **清除 git 历史密钥** — filter-branch 移除 PAT，force push 到 GitHub
- **磁盘清理** — pip 缓存 (4.1G)、trash (447M)、tracker3 缓存 (778M)、apt 缓存 (113M)、VM 镜像 (~6.5G)
- **nvim 优化** — 输入法自动切换（fcitx5）、4 空格缩进、Wayland 剪贴板 xclip
- **Skill 创建** — `dotfiles-maintenance` Claude Code skill，含 subagent 上下文管理策略
