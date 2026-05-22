# Migrations PostgreSQL

## 1. Objetivo

Este documento registra o schema inicial PostgreSQL criado para o backend atual do CodeRats.

O backend usa JPA, Flyway e `spring.jpa.hibernate.ddl-auto=validate`. Portanto, em um banco limpo, o Flyway precisa criar todas as tabelas esperadas pelas entidades antes da validacao do Hibernate.

Migration versionada:

- `Codigo/apps/backend/src/main/resources/db/migration/V1__create_initial_schema.sql`

## 2. Entidades JPA auditadas

As entidades persistidas atualmente sao:

- `User` -> tabela `users`
- `Group` -> tabela `groups`
- `GroupParticipant` -> tabela `group_participants`
- `Checkin` -> tabela `checkins`
- `CheckinLike` -> tabela `checkin_likes`

## 3. Decisoes de schema PostgreSQL

Tipos principais:

- ids Java `UUID` usam `uuid`;
- `OffsetDateTime` usa `timestamptz`;
- textos sem tamanho especifico usam `varchar(255)`, conforme default JPA/Hibernate;
- campos com `columnDefinition = "TEXT"` usam `text`;
- `boolean` Java usa `boolean`;
- `int` Java usa `integer`;
- `Long githubId` usa `bigint`.

Chaves e constraints:

- `users.id`, `groups.id` e `checkins.id` sao chaves primarias UUID;
- `group_participants` usa chave composta `(user_id, group_id)`;
- `checkin_likes` usa chave composta `(checkin_id, user_id)`;
- `users.email`, `users.github_user`, `users.github_id` e `groups.code` possuem constraints unique;
- `group_participants`, `checkins` e `checkin_likes` possuem FKs para `users`, `groups` e `checkins`.

Indices adicionais foram criados para os acessos atuais dos repositorios:

- busca de grupos por usuario;
- ranking de participantes por grupo e pontos;
- feed/checkins por grupo, usuario, data e pontos;
- contagem/consulta de likes por checkin e usuario.

## 4. Diferenca para o SQL MySQL antigo

O arquivo historico `Artefatos/coderats.sql` foi gerado por MySQL Workbench e nao representa o runtime atual do backend.

Principais diferencas:

- tabelas antigas usam nomes em portugues e singular, como `Usuario`, `Grupo`, `Check_in`, `Curtida`;
- entidades atuais usam nomes em ingles e plural, como `users`, `groups`, `checkins`, `checkin_likes`;
- o SQL antigo usa ids `INT AUTO_INCREMENT`; o backend atual usa `UUID`;
- o SQL antigo usa `DATE`, `DATETIME` e `TINYINT`; o schema atual usa `timestamptz` e `boolean`;
- tabelas antigas como `Badge`, `Comentario`, `Commits`, `Usuario_possui_Badge` e `Check_in_possui_Commits` nao possuem entidades JPA no backend atual;
- `group_participants.role` substitui o antigo campo booleano `admin` como representacao de papel;
- `checkin_likes` atual modela curtidas por chave composta `(checkin_id, user_id)`, sem `id_curtida` incremental.

Por isso, o SQL MySQL antigo deve ser tratado apenas como inventario historico. A fonte principal para migracao PostgreSQL/Azure deve ser a combinacao das entidades JPA atuais, repositorios e migrations Flyway versionadas.

## 5. Validacao esperada

Em um PostgreSQL limpo:

1. O Flyway executa `V1__create_initial_schema.sql`.
2. O Hibernate valida o schema com `ddl-auto=validate`.
3. O backend sobe sem depender de criacao manual de tabelas.

Comando base para validar manualmente com um PostgreSQL limpo:

```bash
cd Codigo/apps/backend
./mvnw -q -DskipTests package

SPRING_PROFILES_ACTIVE=local \
DB_URL=jdbc:postgresql://localhost:5432/coderats_db \
DB_USER=coderats_user \
DB_PASS=<senha> \
SECURITY_JWT_SECRET=replace-with-at-least-64-random-characters-for-hs512-signing \
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

O log esperado deve conter a execucao do Flyway e a inicializacao da aplicacao sem erro de validacao de schema.
