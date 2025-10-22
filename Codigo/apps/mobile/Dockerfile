###########
# Build   #
###########
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

# Preparar artefatos para web (sem trocar de canal)
RUN flutter config --no-analytics \
 && flutter precache --web

WORKDIR /app

# Cache de dependências (aproveita camadas de build)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copia o restante do código
COPY . .

# Build web para pasta dedicada (fora de mounts do host)
RUN flutter build web --release --web-renderer=html --output /app/build/web

############
# Runtime  #
############
FROM nginx:alpine AS runtime

# Cria usuário compatível com docker-compose
RUN addgroup -S flutteruser && adduser -S -G flutteruser flutteruser

# Copia artefatos do build
COPY --from=build /app/build/web /usr/share/nginx/html

# Config NGINX para escutar na porta 8080 e SPA fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Porta de execução
EXPOSE 8080

# Ajusta permissões para executar NGINX sem root
RUN mkdir -p /var/cache/nginx /var/run/nginx \
 && chown -R flutteruser: /var/cache/nginx /var/run /usr/share/nginx/html

# Executa como flutteruser (compatível com docker-compose)
USER flutteruser

CMD ["nginx", "-g", "daemon off;"]
