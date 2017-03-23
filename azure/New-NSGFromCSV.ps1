<#
.SYNOPSIS
	Builds a new network security group importing the rules from a CSV 
    file.
.DESCRIPTION
    Reads a list of rules from a CSV file and builds a new NSG based 
    on the specified ruleset.

    The user must already be logged in with Login-AzureRMAccount for 
    this to work.

    Assumes the CSV contains the following columns:
    Priority,Name,Description,Access,Protocol,Direction,SourceIP,
    SourcePort,DestIP,DestPort

    Valid column values:
    Priority - Number
    Access - Allow/Deny
    Protocol - TCP/UDP/*
    Direction - Inbound/Outbound
    SourceIP/DestIP - x.x.x.x/*
    SourcePort/DestPort - Number/*

.NOTES
	File Name	: New-NSGFromCSV.ps1
	Author		: Phil "Barnabus" Skentelbery - phil.skents@gmail.com
.LINK
	https://strangeadventures.in
.EXAMPLE
	.\New-NSGFromCSV.ps1 -RgName MyResourceGroup -Region eastus2 `
    -NsgName MyNewNsg -PathToCsv - C:\PathTo\My.csv
#>

[CmdletBinding()]
Param(
    [Parameter (Mandatory=$true,Position=1)]
    [String]$RgName,

    [Parameter (Manadatory=$true,Position=2)]
    [String]$Region,

    [Parameter (Mandatory=$true,Positon=3)]
    [String]$NsgName,

    [Parameter (Mandatory=$true,Position=4)]
    [String]$PathToCsv
)

# Load CSV

if ([bool](Test-Path $PathToCsv) -eq $true){
    try {
        $Rules = Import-CSV NewNsg.csv
    }
    catch {
        $msg = "Error importing rules from csv "+$PathToCsv+":"
        Write-Host $msg `n 
        Write-Host $_.Exception
        break
    }
}


#Create the NSG

try {
    $Nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $RgName -Location $Region -Name $NsgName
}
catch [Exception]{
    Write-Host 'There was an error creating the NSG:' `n 
    Write-Host $_.Exception.Message
    break
}

#Add rules to NSG

try {
    foreach($rule in $rules){
        $Name = $Rule.Name
        $Description = $Rule.Description
        $Access = $Rule.Access
        $Protocol = $Rule.Protocol
        $Direction = $Rule.Direction
        $Priority = $Rule.Priority
        $SourceIP = $Rule.SourceIP
        $SourcePort = $Rule.SourcePort
        $DestIP = $Rule.DestIP
        $DestPort = $Rule.DestPort

        Add-AzureRMNetworkSecurityRuleConfig -NetworkSecurityGroup $Nsg `
        -Name $Name `
        -Description $Description `
        -Access $Access `
        -Protocol $Protocol `
        -Direction $Direction `
        -Priority $Priority `
        -SourceAddressPrefix $SourceIP `
        -SourcePortRange $SourcePort `
        -DestinationAddressPrefix $DestIP `
        -DestinationPortrange $DestPort
    }
}
catch [Exception]{
    Write-Host "There was an error adding a rule, no rules have been commited:" `n 
    Write-Host $_.Exception.Message
    break
}

#Commit NSG to Azure

try {
    Set-AzureRMNetworkSecurityGroup -NetworkSecurityGroup $Nsg
}
catch [Exception]{
    Write-Host "There was an error commiting the NSG to Azure:" `n 
    Write-Host $_.Exception.Message
}