# Load the PSReadLine module
Import-Module PSReadLine

# Set command history options for older PSReadLine versions
Set-PSReadLineOption -HistorySavePath (Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt')
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# Enable predictive IntelliSense from history
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# (Optional) Set the view style to ListView
Set-PSReadLineOption -PredictionViewStyle ListView

Invoke-Expression (&starship init powershell)


Invoke-Expression (&starship init powershell)

# Function to run fastfetch, but only once per hour
function Invoke-FastfetchWithCooldown {
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

            # If the last run was less than an hour ago, don't run it again
            if ((Get-Date) - $lastRunTime -lt [TimeSpan]::FromHours(1)) {
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

# Run fastfetch with the hourly cooldown
Invoke-FastfetchWithCooldown

function wc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Path
    )

    foreach ($file in $Path) {
        try {
            # Resolve relative paths from the current directory
            $resolved = Resolve-Path -LiteralPath $file -ErrorAction Stop

            # -Raw reads as a single string (faster & accurate for Measure-Object -Word)
            $wordCount = (Get-Content -LiteralPath $resolved -Raw | Measure-Object -Word).Words

            if ($Path.Count -eq 1) {
                # If one file, just output the number
                $wordCount
            }
            else {
                # If multiple, label each
                "{0} : {1}" -f $resolved.Path, $wordCount
            }
        }
        catch {
            Write-Warning "File not found or unreadable: $file"
        }
    }
}

