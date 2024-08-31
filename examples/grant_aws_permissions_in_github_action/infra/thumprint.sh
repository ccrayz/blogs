#/bin/bash

openssl s_client -servername token.actions.githubusercontent.com -showcerts -connect token.actions.githubusercontent.com:443 > ./tmp/cert.crt
LINE=$(cat ./tmp/cert.crt | grep -in 'BEGIN CERTIFICATE' | tail -n 1 | cut -d: -f1)
sed -n "${LINE},/END CERTIFICATE/p" ./tmp/cert.crt > ./tmp/certificate.crt
THUMPRINT=$(openssl x509 -noout -fingerprint -sha1 -in ./tmp/certificate.crt | awk  -F'=' '{print $2}' | sed 's/://g')

echo "{\"thumbprint\": \"$THUMPRINT\"}"