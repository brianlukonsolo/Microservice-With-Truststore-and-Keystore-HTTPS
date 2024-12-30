FROM openjdk:17-jdk-slim

RUN mkdir -p /app/certs

WORKDIR /app

COPY target/MicroserviceWithTruststoreKeystore-1.0-SNAPSHOT.jar app.jar

EXPOSE 8041

CMD ["java", "-jar", "app.jar"]
