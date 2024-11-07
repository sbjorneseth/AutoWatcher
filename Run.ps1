$WatchGoalMinutes = 60
$Streamers = Get-Content -Path "Streamers.json" | ConvertFrom-Json
while (($Streamers.WatchTimeMinutes | Get-Unique) -ne $WatchGoalMinutes) {
    $Streamers = Get-Content -Path "Streamers.json" | ConvertFrom-Json
    foreach ($Streamer in $Streamers) {
        if ($Streamer.WatchTimeMinutes -ge $WatchGoalMinutes) {
            Write-Host "$($Streamer.Name) has been watched for an hour. Skipping"
            Continue
        }
        $Response = Invoke-RestMethod -Method Get -Uri "https://www.twitch.tv/$($Streamer.Name)"
        if ($Response -match '"isLiveBroadcast":.*true') {
            Write-Host "$($Streamer.Name) is live. Starting to watch"
            start-process chrome.exe "https://www.twitch.tv/$($Streamer.Name)"
            while ($Streamer.WatchTimeMinutes -lt $WatchGoalMinutes) {
                Start-Sleep -Seconds 1
                $Response = Invoke-RestMethod -Method Get -Uri "https://www.twitch.tv/$($Streamer.Name)"
                if ($Response -match '"isLiveBroadcast":.*true') {
                    Write-Host "$($Streamer.Name) is still live. Saving progress ($($Streamer.WatchTimeMinutes) minutes) and watching one more minute"
                    $Streamer.WatchTimeMinutes = $Streamer.WatchTimeMinutes + 1
                    $Progress = Get-Content -Path "Streamers.json" | ConvertFrom-Json
                    # Update progress
                    $Progress | ForEach-Object {if ($_.Name -eq $Streamer.Name) {[pscustomobject]@{Name = $_.Name;WatchTimeMinutes = $Streamer.WatchTimeMinutes}}else{$_}} | ConvertTo-Json | Set-Content -Path "Streamers.json" -Force
                }
                else {
                    Write-Host "$($Streamer.Name) is no longer live"
                    Get-Process -Name Chrome -ErrorAction SilentlyContinue | Stop-Process
                    break
                }
            }
            Get-Process -Name Chrome -ErrorAction SilentlyContinue | Stop-Process
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