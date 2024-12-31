FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the JAR file
COPY target/*.jar app.jar

# Config server port
EXPOSE 8222

ENTRYPOINT ["java", "-jar", "app.jar"]