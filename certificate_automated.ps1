<#  Importierung der CSV-Datei für die Automatisierung #>
$CSVPath = "C:\Users\d mueller\Downloads\netbox_devices (4).csv" <# Read-Host "Wo wurde die CSV-Tabelle gespeichert? (Absoluter Pfad)"#>
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
                Get-Certificate -Template "Webserver-ExtendedValidation" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -ChainOption EndEntityCertOnly -CryptoAlgorithmOption TripleDES_SHA1 -Password $secpwd -Force
                Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item 
            }
            else {
                if ($tags -eq "Webserver (2048bit)"){
                    Write-Host "2048 Zertifikat wird ausgestellt für $FQDN"
                    Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                    $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                    Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "..\certs\$FQDN.pfx" -ChainOption EndEntityCertOnly -CryptoAlgorithmOption TripleDES_SHA1 -Password $secpwd -Force
                    Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item
                    if ($Manufacturer -eq "LANCOM"){
                        openssl.exe  pkcs12 -in C:\certs\$FQDN.pfx -out C:\certs\$FQDN.pem -passin pass:$unsecpwd -nodes
                        $PEMContent = Get-Content -Path "C:\certs\$FQDN.pem" 
                        $GoodPEMContent = $PEMContent -replace '-----BEGIN PRIVATE KEY-----', '-----BEGIN RSA PRIVATE KEY-----'
                        $VeryGoodPEMContent = $GoodPEMContent -replace '-----END PRIVATE KEY-----', '-----END RSA PRIVATE KEY-----'
                        $VeryGoodPEMContent | Set-Content -Path "C:\certs\final\2xxx-Serie\$FQDN.pem"
                     }
                }
                else {
                    if ($tags -eq "Webserver (1024bit)"){
                        Write-Host "1024 Zertifikat wird ausgestellt für $FQDN"
                        Get-Certificate -Template "Webserver-ExtendedValidation(1024)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                        $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                        Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -ChainOption EndEntityCertOnly -CryptoAlgorithmOption TripleDES_SHA1 -Password $secpwd -Force
                        Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item
                        if ($Manufacturer -eq "LANCOM"){
                            openssl.exe  pkcs12 -in C:\certs\$FQDN.pfx -out C:\certs\final\3xxx-Serie\$FQDN.pem -passin pass:$unsecpwd -nodes
                        }
                    }  
                    else {
                        Write-Host "Es wurde ein SSL Tag für $FQDN gefunden, jedoch kein Keylength Tag."
                    } 
            }
        }
    }
    else {
        Write-Host "Es wurde kein SSL Tag für $FQDN gefunden."
        }
}