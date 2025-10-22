# 📱 App Mobile Flutter – Guia de Configuração para Desenvolvimento

Este guia irá te ajudar a configurar o ambiente de desenvolvimento do app mobile Flutter usando **Docker no WSL**.  
O objetivo é garantir **consistência de desenvolvimento** entre todos os membros da equipe.

---

## 🧩 Pré-requisitos

### Software Obrigatório

1. **WSL2 com Ubuntu (Obrigatório para todos)**
   - Habilite o WSL2 no Windows  
   - Instale Ubuntu (versão mais recente) da Microsoft Store  
   - Configure o Ubuntu como distribuição padrão  

2. **Docker (Instalar via WSL - Muito mais fácil!)**
   - **NÃO** baixe do site docker.com  
   - Instale diretamente no WSL Ubuntu com os comandos abaixo  

3. **Git**
   - Será instalado junto com as outras dependências no WSL  

---

## ⚙️ Configuração Completa do WSL

Execute estes comandos **dentro do WSL Ubuntu** para instalar tudo que você precisa:

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y docker.io docker-compose git
sudo usermod -aG docker $USER
sudo service docker start
sudo systemctl enable docker
exit
```

**⚠️ IMPORTANTE:** Feche e reabra o terminal WSL após isso.

Verifique se tudo está correto:
```bash
docker --version
docker-compose --version
git --version
```

---

## 🚀 Início Rápido

### 1. Navegue até o Diretório do App Mobile

```bash
cd apps/mobile
```

### 2. Rodando Tudo com Docker Compose (Recomendado)

Do diretório raiz do projeto:

```bash
cd ../..
docker-compose up --build
```

Acesse: **http://localhost:8080**

---

## 📦 Docker – App Mobile (Web)

### Visão Geral

A imagem do **mobile** agora é **multi-stage**, onde:
- O **estágio de build** compila o app Flutter Web.  
- O **estágio final (runtime)** serve os arquivos estáticos via **NGINX**.  

Assim, o container de produção **não contém o SDK do Flutter**.  
Para executar comandos Flutter (`doctor`, `pub`, `run`) durante o desenvolvimento, use:
- Um **container efêmero** com a imagem oficial do Flutter, **ou**
- O serviço **mobile-dev** definido no `docker-compose`.

---

### 🏗️ Produção / Execução (NGINX)

Build e subir **apenas o mobile**:

```bash
docker compose build mobile
docker compose up -d mobile
```

Acesse: **http://localhost:8081** (mapeia 8081:8080)

Rebuild após alterações no código:

```bash
docker compose up -d --build mobile
```

---

### 🧰 Flutter CLI (doctor, version, pub, etc.)

Use a imagem oficial do Flutter (`ghcr.io/cirruslabs/flutter:3.24.3`) para comandos CLI.

#### Linux / WSL

Checar versão e estado do ambiente:
```bash
docker run --rm -it -v "$PWD":/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter --version && flutter doctor -v"
```

Baixar dependências do app mobile:
```bash
docker run --rm -it -v "$PWD/apps/mobile":/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter pub get"
```

#### Windows PowerShell

Checar versão e estado do ambiente:
```powershell
docker run --rm -it -v ${PWD}:/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter --version && flutter doctor -v"
```

Baixar dependências do app mobile:
```powershell
docker run --rm -it -v ${PWD}\apps\mobile:/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter pub get"
```

---

### ⚡ Hot-reload (Web Server) – One-liner

Em algumas montagens (Windows/WSL), compilar shaders diretamente no bind mount pode falhar.  
O comando abaixo copia o código para `/tmp` dentro do container antes de executar.

#### Linux / WSL

```bash
docker run --rm -it -p 8081:8080 -v "$PWD/apps/mobile":/src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc '
WORK=$(mktemp -d) &&
tar -C /src -cf - --exclude=.git --exclude=build --exclude=.dart_tool . | tar -C "$WORK" -xf - &&
cd "$WORK" && flutter clean && flutter pub get &&
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 --web-renderer=html
'
```

Acesse: **http://localhost:8081**

#### Windows PowerShell

```powershell
docker run --rm -it -p 8081:8080 -v ${PWD}\apps\mobile:/src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "
WORK=$(mktemp -d) &&
tar -C /src -cf - --exclude=.git --exclude=build --exclude=.dart_tool . | tar -C $WORK -xf - &&
cd $WORK && flutter clean && flutter pub get &&
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 --web-renderer=html
"
```

---

### 🔁 Hot-reload via docker-compose (Recomendado)

O **serviço de desenvolvimento `mobile-dev`** já está incluso no `docker-compose`.

Ele executa automaticamente o script `scripts/dev-web.sh`  
(cópia segura para `/tmp` + execução via `flutter run`).

Subir com portas mapeadas (usa **8082** no host):

```bash
docker compose run --service-ports mobile-dev
```

Acesse: **http://localhost:8082**

Encerrar: `Ctrl+C` no terminal.

Para rodar novamente, basta executar o comando anterior.

---

### 🧩 Notas Importantes

- O serviço `mobile` serve o **build de produção** via **NGINX** — **não** roda `flutter run`.  
- Use o `mobile-dev` ou containers efêmeros para comandos de desenvolvimento.  
- Para comandos adicionais (`flutter pub outdated`, `flutter test`, etc.),  
  siga os exemplos usando `ghcr.io/cirruslabs/flutter:3.24.3`.

---

## 🧪 Solução de Problemas

### Problemas Comuns

1. **Erro 'ContainerConfig' no docker-compose**
   ```bash
   docker-compose down --volumes --remove-orphans
   docker system prune -a -f
   docker-compose up --build --force-recreate
   ```

2. **Porta já em uso (8080)**
   ```bash
   docker run -it --rm -p 8081:8080 flutter-mobile-app
   ```

3. **Erros de permissão (WSL)**
   ```bash
   sudo usermod -aG docker $USER
   exit
   ```

4. **Docker não está rodando no WSL**
   ```bash
   sudo service docker start
   sudo service docker status
   ```

5. **Flutter doctor mostra avisos**
   ```
   [!] Flutter (Channel unknown, 3.7.7, ...)  ← Normal em container
   [✗] Chrome - develop for the web (...)     ← Normal em container
   [!] Android toolchain (...)                ← Normal em container
   [✓] Linux toolchain ← IMPORTANTE: Deve estar ✓
   [✓] HTTP Host Availability ← IMPORTANTE: Deve estar ✓
   ```

6. **Container não atualiza após mudanças**
   ```bash
   docker build -t flutter-mobile-app . --no-cache
   ```

---

## 👥 Desenvolvimento em Equipe

- Cada dev pode executar sua instância de container (portas distintas)  
- Alterações no código sincronizam via **volume mounts**  
- Não é necessário instalar Flutter localmente  
- Ambientes consistentes em todas as máquinas  

---

## 🎉 Feliz Desenvolvimento Flutter!

> “Build once, run anywhere.” 🚀📱
