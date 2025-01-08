#!/bin/bash

# Set common variables
STOREPASS="password"
DNAME_MICROSERVICE="CN=localhost, OU=Microservice, O=BrianLukonsolo, L=City, ST=State, C=Country"
DNAME_WIREMOCK="CN=localhost, OU=WireMock, O=BrianLukonsolo, L=City, ST=State, C=Country"
SAN="dns:localhost,ip:127.0.0.1,dns:wiremock,dns:microservice"
VALIDITY=3650

# Generate a custom CA (Certificate Authority)
# This command creates a self-signed root CA certificate and stores it in a keystore
# -genkeypair: Generates a key pair (public and private keys)
# -alias: Assigns a name to the key pair for future reference
# -keyalg: Specifies the key generation algorithm (RSA in this case)
# -keysize: Sets the key size to 2048 bits
# -storetype: Defines the keystore type as PKCS12
# -keystore: Specifies the output keystore file
# -validity: Sets the validity period of the certificate in days
# -storepass: Sets the password for the keystore
# -dname: Specifies the distinguished name for the CA
# -ext: Adds extensions to mark this as a CA certificate
keytool -genkeypair -alias customCA -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore custom-ca-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "CN=CustomCA, OU=Root, O=BrianLukonsolo, L=City, ST=State, C=Country" \
-ext BasicConstraints:critical="ca:true" -ext KeyUsage:critical="keyCertSign,cRLSign"

# Export custom CA certificate
# This command exports the CA certificate from the keystore to a separate file
# -exportcert: Exports the certificate
# -rfc: Outputs the certificate in PEM format
keytool -exportcert -alias customCA -keystore custom-ca-keystore.jks \
-storepass $STOREPASS -file custom-ca.crt -rfc

# Generate microservice keystore signed by custom CA
# This series of commands creates a keystore for the microservice, generates a certificate
# signing request (CSR), signs it with the CA, and imports the signed certificate

# Generate key pair for microservice
keytool -genkeypair -alias microservice -keyalg RSA -keysize 2048 -storetype PKCS12 \
-keystore microservice-keystore.jks -validity $VALIDITY -storepass $STOREPASS \
-dname "$DNAME_MICROSERVICE" -ext "SAN=$SAN"

# Generate CSR for microservice
keytool -certreq -alias microservice -keystore microservice-keystore.jks \
-storepass $STOREPASS -file microservice.csr

# Sign the CSR with the CA
keytool -gencert -alias customCA -keystore custom-ca-keystore.jks \
-storepass $STOREPASS -infile microservice.csr -outfile microservice.crt \
-ext "SAN=$SAN" -validity $VALIDITY

# Import CA certificate into microservice keystore
keytool -importcert -trustcacerts -alias customCA -file custom-ca.crt \
-keystore microservice-keystore.jks -storepass $STOREPASS -noprompt

# Import signed certificate into microservice keystore
keytool -importcert -alias microservice -file microservice.crt \
-keystore microservice-keystore.jks -storepass $STOREPASS -noprompt

# Generate WireMock keystore signed by custom CA
# This process is similar to the microservice keystore generation
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
# This command creates a truststore for the microservice and imports the CA certificate
keytool -importcert -alias customCA -file custom-ca.crt \
-keystore microservice-truststore.jks -storepass $STOREPASS -noprompt

# Create WireMock truststore
# This command creates a truststore for WireMock and imports the CA certificate
keytool -importcert -alias customCA -file custom-ca.crt \
-keystore wiremock-truststore.jks -storepass $STOREPASS -noprompt

# Clean up temporary certificate files
rm microservice.csr microservice.crt wiremock.csr wiremock.crt

# Ensure the certs directory exists and copy keystores/truststores to the volume folder
cp ./*.jks /certs/
cp custom-ca.crt /certs/
