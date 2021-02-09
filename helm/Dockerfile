FROM openjdk:17-jdk-alpine
RUN addgroup -S spring && adduser -S spring -G spring
RUN wget https://github.com/kubino148/pp5-voucherstore-11/releases/download/v0.1.3/application.jar -O /usr/local/lib/demo.jar

USER spring:spring


#
#
# Package stage
#

ENTRYPOINT ["java","-jar","/usr/local/lib/demo.jar"]




