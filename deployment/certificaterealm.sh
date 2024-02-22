#!/usr/bin/env bash

set -xeu

pw=changeit
clientKeyStore=client_keystore.p12
caCert=selfsigned.cer
warFile=certificaterealm.war
glassFishTar=./glassfish.tgz
glassFishZip=./web-7.0.11.zip
glassFishDir=./glassfish7
glassFishTrustStore=$glassFishDir/glassfish/domains/domain1/config/cacerts.jks


rm -rf "$clientKeyStore" "$caCert" "$glassFishDir"

#tar -xv -f "$glassFishTar"
unzip "$glassFishZip"

#BD create client cert
test -e "$clientKeyStore" || {
keytool -genkey -v -alias selfsignedkey -keyalg RSA -storetype PKCS12 -keystore "$clientKeyStore" -storepass "$pw" -keypass "$pw"  <<EOF
DavidHeffelfinger
BookWritingDivision
EnsodeTechnologyLLC
Fairfax
Virginia
US
Ja
EOF
}

#BD export ca cert
test -e "$caCert" || {
keytool -export -alias selfsignedkey -keystore "$clientKeyStore" -storetype PKCS12 -storepass "$pw" -rfc -file "$caCert"
}

#BD import ca cert to glassfish truststore
keytool -import -file "$caCert" -keystore "$glassFishTrustStore" -keypass "$pw" -storepass "$pw" <<EOF
Ja
EOF

cp "$warFile"  "$glassFishDir/glassfish/domains/domain1/autodeploy/"

export AS_START_TIMEOUT=$(expr 2 \* 60 \* 1000)
#BD Glassfish starten
asadmin start-domain 

#BD Glassfish konfigurieren
asadmin set server.network-config.protocols.protocol.http-listener-2.ssl.tls13-enabled=false
asadmin set server.network-config.protocols.protocol.http-listener-2.http.http2-enabled=false

#BD Glassfish restarten um Aenderungen zu uebernehmen
asadmin restart-domain


cat <<EOF
Glassfish Admin Console:
  http://localhost:4848/common/index.jsf

App:
  https://localhost:8181/certificaterealm/

glassfish stoppen:
  asadmin stop-domain
EOF

#BD Cert Realm erzeugen
# glassfish7/bin/asadmin create-auth-realm --classname com.sun.enterprise.security.auth.realm.certificate.CertificateRealm newCertificateRealm
# http://localhost:8080/filerealmauthhttps
#
# cp /mnt/arbeit/eclipse/workspace/privat/certificaterealm/target/filerealmauthhttps.war glassfish7/glassfish/domains/domain1/autodeploy/
#
# curl http://localhost:8080/filerealmauthhttps/
# curl -k https://localhost:8181/filerealmauthhttps/
# curl -v -k --cert-type P12 --cert client_keystore.p12:changeit  https://localhost:8181/filerealmauthhttps/
#
# keytool  -printcert -sslserver localhost:8181
#
# openssl s_client -connect localhost:8181 -state -debug -cert client_keystore.pem -key client_keystore.pem
#
# glassfish/bin/asadmin set server.network-config.protocols.protocol.http-listener-2.ssl.tls13-enabled=false
# glassfish/bin/asadmin set server.network-config.protocols.protocol.http-listener-2.http.http2-enabled=false
#
#asadmin stop-domain
