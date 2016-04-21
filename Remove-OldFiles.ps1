<#
.SYNOPSIS
	This script searches the specified path ($path) for files older
	than the defined age in days ($age) and deletes them.
.DESCRIPTION
	Using a calculated date ($date) this script searches for all files
	created before that date and passes them to the Remove-Item
	cmdlet.
	
	It will ignore folders, deleteing files only, and will search
	all child items of the directory specified in the path variable
	($path).
	
	This script is designed to be run as a scheduled task. For a user
	friendly "one off" purge please use the alternative script
	Remove-OldFiles
.NOTES
	File Name	: Remove-OldFilesAuto.ps1
	Author		: Phil "Barnabus" Skentelbery - pskentelbery@aplicor.com
.LINK
	http://www.aplicor.com
.EXAMPLE
	.\Remove-OldFilesAuto.ps1
	
	Be sure to configure the $path and $age variables before running.
#>

Read-Host 
# Directory to be scanned
$path = "C:\APATH"
# Maximum age of items
$age = 30
$date = (Get-Date).AddDays(-$age)
$enddate = (Get-Date).tostring("yyyyMMdd")
$filename = 'C:\DeletionReports' + $enddate + '_DeletionReport.csv'
Get-ChildItem -Path $path -Recurse | Where-Object {-not $_.PsIsContainer -and $_.CreationTime -lt $date } | Export-Csv $filename
Get-ChildItem -Path $path -Recurse | Where-Object {-not $_.PsIsContainer -and $_.CreationTime -lt $date } | Remove-Item