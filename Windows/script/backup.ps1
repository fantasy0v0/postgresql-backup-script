# ������üǵ��޸�
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
        -Subject "���ݿⱸ���쳣" -Body $Body `
        -SmtpServer "smtp.qq.com" -UseSsl -Credential $Credentials -Encoding UTF8
}

# �ж��Ƿ��ظ�����
if (Test-Path $Directory)
{
    echo "$($Directory) already exists"
    SendMessage -Body "$($Directory) �ظ�����"
    Exit 1
}

# ִ��base_backup
& "$($BinPath)\pg_basebackup.exe" -D $($Directory) -F t -z -U postgres
if (! $?)
{
	SendMessage -Body "$($Directory) ����ʧ��"
	Exit 2
}

# ���������ļ�
Compress-Archive -LiteralPath "$($DataPath)\postgresql.conf", "$($DataPath)\pg_hba.conf" -DestinationPath "$($Directory)\conf\conf.$(Get-Date -Format "yyyyMMdd").zip"

# �������base
$CutoffDate = (Get-Date).AddDays(-15)
Get-ChildItem -Path "$($BackupPath)\base\" -Directory | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Recurse
if (! $?)
{
	SendMessage -Body "$($Directory) ����baseʧ��"
	Exit 3
}
# �������wal
Get-ChildItem -Path "$($BackupPath)\wal\" -File | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Recurse
if (! $?)
{
	SendMessage -Body "$($Directory) ����walʧ��"
	Exit 4
}
# �����������
Get-ChildItem -Path "$($BackupPath)\conf\" -File | Where-Object { $_.LastWriteTime -lt $CutoffDate } | Remove-Item -Recurse
if (! $?)
{
	SendMessage -Body "$($Directory) ����confʧ��"
	Exit 4
}