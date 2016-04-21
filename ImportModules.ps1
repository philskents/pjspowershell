#Specify the modules required to execute a script

#Required modules (as array)

$requiredModules = "ActiveDirectory", "SQLPS"

# Iterate through the array, importing each module if available

foreach ($module in $requiredModules){
    if ( (Get-Module -Name $module -ErrorAction silentlycontinue) -eq $null ) {
        if ( (Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue) -eq $null) {
            Write-Error "You must install" $module " Module to use this script!"
        } 
        else {
            Write-Host "Importing " $module
            Import-Module $module -ErrorAction Stop
        }
    }
}