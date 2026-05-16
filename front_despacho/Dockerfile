# ETAPA 1: Construcción
FROM node:18-alpine AS build
WORKDIR /app

# Argumentos necesarios para Vite (Build Time)
ARG VITE_API_URL_VENTAS
ARG VITE_API_URL_DESPACHOS

# Convertir argumentos en variables de entorno para el proceso de compilación
ENV VITE_API_URL_VENTAS=$VITE_API_URL_VENTAS
ENV VITE_API_URL_DESPACHOS=$VITE_API_URL_DESPACHOS

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# ETAPA 2: Servidor Web
FROM nginx:alpine
# Copiamos el build del front al directorio de Nginx
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
