# Etapa 1: Compilación del proyecto con Maven y OpenJDK 17
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B || true
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Despliegue en Apache Tomcat 10 (Jakarta EE 10)
FROM tomcat:10.1-jdk17-temurin
LABEL maintainer="Flor Xiomara Medina Salazar <s01269h@upla.edu.pe>"

# Eliminar aplicaciones por defecto de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar el artefacto WAR generado como ROOT.war para acceso directo en http://localhost:8080/
COPY --from=build /app/target/MiPortafolio.war /usr/local/tomcat/webapps/ROOT.war

# Directorio para subida de archivos
RUN mkdir -p /usr/local/tomcat/uploads

EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
