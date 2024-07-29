param (
    [Parameter(Mandatory=$true)]
    [string]$logFolderPath
)

function ConvertTo-LocalTime {
    param (
        [datetime]$timeInUTC
    )

    if ($timeInUTC -eq $null) {
        return $null
    }

    return $timeInUTC.ToLocalTime()
}

$outputPath = "C:\shabeeb\SystemTimeCheck"

if (-not (Test-Path -Path $outputPath -PathType Container)) {
    New-Item -Path $outputPath -ItemType Directory
}

$results = @()

$logFiles = @(
    "Security.evtx",
    "Microsoft-Windows-Time-Service%4Operational.evtx",
    "Microsoft-Windows-Time-Service.evtx"
	"Microsoft-Windows-Time-Service%4Operational.evtx"
)

foreach ($logFile in $logFiles) {
    $logFilePath = Join-Path -Path $logFolderPath -ChildPath $logFile

    if (Test-Path $logFilePath) {
        Write-Host "Processing events in $logFilePath"

        $events = Get-WinEvent -Path $logFilePath

        $filteredEvents = $events | Where-Object { $_.Id -eq 4616 -or $_.Id -eq 52 -or $_.Id -eq 261 }

        foreach ($event in $filteredEvents) {
            $result = [PSCustomObject]@{
                LogName      = $event.LogName
                EventID      = $event.Id
                TimeChanged  = ConvertTo-LocalTime -UtcTime $event.TimeCreated
                User         = $event.Properties[1].Value
                Description  = $event.Message
                EventData    = $event.Properties | ForEach-Object { $_.Value }
            }

            Write-Output $result

            $results += $result
        }
    }
    else {
        Write-Host "Log file not found: $logFilePath"
    }
}

		# Write the events to a text file
        $results | Format-List | Out-File -FilePath "$outputPath\TimeChangeEvents.txt" -Encoding UTF8

        # Write the events to a json file
        $results | ConvertTo-Json | Out-File -FilePath "$outputPath\TimeChangeEvents.json" -Encoding UTF8

		$results | Export-Csv -Path "$outputPath\TimeChangeEvents.csv" -NoTypeInformation
		

Write-Host "System Time Change events are exported to $outputPath"


#Security EventID 4616
#The system time was changed. This is the most reliable Event ID we will use to detect time slipping 
#[Microsoft-Windows-Time-Service] EventID 52
#This event is important to monitor significant system time alterations
#[Microsoft-Windows-Time-Service] EventID 261
#W32time service changed the time

