FROM openjdk:8-jdk-alpine as build-jar

WORKDIR /app
RUN apk update && apk add git maven
COPY . .
RUN mvn -q clean install

FROM openjdk:8-jre-alpine as build-image

WORKDIR /app
COPY --from=build-jar /app/target/odos-java-microservice*.jar /app/data/

EXPOSE 8080
CMD java -jar /app/data/odos-java-microservice-0.1.0.jar
