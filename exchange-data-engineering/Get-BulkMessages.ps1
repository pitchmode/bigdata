<#
.DESCRIPTION    

    Message Threshold default is set to 100

    Usage 
    Bulk Message by subject for the last day:  Get-BulkMessages 
    Messages for custom period:                Get-BulkMessages -DaysBack 10
    Modify Threshold:                          Get-BulkMessages -BulkTreshold 50
#>

Param(
    [Parameter(Mandatory = $false)]
    [int16] $DaysBack = 1,
    [Parameter(Mandatory = $false)]
    [int16] $BulkTreshold = 100
)

$GotSession = Get-PSSession | Where-Object ConfigurationName -eq Microsoft.Exchange

if (-not ($GotSession)) {
    try { Connect-EXOPSSession }
    catch { 
        Write-Host "This script can only run in the Exchange Online powershell module!" -ForegroundColor Red 
        exit
    }
}

$EndDate = Get-Date
$StartDate = (Get-Date -Hour 0 -Minute 00 -Second 00).AddDays(-$DaysBack)

$PageSize = 5000
$Page = 1
$RawMessages = @()

if (((get-date).DayOfWeek -eq 'Monday') -and ($DaysBack -eq 1)) {
    $DaysBack = 3
}

Write-Host "Days of Logs to Analyse: " $DaysBack -ForegroundColor Blue
Write-Host "Retrieving Message Log" -ForegroundColor Blue
do {
    $BufferMessages = Get-MessageTrace -StartDate $StartDate -EndDate $EndDate -PageSize $PageSize -Page $Page
    if ($BufferMessages.count -eq $PageSize) { Write-Host "Results Exceeded $PageSize Record Buffer, Requesting More Logs" -ForegroundColor Blue }
    $RawMessages += $BufferMessages
    $Page = $Page + 1
} until ($BufferMessages.Count -lt $PageSize)

Write-Host "Log Entries:" $RawMessages.Count -ForegroundColor Blue

$RawBulk = $RawMessages | Group-Object Subject, SenderAddress | Where-Object count -gt $BulkTreshold

$BulkMessages = @()
Write-Host "Processing Logs" -ForegroundColor Blue
foreach ($Message in $RawBulk) {
    $SenderAddress = $Message.Group.SenderAddress.Split(',')[0]
    $Subject = $Message.Name.Substring(0, $Message.Name.LastIndexOf(','))
    $TempMessage = New-Object System.Object
    $TempMessage | Add-Member -Type NoteProperty -Name MessageCount -Value $Message.Count
    $TempMessage | Add-Member -Type NoteProperty -Name SenderAddress -Value $SenderAddress
    $TempMessage | Add-Member -Type NoteProperty -Name Subject -Value $Subject
    $BulkMessages += $TempMessage
}

If (-not($BulkMessages)) {
    Write-Host "No Messages over $BulkTreshold threshold have been send during that time period" -ForegroundColor Green
}
else { $BulkMessages | Sort-Object MessageCount -Descending }
