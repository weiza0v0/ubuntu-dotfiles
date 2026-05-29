# dotfiles

Ubuntu 桌面环境配置文件集，基于 GNU stow 管理，一键部署。

## 目录结构

```
.dotfiles/
├── zsh/          .zshrc, .zimrc, .zsh.d/
├── tmux/         .tmux.conf, help
├── nvim/         Lazy.nvim 配置
├── yazi/         终端文件管理器
├── bash/         .bashrc, .profile
├── conda/        .condarc
├── fastfetch/    系统信息面板
├── ghostty/      终端模拟器 + shaders
├── htop/         进程监视器
├── lazygit/      Git TUI
├── flameshot/    截图工具
├── fsearch/      文件搜索引擎
├── fcitx5/       中文输入法
├── starship/     Shell 提示符
├── pavucontrol/  音量控制
├── ipython/      IPython 配置
├── vscode/       settings.json, chat model
├── gnome/        Glib/GTK 设置
├── claude/       Claude Code 设置
├── condaEnvs/    数据科学依赖列表
├── clash-verge/  代理配置 + deb 离线包
├── bin/          toggle-caps, fcitx5-switch
└── scripts/      install.sh, kanata.kbd, gnome-dconf.ini
```

## 部署

```bash
# 解压
tar -xzf dotfiles.tar.gz -C ~/
# 安装
bash ~/.dotfiles/scripts/install.sh
```

安装完成后切换 shell 并重启终端：

```bash
chsh -s $(which zsh)
```

## install.sh 做了什么

1. **apt 软件包** — git, curl, zsh, stow, tmux, ripgrep, fcitx5, flameshot, pandoc, 编译工具链等 30+ 包
2. **第三方应用** — Docker (阿里云源), Ghostty (PPA), Starship, VS Code, Google Chrome, Claude Code (npm)
3. **键位映射** — Kanata (Caps→Esc/Ctrl) + systemd 服务, toggle-caps (setuid)
4. **可执行程序** — Anaconda3, Lazygit, Yazi, Neovim Nightly, FZF, Nerd Font
5. **stow 映射** — 解决冲突后创建符号链接，将各包映射到 `$HOME`
6. **GNOME 设置** — dconf 批量导入桌面环境偏好
7. **Zimfw** — Zsh 插件框架安装
8. **Tmux 插件** — TPM + 自动安装

## stow 管理

```bash
cd ~/.dotfiles
# 重新映射单个包
stow -vR nvim
# 卸载
stow -vD flameshot
# 添加新包: mkdir -p newpkg/.config/xxx && mv ~/.config/xxx/config newpkg/.config/xxx/
```

## .gitignore 排除项

- `secrets.zsh` — API key
- `profiles.yaml` — clash 订阅 token
- `.claude/` — Claude Code 本地权限
- `cached_layouts` — fcitx5 自动生成
- ipython 运行时数据（db/log/pid/security/history）
