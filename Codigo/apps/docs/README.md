# Code Rats API

API da plataforma gamificada **Code Rats**, que permite o gerenciamento de usuários, grupos, checkins e interações sociais.

* **Versão:** 1.0.0
* **Documentação completa:** [SwaggerHub - Code Rats API](https://app.swaggerhub.com/apis-docs/coderats/code-rats-api/1.0.0)

---

## Autenticação

A API utiliza **JWT (Bearer Token)**.
Inclua o token no header das requisições autenticadas:

```http
Authorization: Bearer <seu_token_jwt>
```

---

## Principais Recursos

### 🔑 Authentication

* **POST /auth/login** – Realizar login e obter token JWT.
* **POST /users** – Criar nova conta de usuário.

### 👤 Users

* **GET /users/me** – Consultar perfil autenticado.
* **PATCH /users/me** – Atualizar dados do usuário.
* **DELETE /users/me** – Excluir conta.
* **GET /users/{id}/profile** – Obter perfil público de outro usuário.
* **GET /users/{id}/groups** – Listar grupos de um usuário.

### 👥 Groups

* **POST /groups** – Criar grupo de desafio.
* **GET /groups** – Listar grupos.
* **GET /groups/{id}** – Detalhar grupo específico.
* **PATCH /groups/{id}** – Atualizar grupo (owner/admin).
* **DELETE /groups/{id}** – Excluir grupo (owner).
* **POST /groups/{id}/join** – Entrar em grupo com entry\_code.
* **POST /groups/{id}/leave** – Sair de grupo.

### 📌 Checkins

* **POST /groups/{id}/checkins** – Criar checkin em grupo.
* **GET /groups/{id}/checkins** – Listar checkins de grupo.
* **DELETE /checkins/{id}** – Excluir checkin (autor/admin/owner).
* **POST /checkins/{id}/like** – Curtir checkin.
* **DELETE /checkins/{id}/like** – Remover curtida.
* **POST /checkins/{id}/comments** – Adicionar comentário.
* **GET /checkins/{id}/comments** – Listar comentários.

---

## Modelos Importantes

### User

```json
{
  "id": "uuid",
  "name": "Maria Silva",
  "email": "maria@example.com",
  "institution": "UTFPR",
  "github_url": "https://github.com/mariasilva"
}
```

### Group

```json
{
  "id": "uuid",
  "name": "Grupo Elite",
  "description": "Desafios semanais de programação",
  "start_date": "2025-01-01T00:00:00Z",
  "end_date": "2025-03-01T00:00:00Z",
  "members_count": 12
}
```

### Checkin

```json
{
  "id": "uuid",
  "title": "Resolução do desafio 1",
  "description": "Implementei em Python",
  "likes": 5,
  "created_at": "2025-01-10T15:30:00Z"
}
```

---

## Erros Comuns

Todas as respostas de erro seguem o formato:

```json
{
  "statusCode": 400,
  "message": "Mensagem de erro",
  "errorCode": "BAD_REQUEST"
}
```

