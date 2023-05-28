#!/bin/bash

# 定义变量
REMOTE_PATH="/var/lib/wonder/nas/filerun/user-files/lxb/Obsidian"
LOCAL_PATH="/home/lhh/github/dg"

# 使用rsync从远程路径同步数据到本地
rsync -avz --progress $REMOTE_PATH/ $LOCAL_PATH/_notes

# 进入到本地路径
cd $LOCAL_PATH

# 运行nix develop
nix develop --command bash -c "bundle install; bundle exec jekyll serve"
