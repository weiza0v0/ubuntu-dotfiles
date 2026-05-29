# 基础增强
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias grep='grep --color=auto'
alias fd='fdfind'

# 工具
alias v='nvim'
alias lg='lazygit'
alias tl='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'

# 项目开发快速跳转
alias cdp='cd ~/projects'
alias cdd='cd ~/.dotfiles'

# Python 环境
alias cal='conda activate DataAnalysis && ipython'

# 重载指令：如果 Tmux 在运行则关闭它，否则只重载 Zsh
alias rfs='(tmux kill-server 2>/dev/null || true) && exec zsh'
function ra() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
