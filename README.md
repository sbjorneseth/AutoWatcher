# Autowatcher
Will automatically watch streamers based on this list https://twitch.facepunch.com/#drops as of 11/07/2024. Json file can be changed to watch any streamer. Progress will be saved every minute.

## How to use
Clone repo, right click Run.ps1 and click "Run with PowerShell"

## How it works
Loops until WatchTimeMinutes (Steamers.json) matches WatchGoalMinutes (variable in Run.ps1) for every streamer in Streamers.json.