$Organisation = "Branddirektion München"
$OrganisationsEinheit = "IT 25"
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
            Get-Certificate -Template "Webserver-ExtendedValidation(2048)" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organisation, OU=$Organisationseinheit, S=$State, E=$Email"
        }
        Router {

        }
        Server {
            Get-Certificate -Template "Webserver-ExtendedValidation" -DnsName "$FQDN" -CertStoreLocation Cert:\LocalMachine\My -SubjectName "CN=$FQDN, C=$Country, L=$Location, O=$Organisation, OU=$Organisationseinheit, S=$State, E=$Email"
        }
     }
    }
}
While ($confirmation -eq "n")

