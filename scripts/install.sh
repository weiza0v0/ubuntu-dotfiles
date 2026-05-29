#!/bin/bash
# =================================================================
# 极致模块化环境安装脚本
# =================================================================

set -e
trap 'echo "❌ 行号 $LINENO 发生错误。安装中止。"' ERR

echo "🚀 启动【极致模块化】环境安装..."

# 0. 确保基础路径存在
mkdir -p ~/.apps
mkdir -p ~/.local/bin
mkdir -p ~/.config

# 1. 基础系统工具安装
echo "📦 安装系统依赖..."
if [ "$EUID" -eq 0 ] || command -v sudo &>/dev/null; then
  sudo apt update -qq && sudo apt install -y -qq \
    zsh git curl wget build-essential cmake gdb \
    ripgrep fd-find xclip stow tmux unzip zip jq \
    npm nodejs \
    fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk2 fcitx5-frontend-gtk3 fcitx5-frontend-qt5 fcitx5-configtool \
    fastfetch htop flameshot fsearch pavucontrol \
    vlc gimp ffmpeg timg pandoc gamemode fonts-jetbrains-mono \
    gnome-shell-extension-manager \
    libboost-all-dev libeigen3-dev libfmt-dev libspdlog-dev libyaml-cpp-dev \
    tree >/dev/null 2>&1 || echo "⚠️ 系统包安装失败，继续..."
else
  echo "⚠️ 无 sudo 权限，跳过系统包更新。"
fi

# Grub: NVMe 延迟修复（减少 SSD 功耗导致的卡顿）
if [ "$EUID" -eq 0 ] || command -v sudo &>/dev/null; then
  if ! grep -q "nvme_core.default_ps_max_latency_us" /etc/default/grub 2>/dev/null; then
    echo "🛠 应用 NVMe 延迟修复到 Grub..."
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvme_core.default_ps_max_latency_us=2000"/' /etc/default/grub
    sudo update-grub
  fi
fi

# 2. Docker 安装 (仅限 WSL/本地)
if ! command -v docker &>/dev/null && ([ "$EUID" -eq 0 ] || command -v sudo &>/dev/null); then
  echo "🐳 安装 Docker (阿里云源)..."
  sudo apt-get update -qq && sudo apt-get install -y -qq ca-certificates gnupg >/dev/null
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update -qq && sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null
  sudo usermod -aG docker $USER || true

  # 配置 Docker 镜像加速
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://huecker.io",
    "https://dockerhub.timeweb.cloud"
  ]
}
EOF
  echo "✅ Docker 配置完成。"
fi

# Ghostty 终端
if ! command -v ghostty &>/dev/null && ([ "$EUID" -eq 0 ] || command -v sudo &>/dev/null); then
  echo "🖥️ 安装 Ghostty..."
  sudo apt-get install -y -qq software-properties-common
  sudo add-apt-repository -y ppa:ghostty/ppa
  sudo apt-get update -qq && sudo apt-get install -y -qq ghostty
fi

# Starship 提示符
if ! command -v starship &>/dev/null; then
  echo "🌟 安装 Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# VS Code (Microsoft 源)
if ! command -v code &>/dev/null && ([ "$EUID" -eq 0 ] || command -v sudo &>/dev/null); then
  echo "📝 安装 VS Code..."
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | \
    sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.sources
  sudo apt update -qq && sudo apt install -y -qq code
fi

# Google Chrome
if ! command -v google-chrome &>/dev/null && ([ "$EUID" -eq 0 ] || command -v sudo &>/dev/null); then
  echo "🌐 安装 Google Chrome..."
  wget -qO- https://dl.google.com/linux/linux_signing_key.pub | \
    sudo tee /etc/apt/keyrings/google-chrome.gpg >/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | \
    sudo tee /etc/apt/sources.list.d/google-chrome.sources
  sudo apt update -qq && sudo apt install -y -qq google-chrome-stable
fi

# Claude Code (npm 全局安装)
if ! command -v claude &>/dev/null && command -v npm &>/dev/null; then
  echo "🤖 安装 Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi

# Kanata 键盘重映射
if ! command -v kanata &>/dev/null; then
  echo "⌨️ 安装 Kanata..."
  KANATA_VER=$(curl -s "https://api.github.com/repos/jtroo/kanata/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || true)
  [ -z "$KANATA_VER" ] && KANATA_VER="1.8.0"
  curl -fSLo /tmp/kanata "https://github.com/jtroo/kanata/releases/download/v${KANATA_VER}/kanata"
  chmod +x /tmp/kanata
  sudo mv /tmp/kanata /usr/local/bin/kanata
  # 部署配置文件
  if [ -f "$HOME/.dotfiles/scripts/kanata.kbd" ]; then
    sudo cp "$HOME/.dotfiles/scripts/kanata.kbd" /etc/kanata.kbd
  fi
  # 设置 systemd 服务 (可选，开机自启)
  if [ ! -f /etc/systemd/system/kanata.service ]; then
    sudo tee /etc/systemd/system/kanata.service <<-'EOS'
[Unit]
Description=Kanata key remapper
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/kanata --cfg /etc/kanata.kbd
Restart=on-failure
RestartSec=3
Nice=-10

[Install]
WantedBy=multi-user.target
EOS
    sudo systemctl enable --now kanata
  fi
fi

# --- 3. 安装软件本体到 ~/.apps 或 ~/.local/bin ---

# 安装 Anaconda
if [ ! -d "$HOME/apps/anaconda3" ]; then
  echo "🐍 安装 Anaconda..."
  # 获取最新版本号
  ANACONDA_VER=$(curl -s https://repo.anaconda.com/archive/ | grep -oP 'Anaconda3-\K[0-9]+\.[0-9]+-[0-9]+(?=-Linux-x86_64\.sh)' | sort -V | tail -1 || true)
  if [ -z "$ANACONDA_VER" ]; then
    ANACONDA_VER="2025.12-2"
  fi
  curl -fSLo anaconda.sh "https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VER}-Linux-x86_64.sh"
  bash anaconda.sh -b -p $HOME/apps/anaconda3 && rm anaconda.sh
fi

# 安装 Lazygit
if [ ! -f "$HOME/apps/lazygit/bin/lazygit" ]; then
  echo "📦 安装 Lazygit..."
  mkdir -p ~/.apps/lazygit/bin
  LG_VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || true)
  if [ -z "$LG_VER" ]; then
    echo "⚠️ GitHub API 受限，使用备用版本..."
    LG_VER="0.45.0"
  fi
  curl -fSLo lg.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
  tar xf lg.tar.gz lazygit && mv lazygit ~/.apps/lazygit/bin/ && rm lg.tar.gz
fi

# 安装 Yazi
if [ ! -f "$HOME/apps/yazi/bin/yazi" ]; then
  echo "📂 安装 Yazi..."
  mkdir -p ~/.apps/yazi/bin
  Y_URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
  curl -Lo yazi.zip "$Y_URL"
  mkdir -p yazi_temp && unzip -q yazi.zip -d yazi_temp
  # 查找并移动二进制文件，不依赖固定目录名
  find yazi_temp -name yazi -type f -exec mv {} ~/.apps/yazi/bin/ \; 2>/dev/null || true
  find yazi_temp -name ya -type f -exec mv {} ~/.apps/yazi/bin/ \; 2>/dev/null || true
  rm -rf yazi.zip yazi_temp
fi

# 安装 Neovim (Nightly)
if [ ! -f "$HOME/apps/nvim/bin/nvim" ]; then
  echo "💤 安装 Neovim (Nightly)..."
  mkdir -p ~/.apps/nvim
  NV_URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
  curl -fSLo nvim.tar.gz "$NV_URL" || {
    echo "⚠️ Neovim nightly 下载失败，尝试使用稳定版..."
    NV_VER=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "\K[^"]*' || true)
    [ -z "$NV_VER" ] && NV_VER="v0.10.4"
    curl -fSLo nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NV_VER}/nvim-linux-x86_64.tar.gz"
  }
  tar -xzf nvim.tar.gz -C ~/.apps/nvim --strip-components=1 && rm nvim.tar.gz
fi

# 安装 FZF
if [ ! -d "$HOME/apps/fzf" ]; then
  echo "🔍 安装 FZF..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.apps/fzf >/dev/null
  ~/.apps/fzf/install --bin --no-bash --no-zsh --no-fish >/dev/null
fi

# 安装 Nerd Font (Yazi/终端图标依赖)
if ! fc-list 2>/dev/null | grep -qi nerd; then
  echo "🔤 安装 Nerd Font (JetBrainsMono)..."
  mkdir -p ~/.local/share/fonts
  curl -fSLo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -qo /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/
  rm /tmp/JetBrainsMono.zip
  fc-cache -f ~/.local/share/fonts/ >/dev/null 2>&1 || true
fi

# 设置 Fcitx5 为默认输入法框架
if command -v fcitx5 &>/dev/null; then
  echo "⌨️ 配置 Fcitx5 输入法..."
  im-config -n fcitx5 2>/dev/null || true
fi


# --- 4. 执行 Stow 自动映射配置 (核心修正区) ---
echo "🔗 执行 Stow 自动映射配置..."

if ! command -v stow &>/dev/null; then
  echo "❌ stow 未安装，跳过配置映射。请先安装: sudo apt install stow"
else
  if [ -d "$HOME/.dotfiles" ]; then
  cd "$HOME/.dotfiles"

  clean_conflict() {
    local target=$1
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ ! -L "$target" ]; then
        echo "⚠️  发现真实冲突项 $target，已备份至 .bak"
        mv "$target" "${target}.bak_$(date +%Y%m%d)"
      fi
    fi
  }

  # 清理可能存在的冲突
  clean_conflict "$HOME/.zshrc"
  clean_conflict "$HOME/.zimrc"
  clean_conflict "$HOME/.zsh.d"
  clean_conflict "$HOME/.tmux.conf"
  clean_conflict "$HOME/.tmux"
  clean_conflict "$HOME/.config/nvim"
  clean_conflict "$HOME/.config/yazi"
  clean_conflict "$HOME/.bashrc"
  clean_conflict "$HOME/.profile"
  clean_conflict "$HOME/.condarc"
  clean_conflict "$HOME/.config/fastfetch"
  clean_conflict "$HOME/.config/ghostty"
  clean_conflict "$HOME/.config/htop"
  clean_conflict "$HOME/.config/lazygit"
  clean_conflict "$HOME/.config/flameshot"
  clean_conflict "$HOME/.config/fsearch"
  clean_conflict "$HOME/.config/fcitx5"
  clean_conflict "$HOME/.config/starship.toml"
  clean_conflict "$HOME/.config/pavucontrol.ini"
  clean_conflict "$HOME/.ipython"
  clean_conflict "$HOME/.config/Code/User/settings.json"
  clean_conflict "$HOME/.config/Code/User/chatLanguageModels.json"
  clean_conflict "$HOME/.config/glib-2.0/settings/keyfile"
  clean_conflict "$HOME/.config/gtk-3.0/bookmarks"

# 显式指定源目录为当前目录 (.)，目标为 $HOME
  stow -vR --dir=. --target="$HOME" zsh
  stow -vR --dir=. --target="$HOME" tmux
  stow -vR --dir=. --target="$HOME" nvim
  stow -vR --dir=. --target="$HOME" yazi
  stow -vR --dir=. --target="$HOME" bash
  stow -vR --dir=. --target="$HOME" conda
  stow -vR --dir=. --target="$HOME" fastfetch
  stow -vR --dir=. --target="$HOME" ghostty
  stow -vR --dir=. --target="$HOME" htop
  stow -vR --dir=. --target="$HOME" lazygit
  stow -vR --dir=. --target="$HOME" flameshot
  stow -vR --dir=. --target="$HOME" fsearch
  stow -vR --dir=. --target="$HOME" fcitx5
  stow -vR --dir=. --target="$HOME" starship
  stow -vR --dir=. --target="$HOME" pavucontrol
  stow -vR --dir=. --target="$HOME" ipython
  stow -vR --dir=. --target="$HOME" vscode
  stow -vR --dir=. --target="$HOME" gnome
  fi
fi

# --- 4.5 GNOME 设置导入 ---
if command -v dconf &>/dev/null && [ -f "$HOME/.dotfiles/scripts/gnome-dconf.ini" ]; then
  echo "⚙️ 导入 GNOME 设置..."
  dconf load / < "$HOME/.dotfiles/scripts/gnome-dconf.ini"
fi

# 统一映射二进制程序
[ -f ~/.apps/lazygit/bin/lazygit ] && ln -sf ~/.apps/lazygit/bin/lazygit ~/.local/bin/lazygit
[ -f ~/.apps/yazi/bin/yazi ] && ln -sf ~/.apps/yazi/bin/yazi ~/.local/bin/yazi
[ -f ~/.apps/nvim/bin/nvim ] && ln -sf ~/.apps/nvim/bin/nvim ~/.local/bin/nvim
[ -f ~/.apps/fzf/bin/fzf ] && ln -sf ~/.apps/fzf/bin/fzf ~/.local/bin/fzf

# 安装 toggle-caps (setuid 二进制，需要 sudo)
if [ ! -f /usr/local/bin/toggle-caps ] && [ -f "$HOME/.dotfiles/bin/toggle-caps" ]; then
  echo "⌨️ 安装 toggle-caps..."
  sudo cp "$HOME/.dotfiles/bin/toggle-caps" /usr/local/bin/toggle-caps
  sudo chown root:root /usr/local/bin/toggle-caps
  sudo chmod 4755 /usr/local/bin/toggle-caps
fi

# fcitx5 输入法切换脚本 (VS Code Vim 扩展用)
[ -f "$HOME/.dotfiles/bin/fcitx5-switch.sh" ] && ln -sf "$HOME/.dotfiles/bin/fcitx5-switch.sh" ~/.local/bin/fcitx5-switch.sh

# --- 5. 安装 Zimfw 核心 ---
if [ ! -f "$HOME/.zim/init.zsh" ]; then
  echo "🚀 安装 Zimfw..."
  mkdir -p "$HOME/.zim"
  if [ ! -f "$HOME/.zim/zimfw.zsh" ]; then
    curl -fsSL https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh -o "$HOME/.zim/zimfw.zsh"
  fi
  ZIM_HOME="$HOME/.zim" zsh "$HOME/.zim/zimfw.zsh" install
fi

# --- 6. 自动安装 Tmux 插件 (先 Stow 后安装) ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "🔌 安装 TPM..."
  # 此时 ~/.tmux 已经是指向 .dotfiles/tmux 的软链接了
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  echo "📥 正在自动下载 Tmux 插件..."
  bash "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1
fi

# --- 7. Clash Verge (代理，需手动下载 deb) ---
CLASH_DEB="$HOME/.dotfiles/clash-verge/clash-verge.deb"
CLASH_VER="2.5.1"
if ! command -v clash-verge &>/dev/null; then
  if [ -f "$CLASH_DEB" ]; then
    echo "🪜 安装 Clash Verge (本地 deb)..."
    sudo dpkg -i "$CLASH_DEB" || sudo apt-get install -y -f
  else
    echo "⚠️ clash-verge 未安装，且无本地 deb。"
    echo "   请手动下载: https://github.com/clash-verge-rev/clash-verge-rev/releases"
    echo "   保存 deb 到 $CLASH_DEB 后重新运行本脚本"
  fi
else
  # 还原配置文件
  CLASH_DATA="$HOME/.local/share/io.github.clash-verge-rev.clash-verge-rev"
  if [ -d "$HOME/.dotfiles/clash-verge" ] && [ -d "$CLASH_DATA" ]; then
    echo "🪜 还原 Clash Verge 配置..."
    cp "$HOME/.dotfiles/clash-verge"/*.yaml "$CLASH_DATA/" 2>/dev/null || true
  fi
fi

echo "---"
echo "✨ 安装完成！"

# 尝试切换默认 shell 到 zsh
if command -v zsh &>/dev/null && [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "🔄 正在将默认 Shell 切换为 Zsh (可能需要输入密码)..."
  if command -v chsh &>/dev/null; then
    chsh -s "$(command -v zsh)" 2>/dev/null || echo "⚠️ 切换失败，请手动执行: chsh -s \$(which zsh)"
  fi
fi
