FROM openjdk:8-jdk-alpine
COPY ./target/*.jar /app/ted-search.jar
COPY ./application.properties /app/application.properties
WORKDIR /app
ENTRYPOINT ["java", "-jar", "ted-search.jar", "--spring.config.location=./application.properties"]
