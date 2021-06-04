$ErrorActionPreference = "SilentlyContinue"

Clear-Host

$Sender = Read-Host "Sender"
$Recipient = Read-Host "Recipient"
$Start = Read-Host "*Start (MM/DD/YYYY HH:mm)"
$End = Read-Host "*End (MM/DD/YYYY HH:mm)"
$Path = Read-Host "CSV-file path (disk:\directory)"

$Servers = Get-TransportService

if (!$Servers) {

    $Servers = Get-TransportServer

}

foreach ($Server in $Servers) {

    $File = $Path + "\"+ $Server.Name + ".txt"

    if ($Path) {

        Get-MessageTrackingLog -Server $Server.Name -ResultSize unlimited -Start $Start -End $End | where {$_.Sender -like "*$Sender*" -and $_.Recipients -like "*$Recipient*"} | select Timestamp, ClientHostname, Source, OriginalClientIp, EventId, @{n='Recipients';e={$_.Recipients -join ";"}}, RecipientCount, Sender, TotalBytes, MessageSubject | Export-Csv -Path $File -Delimiter "?" -Encoding UTF8 -NoTypeInformation -Verbose
    
    } else {

        Get-MessageTrackingLog -Server $Server.Name -ResultSize unlimited -Start $Start -End $End | where {$_.Sender -like "*$Sender*" -and $_.Recipients -like "*$Recipient*"} | select Timestamp, ClientHostname, Source, OriginalClientIp, EventId, Recipients, RecipientCount, Sender, TotalBytes, MessageSubject | Out-GridView 

    }

}
