$Organization = ""
$OrganizationUnit = ""
$Country = ""
$EMail = ""
$Domain = ""
$Location = ""
$State = ""

Do {
$Hostname = Read-Host "Wie lautet der NetBIOS Name des Hosts?"
$FQDN = "$Hostname.$Domain"
$IPAdress = Read-Host "Wie lautet die IP Adresse des Hosts?"
$confirmation = Read-Host "Die Volle FQDN lautet somit: $FQDN, und die IP Adresse ist die $IPAdress. Ist dies richtig? (y/n)"
if ($confirmation -eq "y") {
    $DeviceType = Read-Host "Um welche Art von Host handelt es sich? (Switch, Router, Server)"
    switch ($DeviceType) {
        switch {
            $confirmation_lancom = Read-Host "Handelt es sich um LanCom Switche? (y/n)"
            if ($confirmation_lancom -eq "y") {
                $deviceseries = Read-Host "Geht es um die [2]xxx oder [3]xxx Serie)"
                if ($deviceseries -eq "2"){
                    $exportpwd = Read-Host "Bitte geben Sie das Kennwort für den Export ein" -AsSecureString
                Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -Password $exportpwd
                Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item
                openssl.exe pkcs12 -in "C:\certs\$FQDN.pfx" -out "C:\certs\$FQDN.pem" -nodes
                $PEMContent = Get-Content -Path "C:\certs\$FQDN.pem" 
                $GoodPEMContent = $PEMContent -replace '-----BEGIN PRIVATE KEY-----', '-----BEGIN RSA PRIVATE KEY-----'
                $VeryGoodPEMContent = $GoodPEMContent -replace '-----END PRIVATE KEY-----', '-----END RSA PRIVATE KEY-----'
                $VeryGoodPEMContent | Set-Content -Path "C:\certs\final\$FQDN.pem"
                }
                else {
                        Get-Certificate -Template "Webserver-ExtendedValidation(1024)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                        $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                        Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -ChainOption EndEntityCertOnly -CryptoAlgorithmOption TripleDES_SHA1 -Password $exportpwd -Force
                        Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item
                        if ($Manufacturer -eq "LANCOM"){
                        openssl.exe  pkcs12 -in C:\certs\$FQDN.pfx -out C:\certs\final\3xxx-Serie\$FQDN.pem -nodes
                }
            }
            else {
                $exportpwd = Read-Host "Bitte geben Sie das Kennwort für den Export ein" -AsSecureString
                Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -Password $exportpwd
                openssl.exe pkcs12 -in "C:\certs\$FQDN.pfx" -out "C:\certs\final\$FQDN.pem"
            }
        }
        Router {
          $exportpwd = Read-Host "Bitte geben Sie das Kennwort für den Export ein" -AsSecureString
          Get-Certificate -Template "Webserver-ExtendedValidation" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organisation, OU=$OrganizationUnit, S=$State, E=$Email"
          $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
          Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -Password $exportpwd
          Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item
        }
        Server {
          $exportpwd = Read-Host "Bitte geben Sie das Kennwort für den Export ein" -AsSecureString
          Get-Certificate -Template "Webserver-ExtendedValidation" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organisation, OU=$OrganizationUnit, S=$State, E=$Email"
          $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
          Export-PfxCertificate -Cert Cert:\LocalMachine\My\$PFXCert -FilePath "C:\certs\$FQDN.pfx" -Password $exportpwd
          Get-ChildItem Cert:\LocalMachine\My\$PFXCert | Remove-Item
        }
        }
        }
    }
}
While ($confirmation -eq "n")