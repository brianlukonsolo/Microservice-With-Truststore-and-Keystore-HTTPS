FROM openjdk:17-jdk-slim

# Create necessary directories
RUN mkdir -p /wiremock/certs /wiremock/mappings

WORKDIR /wiremock

# Install wget and download WireMock standalone JAR
RUN apt-get update && apt-get install -y wget && \
    wget https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.10.0/wiremock-standalone-3.10.0.jar -O wiremock.jar

# Copy keystores, truststores, and mappings
COPY certs/*.jks /wiremock/certs/
COPY certs/mappings.json /wiremock/mappings/

# Copy custom CA certificates and update trusted certificates
COPY certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Expose the service port
EXPOSE 9091

# Command to run WireMock with HTTPS and truststore configuration
CMD ["java", "-jar", "wiremock.jar", "--https-port", "9091", "--https-keystore", "/wiremock/certs/wiremock-keystore.jks", "--keystore-password", "password", "--https-truststore", "/wiremock/certs/wiremock-truststore.jks", "--truststore-password", "password", "--root-dir", "/wiremock"]


