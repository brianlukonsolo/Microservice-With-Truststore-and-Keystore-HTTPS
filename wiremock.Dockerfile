FROM openjdk:17-jdk-slim

RUN mkdir -p /wiremock/certs

WORKDIR /wiremock

RUN apt-get update && apt-get install -y wget && \
    wget https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.10.0/wiremock-standalone-3.10.0.jar -O wiremock.jar

COPY /certs/*.jks /wiremock/certs/

EXPOSE 9091

CMD ["java", "-jar", "wiremock.jar", "--https-port", "9091", "--https-keystore", "/wiremock/certs/wiremock-keystore.jks", "--keystore-password", "password", "--https-truststore", "/wiremock/certs/wiremock-truststore.jks", "--truststore-password", "password", "--root-dir", "/wiremock"]


