$Organization = "Branddirektion München"
$OrganizationUnit = "IT 25"
$Country = "DE"
$EMail = "bfm.it2-betrieb_alarmuebertragungsanlagen@muenchen.de"
$Domain = "bma-m.loc"
$Location = "München"
$State = "Bayern"

Do {

$Hostname = Read-Host "Wie lautet der NetBIOS Name des Hosts?"
$FQDN = "$Hostname.$Domain"
$IPAdress = Read-Host "Wie lautet die IP Adresse des Hosts?"

$confirmation = Read-Host "Die Volle FQDN lautet somit: $FQDN, und die IP Adresse ist die $IPAdress. Ist dies richtig? (y/n)"
if ($confirmation -eq "y") {
    $DeviceType = Read-Host "Um welche Art von Host handelt es sich? (Switch, Router, Server)"
    switch ($DeviceType) {
        switch {
            <# Frage nach Lancom Switches fehlt noch. + .pem export sowie -----BEGIN RSA PRIVATE KEY----- replacement #>
            $confirmation_lancom = Read-Host "Handelt es sich um LanCom Switche? (y/n)"
            if ($confirmation_lancom -eq "y") {
                Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
                $PFXCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$FQDN"} | Select-Object -ExpandProperty Thumbprint
                Write-Host $PFXCert
                Export-PfxCertificate 
            }
            Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organization, OU=$OrganizationUnit, S=$State, E=$Email"
        }
        Router {

        }
        Server {
            Get-Certificate -Template "Webserver-ExtendedValidation" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organisation, OU=$OrganizationUnit, S=$State, E=$Email"
        }
     }
    }
}
While ($confirmation -eq "n")

