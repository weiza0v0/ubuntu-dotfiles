# --- 路径别名管理工具 (加固修复版) ---

TEMP_ALIAS_FILE="$HOME/.cache/zsh_temp_aliases.sh"
[[ ! -d "$(dirname "$TEMP_ALIAS_FILE")" ]] && mkdir -p "$(dirname "$TEMP_ALIAS_FILE")"
touch "$TEMP_ALIAS_FILE"

# 1. 自动加载钩子
_last_alias_mtime=0
alias_reload_hook() {
    local mtime  # 使用 local 保护
    [[ ! -f "$TEMP_ALIAS_FILE" ]] && return
    mtime=$(stat -c %Y "$TEMP_ALIAS_FILE" 2>/dev/null || stat -f %m "$TEMP_ALIAS_FILE" 2>/dev/null)
    if [[ "$mtime" != "$_last_alias_mtime" ]]; then
        source "$TEMP_ALIAS_FILE" 2>/dev/null
        _last_alias_mtime=$mtime
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd alias_reload_hook

# 2. rmp：移除别名
rmp() {
    local alias_name="$1"
    [[ -z "$alias_name" ]] && { echo "用法: rmp <别名>" >&2; return 1; }
    
    local tmp=$(mktemp)

    grep -v "alias $alias_name=" "$TEMP_ALIAS_FILE" >! "$tmp" 2>/dev/null
    mv -f "$tmp" "$TEMP_ALIAS_FILE"
    
    unalias "$alias_name" 2>/dev/null
    echo -e "\033[1;33m🗑️ 已移除别名: $alias_name\033[0m"
}

# 3. addp：添加别名
addp() {
    local target="" name="" arg1="$1" arg2="$2"
    local tmp

    if [[ -d "$arg1" ]]; then
        target=$(readlink -f "$arg1"); name="$arg2"
    elif [[ -d "$arg2" ]]; then
        target=$(readlink -f "$arg2"); name="$arg1"
    else
        name="$arg1"; target=$(pwd)
    fi

    [[ -z "$name" ]] && { echo "❌ 用法: addp <别名> [路径]" >&2; return 1; }

    tmp=$($MKTEMP)
    grep -v "alias $name=" "$TEMP_ALIAS_FILE" >! "$tmp" 2>/dev/null
    echo "alias $name='cd \"$target\" && ls -F --color=always'" >> "$tmp"
    mv -f "$tmp" "$TEMP_ALIAS_FILE"

    alias "$name"="cd \"$target\" && ls -F --color=always"
    echo -e "\033[1;32m✨ 别名设置成功:\033[0m $name -> $target"
}

# 4. lsp：列表美化显示
lsp() {
    local alias_item alias_dest  # 彻底避开 path 关键字
    echo -e "\033[1;34m📂 当前持久化别名列表:\033[0m"
    if [[ ! -s "$TEMP_ALIAS_FILE" ]]; then
        echo "  (列表为空)"
    else
        printf "\033[1;37m%-15s %-s\033[0m\n" "ALIAS" "TARGET_PATH"
        # 修复逻辑：通过 read 存入非保留变量名
        sed -E "s/alias (.+)='cd \"(.+)\" && ls.+/\1|\2/" "$TEMP_ALIAS_FILE" | while IFS='|' read -r alias_item alias_dest; do
            printf "\033[1;33m%-15s\033[0m %-s\n" "$alias_item" "$alias_dest"
        done
    fi
}

# 5. arcp：归档文件夹到 D 盘
arcp() {
    local src_path=""
    local keep_source=false
    local archive_root="/mnt/d/02_Work/Archive"
    local date_str=$(date +%Y%m%d_%H%M%S)

    # --- 参数解析 ---
    # 支持 arcp -k [路径] 或 arcp [路径] -k
    for arg in "$@"; do
        if [[ "$arg" == "-k" || "$arg" == "--keep" ]]; then
            keep_source=true
        else
            src_path="$arg"
        fi
    done

    # 基础校验：如果未指定路径，默认当前目录
    [[ -z "$src_path" ]] && src_path=$(pwd)
    [[ ! -d "$src_path" ]] && { echo -e "\033[1;31m❌ 错误: 目录 $src_path 不存在\033[0m" >&2; return 1; }
    
    # 确保目标归档根目录存在
    [[ ! -d "$archive_root" ]] && mkdir -p "$archive_root"

    # 获取绝对路径和文件夹名
    local abs_src=$(readlink -f "$src_path")
    local base_name=$(basename "$abs_src")
    local tar_name="${base_name}_${date_str}.tar.gz"
    local dest_file="$archive_root/$tar_name"

    # 防止归档 Archive 目录本身导致无限递归
    if [[ "$abs_src" == "$archive_root"* ]]; then
        echo -e "\033[1;31m❌ 错误: 不能归档归档目录本身！\033[0m"
        return 1
    fi

    echo -e "\033[1;34m📦 正在归档:\033[0m $base_name"
    echo -e "\033[1;30m   从: $abs_src\033[0m"
    echo -e "\033[1;30m   至: $dest_file\033[0m"

    # 执行压缩
    tar -czf "$dest_file" -C "$(dirname "$abs_src")" "$base_name"

    if [[ $? -eq 0 ]]; then
        local size=$(du -h "$dest_file" | cut -f1)
        echo -e "\033[1;32m✅ 归档成功! (大小: $size)\033[0m"

        # --- 删除逻辑 ---
        if [ "$keep_source" = true ]; then
            echo -e "\033[1;33mℹ️  保留原文件夹: $abs_src\033[0m"
        else
            echo -e "\033[1;35m🗑️  归档成功，正在清理原文件夹...\033[0m"
            rm -rf "$abs_src"
            echo -e "\033[1;32m✨ 原位置已清理。\033[0m"
        fi
    else
        echo -e "\033[1;31m❌ 归档失败，保留原文件夹以防万一。\033[0m"
        return 1
    fi
}
