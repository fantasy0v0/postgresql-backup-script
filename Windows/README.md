# 目录结构要求

遵守以下结构即可

```
D:\pg_backup
├─base
├─script
│  └─backup.ps1
└─wal
```

## base

用于存放pg_basebackup产生的目录、文件以及配置文件

## script

用于存放备份相关的脚本

## wal

用于存放数据库日常产生的wal文件

# 定时任务

使用系统自带的任务计划程序, 每周执行一次pg_basebackup

```txt
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\pg_backup\script\backup.ps1
```