FROM openjdk:8-jdk-alpine
# ENV JAVA_HOME="/usr/lib/jvm/jre-openjdk"

RUN apk update && apk add git maven
RUN mkdir /app

COPY . .

RUN mvn clean install
RUN cp -r /target/ /app/

ENTRYPOINT ["java","-jar","/app/target/odos-java-microservice*.jar"]