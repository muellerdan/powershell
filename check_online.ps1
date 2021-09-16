$computers = Get-ADComputer -Filter {OperatingSystem -Like "*server*"} -Properties operatingsystem | foreach {$_.DNSHostName}


foreach ($computer in $computers) {
    $connected = Test-Connection $computer -Count 1 -Quiet
        if ($connected) {
            Write-Host -ForegroundColor Green -BackgroundColor Black "$computer - Ist online und erreichbar"
        }
        else {
            Write-Host -ForegroundColor Red -BackgroundColor Black "$computer - Nicht über 'Test-Connection' erreichbar, versuche 'Ping'"
        }
    }
