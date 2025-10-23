#!/usr/bin/env bash
set -euo pipefail

# Copia o código para um diretório temporário no FS do container
WORK="$(mktemp -d)"
echo "Using WORK=$WORK"
tar -C /src -cf - --exclude=.git --exclude=build --exclude=.dart_tool . | tar -C "$WORK" -xf -

cd "$WORK"
flutter clean
flutter pub get

# Sobe o web-server com hot-reload
flutter run -d web-server \
  --web-hostname=0.0.0.0 \
  --web-port=8080 \
  --web-renderer=html

