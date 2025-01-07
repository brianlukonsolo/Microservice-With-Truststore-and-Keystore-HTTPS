#!/bin/bash

# Generate microservice
keytool -genkeypair -alias microservice -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore microservice-keystore.jks -validity 3650 -storepass password -dname "CN=localhost, OU=Microservice, O=BrianLukonsolo, L=City, ST=State, C=Country" -ext SAN=dns:localhost,ip:127.0.0.1

# Generate WireMock certificate
keytool -genkeypair -alias wiremock -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore wiremock-keystore.jks -validity 3650 -storepass password -dname "CN=localhost, OU=WireMock, O=BrianLukonsolo, L=City, ST=State, C=Country" -ext SAN=dns:localhost,ip:127.0.0.1

# Export microservice certificate
keytool -exportcert -alias microservice -keystore microservice-keystore.jks -storepass password -file microservice.cer

# Export WireMock certificate
keytool -exportcert -alias wiremock -keystore wiremock-keystore.jks -storepass password -file wiremock.cer

# Create truststore
keytool -importcert -alias microservice -file microservice.cer -keystore truststore.jks -storepass password -noprompt
keytool -importcert -alias wiremock -file wiremock.cer -keystore truststore.jks -storepass password -noprompt

# Import WireMock certificate into microservice keystore
keytool -importcert -alias wiremock -file wiremock.cer -keystore microservice-keystore.jks -storepass password -noprompt

# Import microservice certificate into WireMock keystore
keytool -importcert -alias microservice -file microservice.cer -keystore wiremock-keystore.jks -storepass password -noprompt

# Clean up temporary certificate files
rm microservice.cer wiremock.cer

# Copy certificates and truststore to certs volume directory
cp ./*.jks /certs/