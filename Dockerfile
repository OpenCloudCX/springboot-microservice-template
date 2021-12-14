FROM openjdk:8-jdk-alpine as build-jar

WORKDIR /app
RUN apk update && apk add git maven
RUN git clone https://github.com/dstar55/docker-hello-world-spring-boot /app
RUN mvn clean install

FROM openjdk:8-jre-alpine as build-image

WORKDIR /app
COPY --from=build-jar /app/target/hello*.jar /app/data/

EXPOSE 8080
CMD java -jar /app/data/hello-world-0.1.0.jar
