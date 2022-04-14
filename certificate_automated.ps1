<#  Importierung der CSV-Datei für die Automatisierung #>
$CSVPath = "C:\Users\d mueller\Downloads\netbox_devices (3).csv" <# Read-Host "Wo wurde die CSV-Tabelle gespeichert? (Absoluter Pfad)"#>
$devices = Import-Csv -Path $CSVPath
$unsecpwd =  Read-Host "Export-Pwd"
$secpwd = Read-Host "Bitte noch einmal Bestätigen" -AsSecureString

$Organization = "Branddirektion München"
$OrganizationUnit = "IT 25"
$Country = "DE"
$EMail = "bfm.it2-betrieb_alarmuebertragungsanlagen@muenchen.de"
$Domain = "bma-m.loc"
$Location = "München"
$State = "Bayern"

<#  Auslesen der .CSV-Datei nach Tags in NetBox und deren Hersteller. Tags: SSL, Webserver (2048bit), Webserver (4096bit)#>
foreach ($device in $devices){
    $HostName = $device.Name
    $Manufacturer = $device.Manufacturer
    $FQDN = "$HostName.$Domain"
    $tags = $device.Tags -split ","
    if ($tags -eq "SSL") {
            if ($tags -eq "Webserver (4096bit)"){
                Write-Host "4096 Zertifikat wird ausgestellt für $FQDN" 
            }
            else {
                Write-Host "2048 Zertifikat wird ausgestellt für $FQDN"
                Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -Password $secpwd
                if ($Manufacturer -eq "LANCOM"){
                    openssl.exe  pkcs12 -in "C:\certs\$FQDN.pfx" -out "C:\certs\$FQDN.pem" -passin pass:$unsecpwd -passout pass:$unsecpwd
                    $PEMContent = Get-Content -Path "C:\certs\$FQDN.pem" 
                    $GoodPEMContent = $PEMContent -replace '-----BEGIN ENCRYPTED PRIVATE KEY-----', '-----BEGIN RSA PRIVATE KEY-----'
                    $VeryGoodPEMContent = $GoodPEMContent -replace '-----END ENCRYPTED PRIVATE KEY-----', '-----END RSA PRIVATE KEY-----'
                    $VeryGoodPEMContent | Set-Content -Path "C:\certs\final\$FQDN.pem"
                }
            }
    }
    else {
        Write-Host "Es wurde kein SSL Tag für $FQDN gefunden."
    }
}


<#
    Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
    $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
    Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -Password $exportpwd
    openssl.exe pkcs12 -in "C:\certs\$FQDN.pfx" -out "C:\certs\$FQDN.pem"
    $PEMContent = Get-Content -Path "C:\certs\$FQDN.pem" 
    $GoodPEMContent = $PEMContent -replace '-----BEGIN ENCRYPTED PRIVATE KEY-----', '-----BEGIN RSA PRIVATE KEY-----'
    $VeryGoodPEMContent = $GoodPEMContent -replace '-----END ENCRYPTED PRIVATE KEY-----', '-----END RSA PRIVATE KEY-----'
    $VeryGoodPEMContent | Set-Content -Path "C:\certs\final\$FQDN.pem"
#>