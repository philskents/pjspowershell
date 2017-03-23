<#
.Synopsis
   This script will delete all blobs from the specified container over a certain age.
.DESCRIPTION
   When given the necessary storage account information this script will find any blobs over the given age in days and
   remove them. If the job fails it will send an email to the specified recipient.

   This script is designed to be executed as a scheduled task.
.EXAMPLE
   .\Remove-OldAzureStorageBlob.ps1 -storageAccountName foo -storageAccountKey bar -containerName backups -age 30 `
   -errorSMTPServer mymail.domain.com -errorSourceAddress alerts@domain.com -errorDestAddress me@domain.com
.NOTES
   Author:    Phil Skents (phil@strangeadventures.in)
   URL:       https://strangeadventures.in
#>

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

[Parameter (Mandatory=$false,Position=5)]
[string]$errorSMTPServer,

[Parameter (Mandatory=$false,Position=9)]
[string]$errorSourceAddress,

[Parameter (Mandatory=$false,Position=5)]
[string]$errorDestAddress
)

$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$date = [DateTime]::Today.AddDays(-$age)

Try {
    $ErrorActionPreference = 'Stop'
    Get-AzureStorageBlob -Context $context -Container $containerName | Where-Object {$_.LastModified -lt $date} | Remove-AzureStorageBlob
}
Catch{
    if (($errorSMTPServer -ne $null) -and ($errorDestAddress -ne $null) -and ($errorSourceAddress -ne $null)){
        $hostname = $env:COMPUTERNAME
        $sub = 'Job failed on '+$hostname
        $err = $_.Exception.Message
        $msg = 'Scheduled job Remove-OldAzureStorageBlob failed on '+$hostname+' with error '+$err
        Send-MailMessage -From $errorSourceAddress -To $errorDestAddress -Subject $sub -Body $msg -SmtpServer $errorSMTPServer
    }
    else {
        Write-Host "Error encountered" `n
        Write-Host $_.Exception
    }
}
