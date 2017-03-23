# Phil's PowerShell Snippets

A library of useful PowerShell scripts and snippets

## Azure

### New-NSGFromCSV

Creates a new NSG from a list of rules specified in a CSV file

### Remove-OldAzureStorageBlob.ps1

Removes blobs from azure storage older than the specified age [(Blog Link)](https://strangeadventures.in/deletingoldfilesfromazureblobstorage/)

## ScriptBits

### ImportModules.ps1

Iterates through an array of PowerShell modules and ensures they are imported before executing a script.

## Server Admin

### Import-DHCPRes2008.ps1

Imports DHCP reservations from a CSV file to a DHCP server running Windows Server 2008/R2

### Remove-OldFiles.ps1

Searches a directory for files older than x days and deletes them. Optionally logs the deleted files to a csv file.