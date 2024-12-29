#!/bin/bash

# Generate microservice certificate
keytool -genkeypair -alias microservice -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore microservice-keystore.p12 -validity 3650 -storepass changeit -dname "CN=localhost, OU=Microservice, O=BrianLukonsolo, L=City, ST=State, C=Country" -ext SAN=dns:localhost,ip:127.0.0.1

# Generate WireMock certificate
keytool -genkeypair -alias wiremock -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore wiremock-keystore.p12 -validity 3650 -storepass changeit -dname "CN=localhost, OU=WireMock, O=BrianLukonsolo, L=City, ST=State, C=Country" -ext SAN=dns:localhost,ip:127.0.0.1
