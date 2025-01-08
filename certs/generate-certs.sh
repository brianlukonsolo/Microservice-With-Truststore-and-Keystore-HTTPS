#!/bin/bash

# Set common variables
STOREPASS="password"
DNAME_MICROSERVICE="CN=localhost, OU=Microservice, O=BrianLukonsolo, L=City, ST=State, C=Country"
DNAME_WIREMOCK="CN=localhost, OU=WireMock, O=BrianLukonsolo, L=City, ST=State, C=Country"
SAN="dns:localhost,ip:127.0.0.1,dns:wiremock,dns:microservice"
VALIDITY=3650

# Generate a custom CA
keytool -genkeypair -alias customCA -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore custom-ca-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "CN=CustomCA, OU=Root, O=BrianLukonsolo, L=City, ST=State, C=Country" \
-ext BasicConstraints:critical="ca:true" -ext KeyUsage:critical="keyCertSign,cRLSign"

# Export custom CA certificate
keytool -exportcert -alias customCA -keystore custom-ca-keystore.jks \
-storepass $STOREPASS -file custom-ca.crt -rfc

# Generate microservice keystore signed by custom CA
keytool -genkeypair -alias microservice -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore microservice-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "$DNAME_MICROSERVICE" -ext "SAN=$SAN"

keytool -certreq -alias microservice -keystore microservice-keystore.jks \
-storepass $STOREPASS -file microservice.csr

keytool -gencert -alias customCA -keystore custom-ca-keystore.jks \
-storepass $STOREPASS -infile microservice.csr -outfile microservice.crt \
-ext "SAN=$SAN" -validity $VALIDITY

keytool -importcert -trustcacerts -alias customCA -file custom-ca.crt \
-keystore microservice-keystore.jks -storepass $STOREPASS -noprompt

keytool -importcert -alias microservice -file microservice.crt \
-keystore microservice-keystore.jks -storepass $STOREPASS -noprompt

# Generate WireMock keystore signed by custom CA
keytool -genkeypair -alias wiremock -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore wiremock-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "$DNAME_WIREMOCK" -ext "SAN=$SAN"

keytool -certreq -alias wiremock -keystore wiremock-keystore.jks \
-storepass $STOREPASS -file wiremock.csr

keytool -gencert -alias customCA -keystore custom-ca-keystore.jks \
-storepass $STOREPASS -infile wiremock.csr -outfile wiremock.crt \
-ext "SAN=$SAN" -validity $VALIDITY

keytool -importcert -trustcacerts -alias customCA -file custom-ca.crt \
-keystore wiremock-keystore.jks -storepass $STOREPASS -noprompt

keytool -importcert -alias wiremock -file wiremock.crt \
-keystore wiremock-keystore.jks -storepass $STOREPASS -noprompt

# Create microservice truststore
keytool -importcert -alias customCA -file custom-ca.crt \
-keystore microservice-truststore.jks -storepass $STOREPASS -noprompt

# Create WireMock truststore
keytool -importcert -alias customCA -file custom-ca.crt \
-keystore wiremock-truststore.jks -storepass $STOREPASS -noprompt

# Clean up temporary certificate files
rm microservice.csr microservice.crt wiremock.csr wiremock.crt

# Ensure the certs directory exists and copy keystores/truststores to the volume folder
cp ./*.jks /certs/
cp custom-ca.crt /certs/
