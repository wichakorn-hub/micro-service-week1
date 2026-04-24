
FROM maven:3.9-eclipse-temurin-17 as builder

WORKDIR /app

COPY . .

RUN mvn package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/target/hello-rust-java-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8015

ENTRYPOINT ["java", "-jar", "app.jar"]
