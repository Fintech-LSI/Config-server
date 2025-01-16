# Build stage
FROM maven:3.9.6-amazoncorretto-21 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar
COPY src/main/resources/configurations /app/configurations

RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

EXPOSE 8889

ENV JAVA_TOOL_OPTIONS="-Xms256m -Xmx512m"

ENTRYPOINT ["java", "-jar", "app.jar"]