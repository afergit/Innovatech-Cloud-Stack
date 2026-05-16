# Innovatech Cloud Stack 🚀

Proyecto semestral enfocado en una arquitectura de microservicios, contenedorización y despliegue continuo (DevOps).

## 🛠️ Tecnologías

- **Backend:** Spring Boot (Java 17), Maven.
- **Frontend:** React / Vite.
- **Base de Datos:** PostgreSQL.
- **Infraestructura:** Docker, Docker Compose.
- **Cloud & DevOps:** AWS, GitHub Actions (CI/CD), GitHub Security.

## 📂 Estructura del Proyecto (Clean Tier Architecture)

Siguiendo el flujo de mejores prácticas (estilo `tienda_perritos`), el proyecto se organiza en carpetas independientes con sus propios archivos de orquestación:

- **`front_despacho/`**: Contiene la App React y su `docker-compose.yml` para despliegue en la instancia Frontend.
- **`back-Ventas_SpringBoot/`**: Contiene la lógica de microservicios y el `docker-compose.yml` para despliegue en la instancia Backend.
- **`db/`**: Contiene el `docker-compose.yml` para la instancia de Base de Datos.

## 🚀 Despliegue y DevOps

Este proyecto utiliza un pipeline de **GitHub Actions** (`main_deploy.yml`) para automatizar el despliegue multi-objetivo:
1. **Instancia Backend**: Se actualizan los microservicios y se conectan a la base de datos.
2. **Instancia Frontend**: Se actualiza la interfaz de usuario una vez que el backend está listo.

### Secretos Necesarios en GitHub:
- `EC2_HOST_FRONT`: IP de la instancia de Frontend.
- `EC2_HOST_BACK`: IP de la instancia de Backend.
- `SSH_PRIVATE_KEY`: Llave para acceso seguro a las instancias.

---
*Desarrollado para el Proyecto Semestral ISY1101.*
