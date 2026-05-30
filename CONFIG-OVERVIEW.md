# Dotfiles 配置总览

> 仓库：`~/.dotfiles` | 远程：`git@github.com:weizaiz0v0/ubuntu-dotfiles.git`  
> 管理方式：GNU Stow | 生成时间：2026-05-30

---

## 仓库结构（共 25 个 Stow 包 + 脚本/文档）

| 分类 | 包名 | 用途 | 目标路径 |
|------|------|------|----------|
| Shell | `zsh` | Zsh 配置 + Zim 框架 + 插件 | `~/.zshrc`, `~/.zimrc`, `~/.zsh.d/` |
| Shell | `bash` | Bash 备用配置 | `~/.bashrc`, `~/.profile` |
| 终端 | `tmux` | 终端复用器 | `~/.tmux.conf`, `~/.config/tmux/` |
| 终端 | `ghostty` | GPU 终端模拟器 + GLSL 着色器 | `~/.config/ghostty/` |
| 终端 | `starship` | 跨 Shell 提示符 | `~/.config/starship.toml` |
| 终端 | `fastfetch` | 系统信息展示 | `~/.config/fastfetch/` |
| 编辑器 | `nvim` | Neovim (Lazy.nvim) | `~/.config/nvim/` |
| 编辑器 | `vscode` | VS Code 设置 | `~/.config/Code/User/` |
| 开发 | `claude` | Claude Code CLI 主题 | `~/.claude/settings.json` |
| 开发 | `conda` | Anaconda 配置 | `~/.condarc` |
| 开发 | `condaEnvs` | 数据分析环境依赖 | 独立文件（requirements） |
| 开发 | `lazygit` | Git TUI | `~/.config/lazygit/` |
| 开发 | `ipython` | IPython 配置 | `~/.ipython/` |
| 工具 | `bin` | 自定义脚本 | `~/.local/bin/` |
| 工具 | `scripts` | 安装/系统脚本 | 独立文件（非 stow） |
| 桌面 | `gnome` | GNOME 桌面环境 | `~/.config/glib-2.0/`, `~/.config/gtk-3.0/` |
| 网络 | `clash-verge` | 代理客户端配置 + deb | `~/.config/clash-verge/` |
| 输入法 | `fcitx5` | 中文输入法（拼音） | `~/.config/fcitx5/` |
| 应用 | `flameshot` | 截图工具 | `~/.config/flameshot/` |
| 应用 | `fsearch` | 文件搜索工具 | `~/.config/fsearch/` |
| 应用 | `htop` | 系统监控 | `~/.config/htop/` |
| 应用 | `pavucontrol` | 音频控制 | `~/.config/pavucontrol.ini` |
| 应用 | `yazi` | 终端文件管理器 | `~/.config/yazi/` |
| 占位 | `build` | 空目录（预留） | - |

---

## 1. Shell 配置

### 1.1 Zsh（主 Shell）

**入口文件：`zsh/.zshrc`**

| 设置 | 值 |
|------|-----|
| 补全系统 | 跳过全局 compinit，使用 Zim 补全 |
| 环境变量 | `source ~/.zsh.d/env.zsh` |
| Zim 框架 | `ZIM_HOME=~/.zim` |
| FZF 集成 | 使用 fzf-tab，cd 预览用 `ls --color=always` |
| 加载顺序 | `alias.zsh` → `plugin.zsh` → `tools/path_alias.zsh` → `secrets.zsh` |
| 按键绑定 | vi-mode (`bindkey -v`)，`^B` 书签，`^O` 插入书签 |
| Kitty 检测 | 若在 Kitty 中则设置 `MPLBACKEND=module://matplotlib-backend-kitty` |
| 提示符 | Starship |
| 系统信息 | 仅在本地桌面环境（非 SSH/VS Code/JetBrains/tmux）启动 fastfetch |

**Zim 模块（`zsh/.zimrc`）：**

| 模块 | 用途 |
|------|------|
| `environment` | Zsh 内置选项 |
| `git` | Git 别名 |
| `input` | 终端输入映射 |
| `termtitle` | 终端标题 |
| `utility` | 实用别名，`ls`/`grep` 着色 |
| `zsh-users/zsh-completions` | 额外补全定义 |
| `completion` | 智能 Tab 补全 |
| `Aloxaf/fzf-tab` | 模糊补全 |
| `fast-syntax-highlighting` | Fish 式语法高亮 |
| `zsh-users/zsh-history-substring-search` | 历史子串搜索 |
| `zsh-users/zsh-autosuggestions` | 自动建议 |
| `pabloariasal/zfm` | Zsh 文件管理器 |

**环境变量（`zsh/.zsh.d/env.zsh`）：**

- **PATH**：`~/.local/bin`, `~/.apps/fzf/bin`, `/usr/local/cuda/bin`
- **输入法**：`GTK_IM_MODULE=fcitx5`, `QT_IM_MODULE=fcitx5`, `XMODIFIERS=@im=fcitx5`
- **LD_LIBRARY_PATH**：`/usr/lib/wsl/lib`, `/usr/local/cuda/lib64`
- **编辑器**：`EDITOR=nvim`, `VISUAL=nvim`, `TERM=xterm-256color`, `COLORTERM=truecolor`
- **Conda 懒加载**：定义 `conda()`/`mamba()` 函数，首次调用时才 source conda.sh，节省 ~350ms 启动时间
- **OpenSSL**：`OPENSSL_MODULES=~/.apps/anaconda3/lib/ossl-modules`（修复 conda OpenSSL 版本不匹配警告）
- **FZF 配色**：13 色自定义配色方案，`fd` 作为默认搜索命令

**别名（`zsh/.zsh.d/alias.zsh`）：**

| 别名 | 展开 |
|------|------|
| `ls` | `ls --color=auto` |
| `ll` | `ls -lh` |
| `la` | `ls -A` |
| `grep` | `grep --color=auto` |
| `v` | `nvim` |
| `lg` | `lazygit` |
| `tl` | `tmux ls` |
| `ta` | `tmux attach -t` |
| `tn` | `tmux new -s` |
| `cdp` | `cd ~/projects` |
| `cdd` | `cd ~/.dotfiles` |
| `cal` | `conda activate DataAnalysis && ipython` |
| `rfs` | 杀掉所有 tmux 后 `exec zsh` |

**路径别名系统（`zsh/.zsh.d/tools/path_alias.zsh`）：**
- 持久化别名到 `~/.cache/zsh_temp_aliases.sh`，通过 `precmd` hook 自动重载
- `addp <name> [path]` — 添加持久化 cd 别名
- `rmp <alias>` — 移除别名
- `lsp` — 列出所有路径别名
- `arcp [-k] [path]` — 归档目录为 `.tar.gz` 到 `/mnt/d/02_Work/Archive/`，默认删除源目录（`-k` 保留）
- `ra()` — 启动 yazi，退出时自动 cd 到 yazi 最后所在目录

### 1.2 Bash（备用 Shell）

**`bash/.bashrc`:**
- 基于 Ubuntu 默认 `.bashrc` 模板
- `HISTCONTROL=ignoreboth`, `HISTSIZE=1000`, `HISTFILESIZE=2000`
- 彩色提示符（绿色 `user@host` + 蓝色路径）
- `lesspipe` 支持，`dircolors`
- `ll='ls -alF'`, `la='ls -A'`, `l='ls -CF'`
- `alert` 别名：长命令完成后发送桌面通知
- Bash 补全支持

**`bash/.profile`:**
- 检测 Bash 后 source `~/.bashrc`
- PATH 添加 `~/bin` 和 `~/.local/bin`

---

## 2. 终端工具

### 2.1 tmux

**`tmux/.tmux.conf`:**

| 配置 | 值 |
|------|-----|
| 前缀键 | `Ctrl+a`（原 `Ctrl+b` 已解绑） |
| 鼠标 | 全局启用 |
| 模式键 | vi |
| 终端类型 | `tmux-256color` |
| 分屏 | `prefix+v`（右），`prefix+s`（下） |
| 窗口 | `Alt+t` 新建，`Alt+h/l` 切换，`Alt+w` 关闭 |
| 复制模式 | `Alt+s` 进入，`v` 选择，`y` 复制（xclip） |
| 智能导航 | `Ctrl+hjkl` — vim 内传递按键，tmux 内切换窗格 |
| 状态栏 | 左：会话名，右：日期时间 + 系统负载 |

**`tmux/.config/tmux/help`** — 帮助参考卡片（中英双语），`prefix+?` 显示

### 2.2 Ghostty

**`ghostty/.config/ghostty/config`:**

| 配置 | 值 |
|------|-----|
| 主题 | Ubuntu（前景色 `#aaaaaa` 柔化） |
| 字体 | JetBrainsMono Nerd Font Mono, 19pt |
| 光标 | 竖线（bar），青色 `#00e5ff`，无闪烁，自定义 trail 着色器 |
| 窗口 | 启动最大化，黑色标题栏 |
| 鼠标 | 复制不自动选中，右击=复制并粘贴 |

**GLSL 着色器：**
- `cursor_tail.glsl` (~240行) — 带动画的鼠标拖尾效果，支持对角线平行四边形几何、SDF 抗锯齿、9 种缓动函数

### 2.3 Starship

**`starship/.config/starship.toml`（约365行）：**

```
hostname → directory → git_branch → git_state → git_status →
conda → cmd_duration → time → [newline] → character
```

| 模块 | 配置 |
|------|------|
| 目录 | 截断到 3 层，只读时显示 🔒 |
| Git | 分支 + 状态（冲突/前后/未跟踪/暂存/修改等） |
| 命令时长 | >1s 显示，精确到毫秒 |
| 时间 | `%T` 格式（HH:MM:SS） |
| 主机名 | 仅 SSH 时显示 |
| Conda | 显示环境名（含 base） |
| 提示符 | 成功=绿色箭头，失败=红色箭头 |
| 状态 | 错误时显示 `✗` 和退出码 |

后半部分为所有支持的编程语言/生态系统的 Nerd Font 图标映射（包含44个操作系统符号）。

### 2.4 fastfetch

**`fastfetch/.config/fastfetch/config.jsonc`：**
- Logo：从 `logo.txt` 加载自定义 ASCII art，6 色映射（红/黄/绿/青/蓝/紫）
- 显示模块：OS → Host → Kernel → Uptime → Packages → Shell → DE → WM → Terminal → CPU → GPU → Memory → Disk → LocalIP → Display → DateTime → Colors
- 分隔符：` → `

---

## 3. 编辑器

### 3.1 Neovim

**`nvim/.config/nvim/init.lua`：**

| 分类 | 配置 |
|------|------|
| 基础 | `<Space>` 作为 Leader，绝对+相对行号，真彩色，Wayland 剪贴板（xclip），禁用 swap 文件，4 空格缩进 |
| 插件管理 | lazy.nvim 自动引导安装 |
| 主题 | Catppuccin（透明背景，终端颜色） |
| LSP | mason.nvim 自动安装 `pyright`/`clangd`/`lua_ls` |
| Treesitter | `lua`/`python`/`c` 语法高亮 |
| 补全 | nvim-cmp（LSP + LuaSnip），`<CR>` 确认，`<Tab>` 下一项 |
| 终端 | toggleterm.nvim |
| 导航 | vim-tmux-navigator（tmux 窗格无缝导航） |
| 输入法 | fcitx5 自动切换（进入插入/命令模式→英文，离开→中文） |
| 快捷键 | `<leader>qq` → `:qa!` |

**锁文件：** `lazy-lock.json` 锁定 14 个插件到精确 commit。

### 3.2 VS Code

**`vscode/.config/Code/User/settings.json`：**

| 分类 | 配置 |
|------|------|
| Claude Code 扩展 | 使用 DeepSeek API（`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`），模型 `deepseek-v4-pro`/`deepseek-v4-flash`，面板模式 |
| 主题 | Dracula |
| 字体 | 全局 25px（编辑器/终端/聊天/调试/笔记本等全部统一） |
| Vim 扩展 | 系统剪贴板，fcitx5 自动切换（同 nvim） |
| 侧栏 | 右侧 |
| AI 功能 | 禁用内置 Copilot/Chat |

---

## 4. 开发工具

### 4.1 Claude Code

**`claude/.claude/settings.json`：**
```json
{ "theme": "dark" }
```

### 4.2 Conda

**`conda/.condarc`：**
- 频道：仅 `defaults`
- 不修改 PS1（`changeps1: false`）

**`condaEnvs/dataAnalysisRequirements`** — 数据分析环境依赖：
- 科学计算：`numpy`, `pandas`, `scipy`
- 机器学习：`torch`/`torchvision`/`torchaudio`, `scikit-learn`, `xgboost`, `lightgbm`, `catboost`
- 可视化：`matplotlib`, `seaborn`, `plotly`
- Jupyter 生态：`jupyter`, `ipykernel`, `ipywidgets`
- 特征工程：`feature-engine`（可选）
- 模型解释：`shap`, `eli5`（可选）
- 超参调优：`optuna`, `hyperopt`（可选）
- 计算机视觉：`opencv-python`, `ultralytics`
- 工具：`joblib`, `tqdm`, `pyyaml`, `rich`

### 4.3 IPython

**`ipython/.ipython/profile_default/ipython_config.py`：**
- 自动加载 `icat` 扩展（Kitty 终端内嵌图像显示）

### 4.4 Lazygit

**`lazygit/.config/lazygit/config.yml`** — 空文件，使用全部默认设置。

### 4.5 bin（自定义脚本）

**`bin/.local/bin/fcitx5-switch.sh`：**
- VS Code Vim 扩展调用，切换 fcitx5 输入法
- 参数 `1` → `fcitx5-remote -c`（英文）
- 参数 `2` → `fcitx5-remote -o`（中文）

---

## 5. 部署脚本

### 5.1 `scripts/install.sh`

一键部署脚本，共 7 个阶段：

| 阶段 | 内容 |
|------|------|
| 系统包 | ~40 apt 包（zsh/git/tmux/ripgrep/fd-find/stow/fcitx5/开发库等） |
| 第三方 | Docker（阿里云镜像）、Ghostty（PPA）、Starship、VS Code、Chrome、Claude Code（npm） |
| 键盘 | Kanata（Caps→Esc/Ctrl，systemd 服务）、toggle-caps（setuid） |
| 自包含应用 | Anaconda、Lazygit、Yazi、Neovim Nightly、FZF、Nerd Font（全到 `~/.apps/`） |
| Stow 映射 | ~20 个包，冲突文件备份到 `.bak_YYYYMMDD` |
| GNOME | `dconf load / < gnome-dconf.ini` |
| Zimfw + Tmux 插件 | Zim 框架 + TPM 插件安装 |

### 5.2 `scripts/kanata.kbd`

键盘重映射：CapsLock `tap=Esc`, `hold=Ctrl`，超时 200ms。

### 5.3 `scripts/toggle-caps`

ELF 二进制，通过 `/dev/uinput` 切换 CapsLock LED 状态，安装为 setuid root。

### 5.4 `scripts/gnome-dconf.ini`

完整 GNOME 桌面环境导出配置。关键设置：

| 类别 | 配置 |
|------|------|
| 终端 | Ptyxis，JetBrainsMono Nerd Font Ultra-Bold 10pt，块光标，透明度 0.80 |
| 外观 | `prefer-dark`，Yaru-dark 主题和图标，壁纸 `mizuno-as-Big_Dipper.jpg` |
| 输入法 | US English 键盘，逐窗口输入状态 |
| 快捷按键 | `Super+F12`=切换 CapsLock，`Ctrl+1`=Flameshot 截图 |
| 电源 | 息屏=从不，交流电休眠=从不（超时 1h） |
| Dock | Chrome, Ghostty, 文件管理器, FSearch, VS Code, Clash Verge, 扩展管理器, WPS, Zotero |
| 扩展 | kimpanel, openbar, ubuntu-dock, ubuntu-appindicators, ding, auto-move-windows, tiling-assistant, rounded-window-corners |
| 圆角 | border-radius=23, border-width=20, smoothing=0.3, padding=1px |
| 模糊效果 | Kitty/Ptyxis 应用模糊（sigma=35, brightness=0.65），面板模糊（sigma=30, brightness=0.60） |
| 夜灯 | 启用，手动排程，色温 3804K |
| 代理 | HTTP/HTTPS/SOCKS → `127.0.0.1:7897`（Clash Verge） |
| 隐私 | 关闭技术问题报告 |
| 文件选择器 | 显示隐藏文件，目录优先，按大小排序 |
| 应用抽屉 | "键盘自救"/"通讯"/"办公" 分组 |

### 5.5 `scripts/dump-gnome.sh`

运行 `dconf dump / > gnome-dconf.ini`，用于导出当前 GNOME 设置到迁移文件。

---

## 6. GNOME 桌面（glib/gtk）

### `gnome/.config/glib-2.0/settings/keyfile`
- 默认终端=`/usr/bin/ghostty`
- 圆角窗口扩展：radius=12px, padding=4px, border=2px 灰色

### `gnome/.config/gtk-3.0/bookmarks`
- 中文本地化的 XDG 目录书签（文档/音乐/图片/视频/下载）

---

## 7. 网络代理（Clash Verge）

| 文件 | 说明 |
|------|------|
| `clash-verge.deb` | v2.5.1 离线安装包，~80MB |
| `verge.yaml` | GUI 设置：中文界面，系统代理，TUN 模式，mihomo 内核 |
| `config.yaml` | Mihomo 核心配置桩：端口 7895-7899 |
| `clash-verge.yaml` / `clash-verge-check.yaml` | 完整代理配置（相同） |
| `dns_config.yaml` | 独立 DNS 配置 |
| `profiles.yaml` | 订阅管理（gitignored，含订阅 token） |

**代理概况：**

| 类型 | 数量 | 说明 |
|------|------|------|
| VLESS+Reality+gRPC | 15 | HK/JP/KR/SG/US 节点，link-t7.com |
| Hysteria2 | 17 | HK/JP/SG/US 节点，dexlos.com |
| Shadowsocks | 1 | US 节点 |
| TUIC | 10 | TW 节点（端口 8080, v5, h3） |

**路由规则：** 23 个代理组（主代理/自动选择/负载均衡/区域组/应用组），26 个规则提供者，按服务分流。

**DNS：** Fake-IP 模式，多组 nameserver（国内/直连/回落/代理）。

---

## 8. 输入法（fcitx5）

**`fcitx5/.config/fcitx5/config`：**
- 切换键：`Ctrl+Space`
- 分组切换：`Super+Space`
- 候选词翻页：`Up/Down` 或 `Shift+Tab`/`Tab`
- 每页 5 个候选词，30 分钟自动保存
- 默认非激活状态，逐窗口输入状态

**`fcitx5/.config/fcitx5/profile`：**
- 默认布局：US English
- 默认输入法：拼音
- 输入法列表：键盘-英语 + 拼音

**`fcitx5/.config/fcitx5/conf/pinyin.conf`：**
- 双拼方案：自然码
- 每页 7 个候选词
- 模糊音：仅 `VE→UE`, `NG→GN`, 内/短内模糊
- 云拼音：关闭
- 预测：关闭

**`fcitx5/.config/fcitx5/conf/punctuation.conf`：**
- 启用标点模块
- 字母/数字后半角标点
- 成对标点：分别输入（不配对）

---

## 9. 桌面应用

### 9.1 FSearch（文件搜索）

| 配置 | 值 |
|------|------|
| 窗口 | 850×600，列表视图 |
| 可见列 | 名称(250px), 路径(250px), 大小(75px), 修改时间(125px) |
| 排序 | 按名称升序 |
| 搜索 | 输入即搜，自动匹配大小写 |
| 数据库 | 启动时更新，每 15 分钟更新，不排除隐藏文件 |
| 排除目录 | `/proc`, `/sys` |
| 预定义过滤器 | 全部/文件夹/文件/应用程序/归档/音频/文档/图片/视频 |

### 9.2 htop

- 显示列：PID, USER, PRIORITY, NICE, VIRT, RES, SHR, STATE, CPU%, MEM%, TIME, Command
- 隐藏内核线程，显示程序路径
- 刷新间隔 1.5s
- 排序：按 CPU% 降序
- 双列布局：左侧=CPU+内存+交换，右侧=CPU+任务+负载+运行时间
- 额外屏幕 "I/O"：按 IO_RATE 排序

### 9.3 Yazi

| 配置 | 值 |
|------|------|
| 显示隐藏文件 | true |
| 排序 | 按修改时间降序（最新在前） |

### 9.4 Pavucontrol

- 窗口 500×400
- Sink 输入/源输出：列表模式
- Sink/源：卡片模式
- 显示音量表

### 9.5 Flameshot

配置文件为空，使用全部默认设置。

---

## 10. 部署与维护

### 部署流程

```bash
tar -xzf dotfiles.tar.gz -C ~/
bash ~/.dotfiles/scripts/install.sh
chsh -s $(which zsh)
```

### Stow 管理

```bash
# 重新映射单个包
cd ~/.dotfiles && stow -vR <pkg>

# 取消映射
stow -vD <pkg>

# 添加新配置
mkdir -p newpkg/.config/xxx
mv ~/.config/xxx/config newpkg/.config/xxx/
```

### .gitignore 排除

| 文件/模式 | 原因 |
|-----------|------|
| `secrets.zsh` | API 密钥（Anthropic token） |
| `clash-verge/profiles.yaml` | 订阅 token |
| `/.claude` | Claude Code 本地权限数据 |
| `fcitx5/.../cached_layouts` | 自动生成缓存 |
| `ipython/` 运行时数据 | db/log/pid/security/history |

### Changelog

每次配置变更的详细记录在 `CHANGELOG.md` 中，包含改动内容、原因、踩坑记录和恢复方式。详见仓库根目录的 `CHANGELOG.md` 文件。

### 常见问题速查

| 症状 | 原因 | 修复 |
|------|------|------|
| `conda` 找不到 | 过期的 zsh 编译缓存 | `rm -rf ~/.cache/fsh ~/.zcompdump* && exec zsh` |
| `__conda_exe: bad interpreter` | conda 二进制 shebang 含旧路径 | mass sed 替换所有硬编码路径 |
| stow 创建错误符号链接 | 已有实体文件存在 | `clean_conflict` 备份为 `.bak_YYYYMMDD` |
| OpenSSL 警告 | conda OpenSSL 3.0 vs 系统 3.5 | 设置 `OPENSSL_MODULES` 环境变量 |

---

> 此文件由 6 个子 agent 并行扫描 `~/.dotfiles/` 仓库全部配置文件后汇总生成。
