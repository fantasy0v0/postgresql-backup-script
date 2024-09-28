# 目录结构要求

使用postgres用户创建以下目录, 并且后续所有操作都是在这个用户下进行

```
/pg_backup
├─base
├─conf
├─script
│  └─backup.sh
└─wal
```

## base

用于存放pg_basebackup产生的目录以及文件

## conf

用于存放数据库配置文件的备份, 使用gzip、tar压缩和打包

## script

用于存放备份相关的脚本

## wal

用于存放数据库日常产生的wal文件

# 定时任务

使用系统自带的cron, 每周执行一次pg_basebackup

```txt
0 0 * * 1 sh /pg_backup/script/backup.sh
```