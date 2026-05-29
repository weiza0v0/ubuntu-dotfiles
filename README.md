# Weizai0v0's Dotfiles
## 🌟 项目愿景与核心特性

### 1.1 设计理念
本配置集（Dotfiles）并非简单的工具堆砌，而是基于以下三个核心原则构建的生产力环境：
- **模块化解耦**：利用 `GNU Stow` 实现配置与系统目录的分离。每个组件（Zsh, Nvim, Tmux, Yazi）都是独立的原子模块，可按需加载。
- **配置即代码**：所有配置逻辑（如 Zsh 插件加载顺序、Neovim LSP 配置）均经过代码化管理，确保环境的可移植性与一致性。
- **跨平台互操作**：针对 WSL 2 环境进行了深度优化，打破 Linux 子系统与 Windows 宿主机之间的壁垒，实现资源与指令的无缝调用。

### 1.2 技术栈总览
| 维度 | 核心组件 | 亮点说明 |
| :--- | :--- | :--- |
| **Shell** | Zsh + Zimfw | 追求极致启动速度，相比 Oh-My-Zsh 提速约 3-5 倍 |
| **编辑器** | Neovim (Lazy.nvim) | 采用 LazyVim 理念，集成 LSP、DAP 及透明背景美化 |
| **复用器** | Tmux | 深度集成 Vim 风格导航，支持无缝跨窗口切换 |
| **文件管理** | Yazi | 基于 Rust 的高性能终端文件管理器，集成快速预览 |
| **集成互操作** | WSL Sync Tools | 独家 `upd-win`、`co` 等指令，直接操控宿主机应用 |

### 1.3 核心亮点：WSL 深度集成
这是本项目区别于普通配置的最大特色。通过 `wintools.zsh` 和 `win_sync.zsh`，你可以在 WSL 终端中：
- 使用 `co <path>` 调用宿主机 VS Code 打开任意路径（完美支持 UNC 路径）。
- 使用 `upd-win` 自动抓取 Windows 桌面快捷方式，并将其转化为 Linux 下的直接指令。

```zsh
# 示例：极致的互操作性
$co .              # 在 Windows VS Code 中打开当前目录$ upd-win           # 同步 Windows 软件，此后只需输入 'wx' 即可启动微信
```
## 🛠️ 快速开始 (一键部署)

本项目的安装脚本 `install.sh` 经过精心设计，支持从零构建完整的开发环境。它不仅会安装基础工具，还会自动下载最新的二进制文件并处理复杂的符号链接。

### 2.1 安装先决条件
- **系统要求**：推荐使用 **WSL 2 (Ubuntu/Debian)**。
- **权限要求**：脚本会尝试使用 `sudo` 安装系统级依赖（如 `stow`, `tmux` 等）。
- **工具准备**：确保系统已预装 `git` 和 `curl`。

### 2.2 一键安装流程
在终端中执行以下命令，脚本将自动完成系统更新、依赖安装、工具下载及配置映射：

```bash
# 1. 克隆仓库到本地
git clone https://github.com/weiza0v0/ubuntu-dotfiles.git ~/.dotfiles

# 2. 进入目录并执行安装脚本
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

### 2.3 脚本执行逻辑解析
为了让您了解脚本对系统做了什么，以下是 `install.sh` 的核心步骤：
1. **基础工具安装**：使用 `apt` 安装 `ripgrep`, `fd-find`, `stow`, `tmux`, `unzip` 等核心组件。
2. **Docker 自动部署**：检测环境并自动配置阿里云镜像源安装 Docker（仅限有 sudo 权限的环境）。
3. **第三方工具下载**：
    - 自动从 GitHub 获取 `Neovim`, `Lazygit`, `Yazi`, `FZF` 的最新版本。
    - 所有二进制文件统一存放在 `~/apps` 目录下，并软链接至 `~/.local/bin`。
4. **模块化映射 (Stow)**：
    - 脚本会调用 `clean_conflict` 函数自动备份旧的 `.zshrc`, `.tmux.conf` 等文件。
    - 使用 `stow -vR` 将 `zsh`, `tmux`, `nvim`, `yazi` 等模块映射到主目录。
5. **插件框架初始化**：自动安装 `Zimfw` 并触发插件下载。

### 2.4 安装后的必要手动操作
脚本完成后，请执行以下步骤以激活所有配置：

1. **切换默认 Shell**：
   ```bash
   chsh -s $(which zsh)
   ```
2. **进入 Zsh 并初始化插件**：
   打开新终端或输入 `zsh`，若未自动触发下载，请手动执行：
   ```zsh
   zimfw install
   ```
3. **Neovim 插件加载**：
   首次打开 `nvim` 时，`lazy.nvim` 会自动下载所有插件，请静候完成。
## 🖥️ 模块化配置详解

本项目采用模块化管理，核心逻辑分布在 `~/.zsh.d/`、`~/.config/nvim/` 及 `~/.tmux.conf` 中。以下是各模块的高级特性说明：

### 3.1 Zsh: 极速启动与智能工作流
基于 **Zimfw** 框架，通过精简插件和预编译脚本，实现了几乎零延迟的启动体验。
- **环境隔离 (`env.zsh`)**：深度集成 Conda 环境，通过 `eval $(conda shell.zsh hook)` 的延迟加载技术，避免了直接初始化导致的 shell 启动卡顿。
- **高效别名 (`alias.zsh`)**：
    - `v`: 快速唤起 Neovim。
    - `lg`: 快速唤起 Lazygit。
    - `ra`: 强化版 Yazi，退出时自动切换终端目录到最后浏览的位置。
    - `rfs`: 强制重载 Shell 环境并清理所有 Tmux 残留会话。

### 3.2 WSL 深度集成 (核心特色)
这是本项目最强悍的部分，通过 `wintools.zsh` 和 `win_sync.zsh` 彻底打通 WSL 与 Windows。

#### 1. 软件同步工具 (`upd-win`)
执行 `upd-win` 命令后，脚本会自动扫描 Windows 桌面的所有快捷方式，并为每个软件生成对应的 Linux 函数。
- **用法**：在 WSL 中直接输入 `wechat`、`qq` 或 `steam` 即可直接启动 Windows 端的程序。


#### 2. 跨系统调用 (`co` & `tm`)
- **`co <path>`**：调用 Windows 侧的 VS Code 打开指定路径。脚本会自动处理 `wslpath` 转换，支持 WSL 内部路径及 `/mnt/c/` 挂载路径。
- **`tm <path>`**：在 Windows Terminal 的新标签页中打开当前目录，解决 UNC 路径权限回退问题。

### 3.3 Neovim: 现代化 IDE 体验
- **UI 审美**：基于 `Catppuccin` 主题，并开启了 `transparent_background`（透明背景），与支持毛玻璃效果的终端完美适配。
- **开发增强**：
    - **Markdown 实验室**：通过 `<Leader>n` 快速创建带时间戳的草稿纸，随手记录灵感。
    - **自动格式化**：保存文件（`<Leader>w`）时自动触发 LSP 代码格式化。
    - **中英文输入优化**：自动集成 Windows 端的 `im-select`，在进入插入模式时自动切换输入法状态。
- 本配置已集成 Node.js 环境支持，确保 Mason 可自动安装并驱动高性能 LSP 服务。
### 3.4 Tmux: 终端复用与导航
- **前缀键**：修改为更为顺手的 `Ctrl-a`。
- **无缝导航**：集成了 `vim-tmux-navigator` 逻辑。你可以使用 `Ctrl-h/j/k/l` 在 Tmux 面板和 Neovim 窗口之间进行无感跳转。
- **纯字母派窗口管理**：
    - `Alt-t`: 新建窗口。
    - `Alt-h/l`: 左右切换窗口。
## ⌨️ 核心快捷键手册

为了实现“手不离键盘”的体验，本项目对各组件的快捷键进行了统一化处理。大部分操作都围绕着 `Leader` 键（Neovim/Tmux 中均映射为 `Space` 或 `Ctrl-a`）展开。

### 4.1 终端与复用器 (Tmux)
*前缀键 (Prefix) 已修改为 `Ctrl-a`*

| 快捷键 | 功能 | 备注 |
| :--- | :--- | :--- |
| `Ctrl-a` + `v` | 左右分屏 | 亦可使用 `|` |
| `Ctrl-a` + `s` | 上下分屏 | 亦可使用 `-` |
| `Alt-s` | **进入复制模式** | 免 Prefix 键，极速进入 |
| `Alt-t` | 新建窗口 (Tab) | 纯字母派映射 |
| `Alt-h` / `Alt-l` | 切换上/下一个窗口 | 逻辑与 Vim 一致 |
| **`Ctrl-h/j/k/l`** | **跨窗口/面板跳转** | **核心：** 无缝穿梭于 Tmux 与 Vim 窗口 |

### 4.2 现代化编辑器 (Neovim)
*Leader 键已设置为 `Space` (空格)*

#### 🚀 常用操作
- `<Leader> w`：保存当前文件并**自动触发代码格式化**。
- `<Leader> qq`：强制退出所有窗口（不保存）。
- `<Leader> r`：召唤/隐藏浮动终端（ToggleTerm）。
- `<Leader> n`：瞬间开启一个 Markdown 草稿本（自动存放在缓存区）。

#### 🔍 查找与导航 (Telescope)
- `<Leader> ff`：模糊搜索文件名。
- `<Leader> fg`：全局搜索文本内容（Live Grep）。
- `<Leader> fr`：打开最近访问的文件记录。
- `<Leader> e`：打开/关闭文件树。

#### 🐞 调试与开发 (DAP)
- `<F5>`：启动/继续调试。
- `<F10>` / `<F11>`：单步跳过 / 单步进入。
- `<Leader> b`：切换断点。
- `<Leader> dr`：开启/关闭调试 UI 界面。

### 4.3 智能 Shell (Zsh)
| 快捷键 / 指令 | 功能 |
| :--- | :--- |
| `Tab` | 触发 `fzf-tab`：使用模糊搜索来选择补全项 |
| `Ctrl-r` | 历史命令搜索：基于 FZF 的模糊过滤 |
| `v <file>` | 使用 Neovim 打开 |
| `ra` | 打开 Yazi：退出时会自动 `cd` 到最后停留的目录 |
| `lg` | 打开 Lazygit：终端级 Git 客户端 |
| `rfs` | **终极重载**：清理所有 Tmux 会话并刷新 Zsh 环境 |

### 4.4 路径寄存器 (g 指令)
- **标记**：`g <name> .`（例如 `g wk .` 将当前目录标记为 wk）。
- **跳转**：`g <name>`（直接输入 `g wk` 回到该目录）。
- **查看**：直接输入 `g` 查看当前所有活跃的寄存器。
## 🔄 维护与进阶指南

本项目基于 **GNU Stow** 构建，这使得管理配置文件像管理软件包一样简单。

### 5.1 日常维护工作流
当你修改了某个配置（例如 `.zshrc` 或 Neovim 的插件配置）后，只需按照标准的 Git 流程操作即可：

```bash
cd ~/.dotfiles
# 查看修改
git status
# 提交并推送到远程仓库
git add .
git commit -m "feat: 更新了 zsh 别名和 nvim 主题"
git push
```

### 5.2 使用 Stow 管理模块
`stow` 会在你的家目录创建指向 `~/.dotfiles` 内部文件的**软链接**。这意味着你对 `~/.dotfiles` 目录内文件的修改会实时生效。

- **重新映射模块**（如配置失效时）：
  ```bash
  cd ~/.dotfiles
  stow -vR nvim   # -R 表示先卸载再重新映射
  ```
- **添加新模块**：
  假设你要添加 `htop` 的配置：
  1. 在 `~/.dotfiles` 下创建目录：`mkdir -p htop/.config/htop`
  2. 移动配置文件：`mv ~/.config/htop/htoprc htop/.config/htop/`
  3. 执行映射：`stow htop`

### 5.3 进阶：WSL 权限与路径问题
由于 WSL 与 Windows 系统的互操作性，可能会遇到权限或路径映射报错：

- **Compaudit 警告**：
  若 Zsh 提示 `Insecure completion-dependent directories`，通常是 Windows 挂载盘权限过高。本项目已在 `.zshrc` 中加入了部分修复逻辑，若仍报错，可执行：
  ```bash
  compaudit | xargs chmod g-w,o-w
  ```
- **Windows 路径映射失效**：
  如果 `co` 或 `upd-win` 指令无法执行，请检查 Windows 端的 `powershell.exe` 是否在系统 PATH 中，并确保 WSL 能够调用 `.exe` 后缀的文件（默认开启）。

### 5.4 故障排除 (FAQ)
- **Q: 为什么新安装的 Zsh 插件没生效？**
  - **A**: 运行 `zimfw install` 后，尝试执行 `rfs`（本项目内置的强力重载别名）。
- **Q: 为什么 Tmux 里的颜色显示不正常？**
  - **A**: 本配置强制开启了 `truecolor` 支持，请确保你使用的终端（如 Windows Terminal, Alacritty）已支持 24-bit color。
- **Q: `upd-win` 找不到我的软件？**
  - **A**: 该脚本默认扫描 `C:\Users\你的用户名\Desktop` 下的快捷方式，请确保软件快捷方式在桌面上。
## 🎁 特别鸣谢

本项目的构建与优化离不开以下“赛博伙伴”的深度协作：

* **[Gemini 3 Flash](https://deepmind.google/technologies/gemini/)**：作为本项目的“首席架构师”，负责了底层 `install.sh` 脚本的逻辑重构、WSL 路径映射的兼容性修复，以及整份 README 文档的撰写与润色。
* **[DeepSeek](https://www.deepseek.com/)**：在 Neovim Lua 配置调优、Zsh 补全系统报错排查以及复杂正则逻辑的编写中提供了关键的灵感与代码支持。

> **AI + Human Workflow**：本项目是典型的“人机协作”产物，由作者提供核心需求与审美导向，AI 负责繁琐的兼容性调试与文档工程，共同打磨出这套追求极致体验的 Dotfiles。
