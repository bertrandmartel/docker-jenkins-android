#!/bin/bash
# generate keystore from cert & key certificate

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo "need 3 arguments : cert, key, destination folder, key password (password is added)"
	exit 1;
fi

rm -f $3/*.p12 $3/*.jks

openssl pkcs12 -export -in $1 -inkey $2 -out $3/cert.p12 -name ALIAS -passout pass:$4

keytool -importkeystore -deststorepass $4 -destkeypass $4 \
        -destkeystore $3/cert.jks -srckeystore $3/cert.p12 -srcstoretype PKCS12 -srcstorepass $4  \
        -alias ALIAS