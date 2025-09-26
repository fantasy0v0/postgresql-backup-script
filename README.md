# postgresql-backup-script
PostgreSQL Point-in-Time Recovery (PITR)

# 记录各个操作系统下PostgreSQL的定时备份脚本(基于PITR)

# Point-in-Time Recovery (PITR)

> https://www.postgresql.org/docs/current/continuous-archiving.html

利用每周一次的basebackup，和期间备份的wal文件，可以让数据库恢复到任意时间点。

## 前置步骤需要开启归档

1.打开postgresql.conf

2.设置指定参数

To enable WAL archiving, set the wal_level configuration parameter to replica or higher, archive_mode to on

3.设置归档命令

```txt
archive_command = 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'  # Unix
archive_command = 'copy "%p" "C:\\server\\archivedir\\%f"'  # Windows
```

## custom.conf

记录需要对数据库默认参数进行修改的参数项, 一般放置于数据库配置目录中的conf.d目录中，用来覆盖默认配置

## pg_hba.conf

允许任意ipv4地址连接数据库