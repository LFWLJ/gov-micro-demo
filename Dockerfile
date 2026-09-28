FROM eclipse-temurin:17-jre AS runtime

ARG MODULE
ENV MODULE=${MODULE}
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xms256m -Xmx512m -Dfile.encoding=UTF-8"

WORKDIR /app
COPY ${MODULE}/target/${MODULE}-1.0.0.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]