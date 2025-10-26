###########
# Build   #
###########
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

# Pre-cache Flutter web artifacts
RUN flutter config --no-analytics \
 && flutter precache --web

WORKDIR /app

# Cache dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Build Flutter web to a dedicated folder
RUN flutter build web --release --web-renderer=html --output /app/build/web

############
# Runtime  #
############
FROM nginx:alpine AS runtime

# Copy build artifacts into nginx html root
COPY --from=build /app/build/web /usr/share/nginx/html

# NGINX config to listen on 8080 with SPA fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

# Run nginx in foreground (master as root; workers drop to 'nginx' user)
CMD ["nginx", "-g", "daemon off;"]

