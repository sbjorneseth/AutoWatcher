# This file is executed by right clicking and selecting "Run with PowerShell". Will loop until all streamers have been watched for the desired amount of time.
$Settings = Get-Content -Path ".\Settings.json" | ConvertFrom-Json
$ProcessName = $Settings.BrowserFullPath.Split("\")[-1].Split(".")[0]
$Streamers = Get-Content -Path ".\Streamers.json" | ConvertFrom-Json
while (($Streamers.WatchTimeMinutes | Get-Unique) -ne $Settings.WatchTimeGoalMinutes) {
    $Streamers = Get-Content -Path ".\Streamers.json" | ConvertFrom-Json
    foreach ($Streamer in $Streamers) {
        if ($Streamer.WatchTimeMinutes -ge $Settings.WatchTimeGoalMinutes) {
            Write-Host "$($Streamer.Name) has been watched for $($Settings.WatchTimeGoalMinutes). Skipping"
            Continue
        }
        $Response = Invoke-RestMethod -Method Get -Uri "https://www.twitch.tv/$($Streamer.Name)"
        if ($Response -match '"isLiveBroadcast":.*true') {
            Write-Host "$($Streamer.Name) is live. Starting to watch"
            start-process -FilePath $Settings.BrowserFullPath -ArgumentList "https://www.twitch.tv/$($Streamer.Name)"
            while ($Streamer.WatchTimeMinutes -lt $Settings.WatchTimeGoalMinutes) {
                Start-Sleep -Seconds ($Settings.UpdateIntervalMinutes * 60)
                $Response = Invoke-RestMethod -Method Get -Uri "https://www.twitch.tv/$($Streamer.Name)"
                if ($Response -match '"isLiveBroadcast":.*true') {
                    $Streamer = Get-Content -Path ".\Streamers.json" | ConvertFrom-Json | Where-Object -FilterScript {$_.Name -eq $Streamer.Name}
                    $Streamer.WatchTimeMinutes = $Streamer.WatchTimeMinutes + $Settings.UpdateIntervalMinutes
                    Write-Host "$($Streamer.Name) is still live. Saving progress ($($Streamer.WatchTimeMinutes) minutes) and watching $($Settings.UpdateIntervalMinutes) more minute"
                    $Progress = Get-Content -Path ".\Streamers.json" | ConvertFrom-Json
                    # Update progress
                    $Progress | ForEach-Object {if ($_.Name -eq $Streamer.Name) {[pscustomobject]@{Name = $_.Name;WatchTimeMinutes = $Streamer.WatchTimeMinutes}}else{$_}} | ConvertTo-Json | Set-Content -Path ".\Streamers.json" -Force
                }
                else {
                    Write-Host "$($Streamer.Name) is no longer live"
                    Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Stop-Process
                    break
                }
            }
            Write-Host "Watch goal reached for $($Streamer.Name)!" -ForegroundColor Green
            Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Stop-Process
            Continue
        }
        else {
            Write-Host "$($Streamer.Name) is not live"
            Continue
        }
    }
}
Write-Host "Done!" -ForegroundColor Green
Read-Host -Prompt "Press Enter to exit"