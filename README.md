# Autowatcher
Automatically watches streamers based on the list from [Twitch Drops](https://twitch.facepunch.com/#drops) as of 11/07/2024. The JSON file can be modified to watch any streamer. Progress is saved every minute.

## How to Use
1. Clone the repository.
2. Define streamers in `Streamers.json`.
3. If you are using a browser other than Chrome, update `settings.jsonc` accordingly.
4. Right-click `Run.ps1` and select "Run with PowerShell".

## How It Works
The script loops until `WatchTimeMinutes` (in `Streamers.json`) matches `WatchTimeGoalMinutes` (in `Settings.jsonc`) for every streamer in `Streamers.json`.