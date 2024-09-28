# 相关配置记得修改
$Password = ConvertTo-SecureString -String "password" -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential("recipient@qq.com", $Password)
$BasePath = "C:\Program Files\PostgreSQL\15"
$BinPath = "$($BasePath)\bin"
$DataPath = "$($BasePath)\data"
$BackupPath = "C:\pg_backup"
$Directory = "$($BackupPath)\base\$(Get-Date -Format "yyyyMMdd")"

function SendMessage
{
    param (
     [string]$Body
    )
    Send-MailMessage `
        -From "XXX <recipient@qq.com>" -To "Fan <sender@qq.com>" `
        -Subject "数据库备份异常" -Body $Body `
        -SmtpServer "smtp.qq.com" -UseSsl -Credential $Credentials -Encoding UTF8
}

# 判断是否重复备份
if (Test-Path $Directory)
{
    echo "$($Directory) already exists"
    SendMessage -Body "$($Directory) 重复备份"
    Exit 1
}

# 执行base_backup
& "$($BinPath)\pg_basebackup.exe" -D $($Directory) -F t -z -U postgres
if (! $?)
{
	SendMessage -Body "$($Directory) 备份失败"
	Exit 2
}

# 备份配置文件
Compress-Archive -LiteralPath "$($DataPath)\postgresql.conf", "$($DataPath)\pg_hba.conf" -DestinationPath "$($Directory)\conf\conf.$(Get-Date -Format "yyyyMMdd").zip"

# 清理过期base
$CutoffDate = (Get-Date).AddDays(-15)
Get-ChildItem -Path "$($BackupPath)\base\" -Directory | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Recurse
if (! $?)
{
	SendMessage -Body "$($Directory) 清理base失败"
	Exit 3
}
# 清理过期wal
Get-ChildItem -Path "$($BackupPath)\wal\" -File | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Recurse
if (! $?)
{
	SendMessage -Body "$($Directory) 清理wal失败"
	Exit 4
}
# 清理过期配置
Get-ChildItem -Path "$($BackupPath)\conf\" -File | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Recurse
if (! $?)
{
	SendMessage -Body "$($Directory) 清理conf失败"
	Exit 4
}