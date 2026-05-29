#!/bin/bash
# fcitx5 IM switcher for VS Code Vim extension
# 1 = English (close IM), 2 = Chinese (restore IM)
if [ "$1" = "1" ]; then
  /usr/bin/fcitx5-remote -c
else
  /usr/bin/fcitx5-remote -o
fi
