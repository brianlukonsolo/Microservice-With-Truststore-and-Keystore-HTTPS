FROM openjdk:17-jdk-slim

# Create necessary directories
RUN mkdir -p /app/certs

WORKDIR /app

# Copy the application JAR
COPY target/MicroserviceWithTruststoreKeystore-1.0-SNAPSHOT.jar app.jar

# Copy custom CA certificates and update trusted certificates
COPY certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Copy keystores and truststores
COPY certs/*.jks /app/certs/

# Expose the service port
EXPOSE 8041

# Update the CMD to use the truststore
CMD ["java", "-Djavax.net.ssl.trustStore=/app/certs/microservice-truststore.jks", "-Djavax.net.ssl.trustStorePassword=password", "-jar", "app.jar"]

