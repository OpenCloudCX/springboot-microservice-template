FROM openjdk:8-jdk-alpine
# ENV JAVA_HOME="/usr/lib/jvm/jre-openjdk"

RUN apk update && apk add git maven
RUN mkdir /app

COPY . .

RUN mvn clean install
RUN cp /target/*.jar /app/

ENTRYPOINT ["java","-jar","/app/odos-java-microservice*.jar"]