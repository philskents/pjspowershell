<#
.SYNOPSIS
	This script searches the specified path for files older
	than the defined age in days and deletes them.
.DESCRIPTION
	Using a calculated date this script searches for all files
	created before that date and passes them to the Remove-Item
	cmdlet.
	
	It will ignore folders, deleteing files only, and will search
	all child items of the directory specified in the path parameter.
.NOTES
	File Name	: Remove-OldFiles.ps1
	Author		: Phil "Barnabus" Skentelbery - phil.skents@gmail.com
.LINK
	http://www.aplicor.com
.EXAMPLE
	.\Remove-OldFilesAuto.ps1
	
	Be sure to configure the $path and $age variables before running.
#>

[CmdletBinding()]
Param(
	[Parameter (Mandatory=$true,Position=1)]
	[String]$targetPath,

	[Parameter (Mandatory=$true,Positon=2)]
	[Int]$maxAge,

	[Parameter (Mandatory=$false,Position=3)]
	[String]$pathToCsv
)

$files = Get-ChildItem -Path $path -Recurse | Where-Object {-not $_.PsIsContainer -and $_.CreationTime -lt $date }
$date = (Get-Date).AddDays(-$age)
$enddate = (Get-Date).tostring("yyyyMMdd")

foreach ($file in $files){
	if ($pathToCsv -ne $null){
		Select-Object $file.Fullname | Export-Csv $pathToCsv
	}
	Remove-Item $file
}