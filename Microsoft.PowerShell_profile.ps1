# Set command history options for older PSReadLine versions
Set-PSReadLineOption -HistorySavePath (Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt')
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

# Enable predictive IntelliSense from history
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# (Optional) Set the view style to ListView
Set-PSReadLineOption -PredictionViewStyle ListView

Invoke-Expression (&starship init powershell)

fastfetch