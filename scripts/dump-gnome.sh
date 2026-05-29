#!/bin/bash
# 导出当前 GNOME dconf 设置，便于换机迁移
cd "$(dirname "$0")"
dconf dump / > gnome-dconf.ini
echo "✅ GNOME 设置已导出到 scripts/gnome-dconf.ini ($(wc -l < gnome-dconf.ini) 行)"
