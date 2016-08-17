[CmdletBinding()]
Param(
[Parameter (Mandatory=$true,Position=1)]
[string]$storageAccountName,

[Parameter (Mandatory=$true,Position=2)]
[string]$storageAccountKey,

[Parameter (Mandatory=$true,Position=3)]
[string]$containerName,

[Parameter (Mandatory=$true,Position=4)]
[string]$age,

[Parameter (Mandatory=$true,Position=5)]
[string]$errorSMTPServer
)

$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$date = [DateTime]::Today.AddDays(-$age)

Try {
    $ErrorActionPreference = 'Stop'
    Get-AzureStorageBlob -Context $context -Container $containerName | Where-Object {$_.LastModified -lt $date} | Remove-AzureStorageBlob
}
Catch{
    $hostname = $env:COMPUTERNAME
    $sub = 'Job failed on '+$hostname
    $err = $_.Exception.Message
    $msg = 'Scheduled job Remove-OldAzureStorageBlob failed on '+$hostname+' with error '+$err
    Send-MailMessage -From alerts@aplicor.com -To opshelpdesk@aplicor.com -Subject $sub -Body $msg -SmtpServer $errorSMTPServer
}
