#!/bin/bash

# Set common variables
STOREPASS="password"
DNAME_MICROSERVICE="CN=localhost, OU=Microservice, O=BrianLukonsolo, L=City, ST=State, C=Country"
DNAME_WIREMOCK="CN=localhost, OU=WireMock, O=BrianLukonsolo, L=City, ST=State, C=Country"
SAN="dns:localhost,ip:127.0.0.1"
VALIDITY=3650

# Generate microservice keystore
keytool -genkeypair -alias microservice -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore microservice-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "$DNAME_MICROSERVICE" -ext "SAN=$SAN"

# Generate WireMock keystore
keytool -genkeypair -alias wiremock -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore wiremock-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "$DNAME_WIREMOCK" -ext "SAN=$SAN"

# Export microservice certificate
keytool -exportcert -alias microservice -keystore microservice-keystore.jks \
-storepass $STOREPASS -file microservice.cer -rfc

# Export WireMock certificate
keytool -exportcert -alias wiremock -keystore wiremock-keystore.jks \
-storepass $STOREPASS -file wiremock.cer -rfc

# Create microservice truststore and import WireMock certificate
keytool -importcert -alias wiremock -file wiremock.cer \
-keystore microservice-truststore.jks -storetype PKCS12 -storepass $STOREPASS -noprompt

# Create WireMock truststore and import microservice certificate
keytool -importcert -alias microservice -file microservice.cer \
-keystore wiremock-truststore.jks -storetype PKCS12 -storepass $STOREPASS -noprompt

# Clean up temporary certificate files
rm microservice.cer wiremock.cer

# Ensure the certs directory exists and copy keystores/truststores
mkdir -p /certs
cp ./*.jks /certs/
