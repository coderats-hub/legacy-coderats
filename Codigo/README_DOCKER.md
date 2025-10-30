# 📱 App Mobile Flutter – Guia de Configuração para Desenvolvimento

Este guia irá te ajudar a configurar o ambiente de desenvolvimento do app mobile Flutter usando **Docker no WSL**.  
O objetivo é garantir **consistência de desenvolvimento** entre todos os membros da equipe.

---

### 🧩 Pré-requisitos

#### Software Obrigatório

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

### ⚙️ Configuração Completa do WSL

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

## 🚀 Início Rápido - Frontend

#### 1. Navegue até o Diretório do App Mobile

```bash
cd apps/mobile
```

#### 2. Rodando Tudo com Docker Compose (Recomendado)

Do diretório raiz do projeto:

```bash
cd ../..
docker-compose up --build
```

Acesse: **http://localhost:8080**

---

### 📦 Docker – App Mobile (Web)

#### Visão Geral

A imagem do **mobile** agora é **multi-stage**, onde:
- O **estágio de build** compila o app Flutter Web.  
- O **estágio final (runtime)** serve os arquivos estáticos via **NGINX**.  

Assim, o container de produção **não contém o SDK do Flutter**.  
Para executar comandos Flutter (`doctor`, `pub`, `run`) durante o desenvolvimento, use:
- Um **container efêmero** com a imagem oficial do Flutter, **ou**
- O serviço **mobile-dev** definido no `docker-compose`.

---

#### 🏗️ Produção / Execução (NGINX)

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

#### 🧰 Flutter CLI (doctor, version, pub, etc.)

Use a imagem oficial do Flutter (`ghcr.io/cirruslabs/flutter:3.24.3`) para comandos CLI.

###### Linux / WSL

Checar versão e estado do ambiente:
```bash
docker run --rm -it -v "$PWD":/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter --version && flutter doctor -v"
```

Baixar dependências do app mobile:
```bash
docker run --rm -it -v "$PWD/apps/mobile":/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter pub get"
```

###### Windows PowerShell

Checar versão e estado do ambiente:
```powershell
docker run --rm -it -v ${PWD}:/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter --version && flutter doctor -v"
```

Baixar dependências do app mobile:
```powershell
docker run --rm -it -v ${PWD}\apps\mobile:/src -w /src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "flutter pub get"
```

---

#### ⚡ Hot-reload (Web Server) – One-liner

Em algumas montagens (Windows/WSL), compilar shaders diretamente no bind mount pode falhar.  
O comando abaixo copia o código para `/tmp` dentro do container antes de executar.

###### Linux / WSL

```bash
docker run --rm -it -p 8082:8080 -v "$PWD/apps/mobile":/src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "
cd /src &&
flutter clean &&
flutter pub get &&
flutter run --hot -d web-server --web-hostname=0.0.0.0 --web-port=8080 --web-renderer=html
"
```

Acesse: **http://localhost:8081**

###### Windows PowerShell

```powershell
docker run --rm -it -p 8081:8080 -v ${PWD}\apps\mobile:/src ghcr.io/cirruslabs/flutter:3.24.3 bash -lc "
WORK=$(mktemp -d) &&
tar -C /src -cf - --exclude=.git --exclude=build --exclude=.dart_tool . | tar -C $WORK -xf - &&
cd $WORK && flutter clean && flutter pub get &&
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 --web-renderer=html
"
```

---

#### 🔁 Hot-reload via docker-compose (Recomendado)

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

#### 🧩 Notas Importantes

- O serviço `mobile` serve o **build de produção** via **NGINX** — **não** roda `flutter run`.  
- Use o `mobile-dev` ou containers efêmeros para comandos de desenvolvimento.  
- Para comandos adicionais (`flutter pub outdated`, `flutter test`, etc.),  
  siga os exemplos usando `ghcr.io/cirruslabs/flutter:3.24.3`.

---

### 🧪 Solução de Problemas

#### Problemas Comuns

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

### 👥 Desenvolvimento em Equipe

- Cada dev pode executar sua instância de container (portas distintas)  
- Alterações no código sincronizam via **volume mounts**  
- Não é necessário instalar Flutter localmente  
- Ambientes consistentes em todas as máquinas  

---

### 🎉 Feliz Desenvolvimento Flutter!

> “Build once, run anywhere.” 🚀📱

## Início Rápido - Backend

Para iniciar crie um arquivo chamado .env na raiz (mesmo nível do docker-compose.yml). Com as seguintes chaves de acesso:

```yml
# --- APP ---
# --- APP ---
SPRING_PROFILES_ACTIVE=dev
APP_PORT=8080

# --- DATABASE ---
POSTGRES_DB=coderats_db
POSTGRES_USER=coderats_user
POSTGRES_PASSWORD=coderats_pass
DB_PORT=5432

# --- PGADMIN ---
PGADMIN_DEFAULT_EMAIL=admin@local.dev
PGADMIN_DEFAULT_PASSWORD=admin
PGADMIN_PORT=5050

```

### Subindo o ambiente completo

Na raiz do projeto:

```bash
docker compose up -d --build
```

Isso fará com que:

1. O PostgreSQL 16 seja inicializado com as variáveis de ambiente acima;
2. O pgAdmin fique disponível na porta **5050**;
3. O backend (Spring Boot) seja compilado e inicializado (executando as migrations do Flyway);
4. O mobile container fique disponível para desenvolvimento.

Verifique os contêineres ativos:

```bash
docker ps
```

Você deve ver algo como:

```
CONTAINER ID   IMAGE              STATUS          PORTS
xxxxxx         postgres:16        Up (healthy)    5432/tcp
xxxxxx         dpage/pgadmin4     Up              0.0.0.0:5050->80/tcp
xxxxxx         codigo-backend     Up              0.0.0.0:8080->8080/tcp
xxxxxx         codigo-mobile      Up              0.0.0.0:8081->8080/tcp
```

---

### Acessando os serviços

| Serviço     | URL                                            | Login                                      |
| :---------- | :--------------------------------------------- | :----------------------------------------- |
| **Backend** | [http://localhost:8080](http://localhost:8080) | —                                          |
| **pgAdmin** | [http://localhost:5050](http://localhost:5050) | E-mail: `admin@local.dev` / Senha: `admin` |

---

### Conectando o pgAdmin ao banco

1. Acesse **[http://localhost:5050](http://localhost:5050)**
2. Clique em **Add New Server**
3. Aba **General**:

   * *Name:* `local-db`
4. Aba **Connection**:

   * *Host name/address:* `db`
   * *Port:* `5432`
   * *Username:* `coderats_user`
   * *Password:* `coderats_pass`
5. Clique em **Save**

Você poderá visualizar:

* As tabelas criadas pelas migrations (`users`, etc.)
* A tabela de controle do Flyway (`flyway_schema_history`)

---

### Verificando as migrations

#### Opção 1 – Via pgAdmin

Abra a tabela **flyway_schema_history** → *View/Edit Data → All Rows*
Cada migration aplicada aparece listada com:

* `version` (ex.: `1`)
* `description` (ex.: `init`)
* `success = true`

#### Opção 2 – Via terminal

```bash
docker exec -it coderats_db psql -U coderats_user -d coderats_db -c \
"SELECT version, description, installed_on, success FROM flyway_schema_history ORDER BY installed_rank;"
```

---

### Estrutura de migrations

Os arquivos SQL ficam em:

```
apps/backend/src/main/resources/db/migration/
 ├── V1__init.sql
 └── V2__add_status_to_users.sql
```

#### Exemplo de migration inicial

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

Ao reiniciar o backend, o Flyway aplicará automaticamente novas versões (`V2__...`, `V3__...` etc.).

#### Boas práticas com Migrations (Flyway)

* **Sempre use versionamento incremental**
  Nomeie os arquivos como `V1__init.sql`, `V2__add_users.sql`, `V3__update_email_index.sql` — mantendo a ordem numérica e **dois underscores** (`__`).

* **Nunca edite uma migration já aplicada**
  Se precisar mudar algo em uma tabela existente, **crie uma nova migration** (ex.: `V4__alter_table_users.sql`).
  Alterar uma migration antiga gera erro de *checksum* e quebra o histórico.

* **Verifique o resultado no banco**
  Confira a tabela `flyway_schema_history` para confirmar o sucesso de cada versão.

* **Mantenha `spring.jpa.hibernate.ddl-auto=validate`**
  Isso garante que o Hibernate apenas **valide** o schema, sem criar nem alterar nada automaticamente — deixando o controle 100% nas migrations.

* **Use scripts reversíveis (opcional)**
  Sempre que possível, adicione comandos que permitam desfazer alterações (DROP, DELETE, etc.) para facilitar rollbacks em ambiente de testes.

* **Sincronize a numeração entre branches**
  Em times, coordene a criação de novas migrations para evitar conflitos (duas `V5__...` diferentes).

## Estrutura do Projeto

```
Codigo/
 ├── apps/
 │   ├── backend/              # Projeto Spring Boot
 │   │   ├── src/
 │   │   └── Dockerfile
 │   └── mobile/               # Projeto Flutter (opcional)
 │       ├── src/
 │       └── Dockerfile
 ├── docker-compose.yml        # Orquestração dos serviços
 ├── .env                      # Variáveis de ambiente
 └── README.md
```