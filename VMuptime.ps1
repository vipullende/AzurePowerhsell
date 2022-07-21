# Create Custom Object
$UptimeReport = @()
$AllVMs = Get-AzVM -Status | Where-Object { $_.PowerState -Like 'VM running' }
# Walk through each VM
foreach ($VM in $AllVMs) {

    # Get Subscription Information
    $ctx = Get-AzContext
    Write-Host "Check: '$($VM.Name)' in Subscription '$($ctx.Subscription.Name)'"
    
    # Get the Activity Log of the VM
    $VMAzLog = Get-AzLog -ResourceId $VM.Id `
    | Where-Object { $_.OperationName.LocalizedValue -Like 'Start Virtual Machine' } `
    | Sort-Object EventTimestamp -Descending `
    | Select-Object -First 1
    $BootTime = $VMAzLog.EventTimestamp

    if ($BootTime) {
        $Uptime = '{0}:{1:D2}:{2:D2}' -f (24 * $TimeSpan.Days + $TimeSpan.Hours), $TimeSpan.Minutes, $TimeSpan.Seconds
    }
    else {
        $Uptime = "n/a" 
    }

    if ($BootTime) {
        
        $TimeSpan = New-TimeSpan -Start $($VMAzLog.EventTimestamp) -End (Get-Date)

        $UptimeReport += [PSCustomObject]@{
            VM             = $VM.Name
            SubscriptionId = $ctx.Subscription.id
            Uptime         = $Uptime
        }
    }
}

# Print Result
return $UptimeReport | Sort-Object -Property VM | ft * -AutoSize