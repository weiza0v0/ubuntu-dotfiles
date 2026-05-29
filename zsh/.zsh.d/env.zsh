# ------------------------------------------------------------------------------
# 1. 基础路径 (不含 Conda 内部环境路径)
# ------------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.apps/fzf/bin:/usr/local/cuda/bin:$PATH"

# ------------------------------------------------------------------------------
# Fcitx5 输入法
# ------------------------------------------------------------------------------
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export GLFW_IM_MODULE=ibus

# ------------------------------------------------------------------------------
# 2. 动态库管理 (谨慎操作)
# ------------------------------------------------------------------------------
# 建议只保留系统和 CUDA 基础路径，特定环境的库路径应通过 'conda activate' 自动管理
export LD_LIBRARY_PATH=/usr/lib/wsl/lib:/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# ------------------------------------------------------------------------------
# 3. Conda 懒加载 (首次调用 conda 时才初始化，省 ~350ms 启动时间)
# ------------------------------------------------------------------------------
# 加 bin 到 PATH（几乎零开销）
export PATH="$HOME/.apps/anaconda3/bin:$PATH"
# 修复 conda OpenSSL 版本不匹配警告
export OPENSSL_MODULES="$HOME/.apps/anaconda3/lib/ossl-modules"

# 再用函数包装，首次使用时才 source conda.sh
conda() {
    unfunction conda mamba 2>/dev/null
    . "$HOME/.apps/anaconda3/etc/profile.d/conda.sh"
    conda "$@"
}
mamba() {
    unfunction conda mamba 2>/dev/null
    . "$HOME/.apps/anaconda3/etc/profile.d/conda.sh"
    mamba "$@"
}
# ------------------------------------------------------------------------------
# 4. 终端/编辑器与 FZF 配置
# ------------------------------------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export TERM="xterm-256color"
export COLORTERM="truecolor"

local fzf_colors='--color=fg:#d0d0d0,bg:-1,hl:#5fafff --color=fg+:#000000,bg+:#00ffff,hl+:#ffaf00 --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border $fzf_colors"

if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ------------------------------------------------------------------------------
# 5. 终端颜色与补全样式 (LS_COLORS)
# ------------------------------------------------------------------------------
# 确保这一行末尾有闭合的引号
export LS_COLORS="di=01;33:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dds=01;35:*.dgca=01;31:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

# 强制补全系统使用 LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

