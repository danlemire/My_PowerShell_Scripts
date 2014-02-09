
function Get-CurrentPowerPlan
{  
    #Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power | format-table ElementName
    return (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power | Where-Object {$_.IsActive -eq $True}).ElementName # | format-table ElementName).ElementName
}

function Get-PowerPlans
{
    Write-Host "Powerplans:"
    Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power | format-table ElementName
    #Write-Host 'Usage for set: SetPowerPlan $ElementName';
}

function Set-PowerPlan([string]$PreferredPlan)
{
    Write-Host "Setting Powerplan to $PreferredPlan"
    $guid = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "ElementName='$PreferredPlan'").InstanceID.tostring()
    $regex = [regex]"{(.*?)}$"
    $newpowerVal = $regex.Match($guid).groups[1].value

    # setting power setting to high performance
    powercfg -S  $newpowerVal
}

[string] $currentPowerPlan = Get-CurrentPowerPlan
Get-PowerPlans;
Write-Host "Current Power Plan is $currentPowerPlan"

Try
{
    
    if ( $currentPowerPlan -like "*Bal*")
    {
        Write-Host "Found BAL, switching to always on"
        Set-PowerPlan "Always On";
    }

    #elseif (Get-CurrentPowerPlan -like "Always" -or Get-CurrentPowerPlan -like "Max")
    elseif ($currentPowerPlan -like "*On*")
    {
       Write-Host "Found *On*, switching to Balanced"
       Set-PowerPlan "Balanced";
    }
}
catch [System.Management.Automation.RuntimeException]
{
    Write-Error "Always On or Balanced power setting not found"
    Get-PowerPlans;
}



