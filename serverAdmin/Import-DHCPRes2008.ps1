<#
.SYNOPSIS
	This script takes a CSV file of DHCP reservations and imports them into
    a DHCP scope hosted on a 2008/2008R2 DHCP server.
.DESCRIPTION
    Assumes the CSV file used has the following columns:
    
    ScopeID,IPAddress,Mac,Name,Description 

	Imports the CSV file and then takes entry through the following steps:
    1) Converts the MAC address to a standard format (xx:xx:xx:xx:xx:xx)
    2) Validates the IP and skips if invald
    3) Validates the MAC and skips if invalid
    4) If both th IP and MAC are valid the script builds and executes the netsh command
.NOTES
	File Name	: Import-DHCPRes2008.ps1
	Author		: Phil "Barnabus" Skentelbery - phil.skents@gmail.com
.LINK
	https://strangeadventures.in
.EXAMPLE
	.\Import-DHCPRes2008.ps1 -pathToCsv C:\PathTo\my.csv -dhcpServer \\myDHCPServer
#>

[CmdletBinding()]
Param(
    #Get path to CSV 
    [Parameter (Mandatory=$true,Position=1)]
    [string]$pathToCsv,

    #Get DHCP Server ID
    [Parameter (Mandatory=$true,Position=2)]
    [string]$dhcpServer
)

#Import CSV file
$Reservations = Import-Csv -Path $pathToCsv

#Standardize MAC format to xx:xx:xx:xx:xx:xx
foreach ($Reservation in $Reservations){
    $dirtyMac = $Reservation.Mac
    $dirtyMac = $dirtyMac -replace '[^a-zA-Z0-9]',''
    $dirtyMac = $dirtyMac.insert(2,":")
    $dirtyMac = $dirtyMac.insert(5,":")
    $dirtyMac = $dirtyMac.insert(8,":")
    $dirtyMac = $dirtyMac.insert(11,":")
    $cleanMac = $dirtyMac.insert(14,":")

    #Check to see if IP address is valid
    if ([bool]($Reservation.IPAddress -as [ipaddress]) -eq $false){
        $message = "The IP Address "+$Reservation.IPAddress+" is invalid, skipping"
        Write-Host $message
    }
    #Check MAC to see if it is valid 
    elseif ($cleanMac -notmatch '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'){
        $message = "The MAC address for "+$Reservation.IPAddress+" is invalid, skipping"
        Write-Host $message
    }
    else {
        try {
            #Remove delimitters from mac address (required for netsh command)
            $mac = $cleanMac -replace '[^a-zA-Z0-9]',''
            #Build netsh command 
            $cmd = 'netsh Dhcp Server '+$dhcpServer+' Scope '+$Reservation.ScopeId+' Add reservedip '+$Reservation.IPAddress+' '+$mac+' "'+$Reservation.Name+'" "'+$Reservation.Description+'" BOTH'
            #Execute netsh command 
            Invoke-Expression $cmd | Out-Null
            $message = "Reservation for "+$Reservation.IPAddress+" Added to scope"
            Write-Host $message
        }
        catch {
            $message = "Critical error adding reservation for "+$Reservation.IPAddress+", exiting script."
            Write-Host $message `n
            Write-Host $_.Exception.Message
            break
        }
    }
}