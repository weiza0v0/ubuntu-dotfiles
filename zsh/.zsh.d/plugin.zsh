# FZF 插件特定配置（颜色在 env.zsh 中统一管理）

# 如果安装了 zfm 或 fzf-tab，在这里写配置
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' fzf-command fzf