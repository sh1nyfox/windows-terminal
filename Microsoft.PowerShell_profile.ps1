# Set command history options for older PSReadLine versions
Set-PSReadLineOption -HistorySavePath (Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt')
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# Enable predictive IntelliSense from history
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# (Optional) Set the view style to ListView
Set-PSReadLineOption -PredictionViewStyle ListView

Invoke-Expression (&starship init powershell)

# Function to run fastfetch, but only after a specified cooldown period.
function Invoke-FastfetchWithCooldown {
    param(
        # The cooldown period in hours. Defaults to 1 hour.
        [double]$CooldownHours = 1.0
    )
    # Define the path for the timestamp file in the user's temp directory
    $timestampFile = Join-Path $env:TEMP "fastfetch_last_run.txt"

    # Default to running fastfetch
    $shouldRun = $true

    # Check if the timestamp file exists
    if (Test-Path $timestampFile) {
        try {
            # Read the last run timestamp from the file
            $lastRunString = Get-Content $timestampFile
            $lastRunTime = [datetime]::Parse($lastRunString, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)

            # If the last run was within the cooldown period, don't run it again
            if ((Get-Date) - $lastRunTime -lt [TimeSpan]::FromHours($CooldownHours)) {
                $shouldRun = $false
            }
        } catch {
            # If there's an error reading or parsing the file, just proceed to run fastfetch
            # and overwrite the corrupted file.
            Write-Warning "Could not parse timestamp file. Running fastfetch and resetting timestamp."
        }
    }

    if ($shouldRun) {
        # Run fastfetch
        fastfetch

        # Update the timestamp file with the current time in a round-trippable format (ISO 8601)
        (Get-Date).ToString("o") | Set-Content -Path $timestampFile
    }
}

# Run fastfetch with the default hourly cooldown.
# To change the cooldown, pass the -CooldownHours parameter.
# For example, to run it every 30 minutes (0.5 hours):
# Invoke-FastfetchWithCooldown -CooldownHours 0.5
Invoke-FastfetchWithCooldown