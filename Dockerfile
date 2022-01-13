FROM openjdk:8-jre-alpine

WORKDIR /app
COPY /target/odos-java-microservice*.jar /app/target/

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/target/odos-java-microservice-0.1.0.jar"]