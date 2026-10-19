# Build stage
FROM maven:3.9-eclipse-temurin-11 AS build

WORKDIR /build

COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:11-jre

WORKDIR /app

RUN groupadd --system --gid 10001 barcodeapi \
    && useradd --system --uid 10001 --gid barcodeapi --home-dir /app barcodeapi

COPY --from=build /build/target/server.jar /app/server.jar
COPY config /app/config
COPY resources /app/resources

RUN mkdir -p /app/cache /app/logs \
    && chown -R barcodeapi:barcodeapi /app/cache /app/logs

ENV LOG_DIR=/app/logs

EXPOSE 8080

USER barcodeapi

ENTRYPOINT ["java", "-jar", "/app/server.jar", "--port", "8080", "--no-telemetry"]
