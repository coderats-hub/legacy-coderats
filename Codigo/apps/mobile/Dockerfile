FROM cirrusci/flutter:stable

# Cria usuário flutteruser
RUN useradd -ms /bin/bash flutteruser

# Instala dependências Linux necessárias para build
USER root
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    clang \
    git \
    wget \
    gnupg \
    software-properties-common \
    xvfb \
 && rm -rf /var/lib/apt/lists/*

# Instala Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# Ajusta permissões do Flutter SDK
RUN chown -R flutteruser:flutteruser /sdks/flutter

# Volta para o usuário normal
USER flutteruser

# Configura Flutter channel
RUN cd /sdks/flutter && git remote set-url origin https://github.com/flutter/flutter.git || git remote add origin https://github.com/flutter/flutter.git
RUN cd /sdks/flutter && git fetch origin
RUN cd /sdks/flutter && git checkout origin/stable -B stable || echo "Using existing Flutter version"

WORKDIR /home/flutteruser/app

# Define variáveis de ambiente
ENV DISPLAY=:99
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

# Copia pubspec primeiro (para cache)
COPY pubspec.* ./
RUN flutter pub get || echo "Nenhum pubspec.yaml encontrado, pulando flutter pub get"

# Copia o restante do código
COPY . .

EXPOSE 8080

CMD ["sh"]
