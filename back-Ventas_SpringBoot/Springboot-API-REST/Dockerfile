# ETAPA 1: Compilación (Build)
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
# Copiamos solo el pom.xml primero para aprovechar la caché de Docker
COPY pom.xml .
RUN mvn dependency:go-offline
# Copiamos el código fuente y compilamos
COPY src ./src
RUN mvn clean package -DskipTests

# ETAPA 2: Ejecución (Run) - Imagen Liviana
FROM openjdk:17-jdk-slim
WORKDIR /app
# Crear un usuario no root por seguridad (Requerimiento IE1)
RUN addgroup --system springuser && adduser --system springuser --ingroup springuser
USER springuser
# Copiamos solo el archivo .jar generado en la etapa anterior
COPY --from=build /app/target/*.jar app.jar
# Exponemos el puerto (ajusta según el puerto de tu app, ej: 8080)
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
