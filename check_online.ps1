$computers = Get-ADComputer -Filter {OperatingSystem -Like "*server*"} -Properties operatingsystem | foreach {$_.DNSHostName}


foreach ($computer in $computers) {
    $connected = Test-Connection $computer -Count 1 -Quiet
        if ($connected) {
            Write-Host -ForegroundColor Green "$computer - Ist erreichbar"
        }
    }
