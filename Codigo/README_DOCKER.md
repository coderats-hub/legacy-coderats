# App Mobile Flutter - Guia de Configuração para Desenvolvimento

Este guia irá te ajudar a configurar o ambiente de desenvolvimento do app mobile Flutter usando Docker no WSL. Isso garante consistência de desenvolvimento entre todos os membros da equipe.

## Pré-requisitos

Antes de começar, certifique-se de ter o seguinte instalado no seu sistema:

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

### Configuração Completa do WSL

Execute estes comandos **dentro do WSL Ubuntu** para instalar tudo que você precisa:

```bash
# Atualize o sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instale Docker, Docker Compose e Git
sudo apt-get install -y docker.io docker-compose git

# Adicione seu usuário ao grupo docker (requer logout/login)
sudo usermod -aG docker $USER

# Inicie o serviço Docker
sudo service docker start

# Configure Docker para iniciar automaticamente
sudo systemctl enable docker

# Reinicie o WSL para aplicar as mudanças
exit
# Reabra o terminal WSL
```

**⚠️ IMPORTANTE**: Após executar os comandos acima, feche e reabra seu terminal WSL para que as mudanças tenham efeito.

### Verificar Instalação

Execute estes comandos **dentro do WSL Ubuntu** para verificar se tudo está correto:

```bash
docker --version
docker-compose --version
git --version
```

## Início Rápido - Mobile

### 1. Navegue até o Diretório do App Mobile

```bash
cd apps/mobile
```

### 2. Opção A: Usando Docker Compose (Recomendado)

Do **diretório raiz do projeto** (study-coderats/), execute todos os serviços:

```bash
# Volte para a raiz do projeto
cd ../..

# Inicie todos os serviços (backend, mobile, database)
docker-compose up --build 
# ou
docker compose up --build 
```

**✅ Isso é normal!** Os containers estão rodando e mostrando logs. 

**Para usar o container mobile:**

1. **Abra um NOVO terminal WSL** (não feche o atual)
2. **Execute** para acessar o container do mobile:
```bash
docker exec -it coderats-mobile sh
```

3. **Dentro do container, execute:**
```bash
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

**Acesse seu app em:** <http://localhost:8080>

**Para parar os containers:** Pressione `Ctrl+C` no terminal original.

**Alternativa - Rodar em background (sem ver logs):**
```bash
# Rode os containers em background
docker-compose up -d --build

# Para acessar o container mobile
docker exec -it coderats-mobile sh

# Para ver logs se necessário
docker-compose logs -f mobile

# Para parar tudo
docker-compose down
```

### 2. Opção B: Executar Apenas o App Mobile

Se você quiser trabalhar apenas no app mobile:

```bash
# Certifique-se de estar no diretório apps/mobile
cd apps/mobile

# Construa a imagem Docker
docker build -t flutter-mobile-app .

# Execute o container
docker run -it --rm -p 8081:8080 flutter-mobile-app
```

**Acesse seu app em:** http://localhost:8081

### Fluxo de Desenvolvimento

#### Dentro do Container

Uma vez que seu container estiver rodando, você terá acesso a um shell onde pode executar comandos Flutter:

```bash
# Verifique a instalação do Flutter
flutter doctor

# Veja o que está disponível
ls -la

# Baixe as dependências
flutter pub get

# Execute a versão web (recomendado para desenvolvimento)
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

#### Desenvolvimento ao Vivo

1. **Faça alterações no código** no seu diretório local `apps/mobile`
2. **Arquivos são sincronizados automaticamente** para o container via volume mounting
3. **Hot reload** funciona quando executando `flutter run`
4. **Veja as mudanças instantaneamente** no seu navegador

#### Comandos Flutter Disponíveis

```bash
# Desenvolvimento
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
flutter hot-reload  # Pressione 'r' durante flutter run
flutter hot-restart # Pressione 'R' durante flutter run

# Testes
flutter test

# Análise
flutter analyze
flutter doctor

# Dependências
flutter pub get
flutter pub upgrade
flutter pub deps

# Build
flutter build web
flutter build linux
```

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

## Solução de Problemas

### Problemas Comuns

1. **Erro 'ContainerConfig' no docker-compose**
   ```bash
   # Limpe containers e imagens antigas
   docker-compose down --volumes --remove-orphans
   docker system prune -a -f
   
   # Reconstrua tudo do zero
   docker-compose up --build --force-recreate
   ```

2. **Porta já em uso (8080)**
   ```bash
   # Use uma porta diferente
   docker run -it --rm -p 8081:8080 flutter-mobile-app
   ```

3. **Erros de permissão (WSL)**
   ```bash
   # Adicione usuário ao grupo docker
   sudo usermod -aG docker $USER
   # Depois faça logout e login novamente no WSL
   ```

4. **Docker não está rodando no WSL**
   ```bash
   # Inicie o serviço Docker
   sudo service docker start
   
   # Verifique se está rodando
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
   - Avisos sobre Android/Chrome são normais em containers
   - Foque no Linux toolchain e HTTP availability estarem ✓

6. **Container não atualiza após mudanças no código**
   ```bash
   # Reconstrua sem cache
   docker build -t flutter-mobile-app . --no-cache
   ```

7. **Falha ao executar Chrome no container**
   ```bash
   # Use web-server ao invés de chrome
   flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
   ```

### Comandos Docker Úteis

```bash
# Ver containers rodando
docker ps

# Parar container específico
docker stop coderats-mobile

# Ver logs
docker logs coderats-mobile

# Acessar shell do container
docker exec -it coderats-mobile sh

# Limpar imagens/containers não utilizados
docker system prune
```

## Dicas de Desenvolvimento

1. **Use modo web-server**: `flutter run -d web-server` é mais confiável que Chrome em containers
2. **Volume mounting funciona**: Suas mudanças locais aparecem imediatamente no container
3. **Hot reload**: Funciona perfeitamente para desenvolvimento rápido - pressione 'r' para recarregar
4. **Flexibilidade de porta**: Use portas diferentes (8081, 8082, etc.) para evitar conflitos
5. **Flutter doctor**: Ignore avisos sobre Android/Chrome no ambiente de container

## O que está Incluído no Container

✅ **Flutter SDK** (canal stable)  
✅ **Ferramentas de build Linux** (cmake, ninja-build, etc.)  
✅ **Google Chrome** (para desenvolvimento web)  
✅ **Display virtual** (Xvfb para operações headless)  
✅ **Todas as dependências** pré-instaladas  

## Saída Esperada do Flutter Doctor

Após a configuração, `flutter doctor` deve mostrar:
```
[✓] Flutter (Channel stable, 3.x.x, ...)
[!] Android toolchain (normal em container)
[✓] Chrome - develop for the web  
[✓] Linux toolchain - develop for Linux desktop
[✓] Connected device (1 available)
[✓] HTTP Host Availability
```

## Próximos Passos

1. **Inicie o container** usando um dos métodos acima
2. **Execute `flutter doctor`** para verificar a configuração
3. **Faça uma mudança de teste** em `lib/main.dart`
4. **Execute o app**: `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0`
5. **Abra o navegador** em http://localhost:8080 (ou 8081)
6. **Veja suas mudanças ao vivo!**

## Desenvolvimento em Equipe

- Cada desenvolvedor pode executar sua própria instância de container
- Use portas diferentes para evitar conflitos
- Mudanças no código são sincronizadas via volume mounts
- Não é necessário instalar Flutter localmente
- Ambiente consistente em todas as máquinas

## Suporte

Se você encontrar problemas:

1. **Verifique este README** para soluções comuns
2. **Confirme os pré-requisitos** estão instalados corretamente
3. **Tente reconstruir** com a flag `--no-cache`
4. **Verifique os logs do Docker** para mensagens de erro detalhadas
5. **Pergunte aos membros da equipe** que já configuraram o ambiente com sucesso

---

Feliz desenvolvimento Flutter! 🚀📱



CONTAINER ID   IMAGE                    COMMAND                  CREATED       STATUS                       PORTS     NAMES
d2369446ea0f   study-coderats_backend   "docker-entrypoint.s…"   3 hours ago   Exited (137) 5 seconds ago             coderats-backend
1ce42c5438d8   study-coderats_mobile    "sh"                     3 hours ago   Exited (137) 5 seconds ago             coderats-mobile
79441ca7f2d1   mongo:7.0                "docker-entrypoint.s…"   3 hours ago   Exited (0) 15 seconds ago              coderats-mongo

![alt text](./image.png)