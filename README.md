# Autowatcher
Will automatically watch streamers based on this list https://twitch.facepunch.com/#drops as of 11/07/2024. Json file can be changed to watch any streamer. Progress will be saved every minute.

## How to use
1. Clone repo
2. Define streamers in Streamers.json
3. If you are using another browser than Chrome, make sure to change settings.jsonc
4. Right click Run.ps1 and click "Run with PowerShell"

## How it works
Loops until WatchTimeMinutes (Steamers.json) matches WatchTimeGoalMinutes (settings.jsonc) for every streamer in Streamers.json.