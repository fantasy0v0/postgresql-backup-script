#!/bin/bash
base="/pg_backup"
# 判断是否重复备份
directory="$base/base/`date +%Y%m%d`"
if [ -d $directory ]; then
	echo "$directory already exists"
	exit 1
fi
# 执行base_backup
pg_basebackup -D $directory -F t -z -U postgres
if [ $? -eq 1 ]; then
	echo "basebackup failed"
	exit 2
fi
# 备份配置文件
tar -zcvf "$base/conf/conf.`date +%Y%m%d`.tar.gz" --directory=/etc/postgresql/ .

# 清理过期basebackup
find $base/base/ -mindepth 1 -maxdepth 1 -type d -mtime +15 -printf "%P\0" | xargs -0 -I {} rm -rfv $base/base/{}
# 清理过期wal
find $base/wal/ -mindepth 1 -maxdepth 1 -type f -mtime +15 -exec rm -rfv {} \;
# 清理过期conf
find $base/conf/ -mindepth 1 -maxdepth 1 -type f -mtime +15 -exec rm -rfv {} \;
