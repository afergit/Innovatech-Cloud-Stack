# Innovatech Cloud Stack 🚀

Proyecto semestral enfocado en una arquitectura de microservicios, contenedorización y despliegue continuo (DevOps).

## 🛠️ Tecnologías

- **Backend:** Spring Boot (Java 17), Maven.
- **Frontend:** React / Vite.
- **Base de Datos:** PostgreSQL.
- **Infraestructura:** Docker, Docker Compose.
- **Cloud & DevOps:** AWS, GitHub Actions (CI/CD), GitHub Security.

## 📂 Estructura del Proyecto

- `back-Ventas_SpringBoot/`: Microservicio de gestión de ventas.
- `back-Despachos_SpringBoot/`: Microservicio de gestión de despachos.
- `front_despacho/`: Aplicación cliente en React.
- `docker-compose.yml`: Orquestación de contenedores para desarrollo local.

## 🚀 Ejecución Local

Para levantar todo el ecosistema de microservicios localmente, asegúrate de tener Docker instalado y ejecuta:

```bash
docker-compose up --build
```

Esto levantará:
- **Frontend**: Accedible en `http://localhost:80`
- **API Ventas**: Microservicio de backend.
- **API Despachos**: Microservicio de backend.
- **Base de Datos**: PostgreSQL para persistencia de datos.

## ☁️ Despliegue y DevOps

Este proyecto está diseñado para implementarse en **AWS Student** siguiendo prácticas modernas de DevOps:
- **CI/CD**: Flujos de automatización mediante GitHub Actions para construcción y despliegue.
- **Security**: Implementación de escaneo de vulnerabilidades y manejo de secretos.
- **Infraestructura**: Uso de contenedores Docker para garantizar la paridad entre entornos.

---
*Desarrollado para el Proyecto Semestral ISY1101.*
