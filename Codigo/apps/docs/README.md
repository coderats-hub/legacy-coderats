# Documentação da API Code Rats

Bem-vindo à documentação oficial da API Code Rats. Este documento serve como um guia completo para desenvolvedores que desejam integrar ou construir aplicações utilizando nossa plataforma social e gamificada para estudos de programação.

A API é projetada seguindo os princípios RESTful e uma abordagem orientada ao domínio (Domain-Driven Design), garantindo uma interface clara, previsível e consistente.

## Acesso Rápido

  - **Documentação Interativa (SwaggerHub):** [**Acesse a API no SwaggerHub**](https://app.swaggerhub.com/apis-docs/coderats/code-rats-api/1.2.0)
  - **Coleção do Postman:** Para testes rápidos, importe nossa coleção pública diretamente no Postman.

## Organização da API

A estrutura da API é organizada em torno de recursos principais que refletem os conceitos centrais do nosso produto. Entender esses recursos é a chave para utilizar a API de forma eficaz.

#### 1\. **Usuários (`/users`)**

Este é o recurso central para tudo relacionado a contas de usuários.

  - **Autenticação (`/auth`):** Endpoints para registrar (`/register`) e autenticar (`/login`) usuários.
  - **Gerenciamento de Perfil (`/users/me`):** Um alias especial, `/me`, é usado para acessar e modificar os dados do usuário atualmente autenticado. Isso inclui seu perfil, os grupos que participa (`/users/me/groups`) e as badges que conquistou (`/users/me/badges`). Veja mais sobre essa convenção na seção "Convenções da API".
  - **Perfis Públicos (`/users/{userId}`):** Permite visualizar o perfil público de outros usuários na plataforma.

#### 2\. **Grupos (`/groups`)**

Grupos são as comunidades ou desafios onde a interação acontece.

  - Um usuário autenticado pode criar um novo grupo.
  - É possível visualizar os detalhes de um grupo, incluindo seus membros e o feed de check-ins específico daquele grupo.

#### 3\. **Check-ins (`/checkins`)**

O check-in é o coração da plataforma, representando um registro de progresso de estudo feito por um usuário dentro de um grupo.

  - A criação de um check-in está sempre vinculada a um grupo (`/groups/{groupId}/checkins`).
  - O feed principal (`/feed`) agrega os check-ins de todos os grupos que o usuário participa.

#### 4\. **Interações Sociais (`likes` e `comments`)**

As interações sociais são tratadas como sub-recursos de um check-in, garantindo que elas sempre existam dentro de um contexto.

  - **Curtidas (`/checkins/{checkinId}/like`):** Permite que um usuário curta ou descurta um check-in.
  - **Comentários (`/checkins/{checkinId}/comments`):** Permite a criação, visualização e exclusão de comentários em um check-in.

#### 5\. **Badges (`/badges`)**

Este recurso funciona como um catálogo de todas as conquistas disponíveis na plataforma, detalhando o que é necessário para desbloqueá-las.

## Como Usar a API (Fluxo Básico)

Para começar a usar a API, siga este fluxo de autenticação e uso:

1.  **Crie uma Conta:** Faça uma requisição `POST` para `/auth/register` com seu nome, e-mail e senha.

2.  **Faça Login:** Envie seu e-mail e senha para `POST /auth/login`. A resposta incluirá um **token JWT**.

3.  **Autentique suas Requisições:** Para todos os endpoints protegidos, você deve incluir o token recebido no cabeçalho `Authorization` da sua requisição, no formato `Bearer`.

    ```
    Authorization: Bearer <seu-token-jwt>
    ```

4.  **Explore e Interaja:**

      - Liste os grupos que você participa com `GET /users/me/groups`.
      - Faça um check-in em um grupo com `POST /groups/{groupId}/checkins`.
      - Visualize o progresso de outros no seu feed com `GET /feed`.
      - Curta um check-in interessante com `POST /checkins/{checkinId}/like`.

## Como Testar a Documentação

Nossa especificação OpenAPI (`openapi.yaml`) não é apenas um documento estático; é um contrato interativo que pode ser usado para testar e simular a API.

#### 1\. **Usando Ferramentas de UI (Swagger UI, Postman)**

Você pode usar ferramentas populares para visualizar e interagir com a API de forma amigável.

  - **Swagger UI / Editor:**

    1.  Acesse nossa documentação pública e interativa no [**SwaggerHub**](https://app.swaggerhub.com/apis-docs/coderats/code-rats-api/1.2.0).
    2.  A interface do SwaggerHub permite que você explore cada endpoint, veja os modelos de dados e **envie requisições de teste diretamente do seu navegador**.

  - **Postman / Insomnia:**

    1.  Importe o arquivo `openapi.yaml` diretamente na sua ferramenta. Uma coleção completa de requisições será criada automaticamente.

    2.  Para testar os endpoints protegidos, configure a autenticação do tipo "Bearer Token" na coleção, inserindo o JWT obtido no login.

    3.  **Alternativamente, clique no botão abaixo para importar nossa coleção pública diretamente no Postman:**

        [](https://galactic-rocket-826652.postman.co/workspace/Caroneiros~0f84ab9e-7b6b-4f64-9ec1-0e2cd83b022b/collection/27475636-8840903c-8c83-4dc5-84a8-9f8f30f5bd75?action=share&creator=27475636)

#### 2\. **Gerando um Servidor Mock**

Os exemplos detalhados em cada endpoint permitem que as equipes de frontend trabalhem em paralelo com o backend, sem precisar esperar a API estar totalmente funcional.

  - Ferramentas como o [Prism](https://stoplight.io/open-source/prism) podem usar o arquivo `openapi.yaml` para iniciar um servidor de mock localmente.
  - Quando você fizer uma requisição para este servidor mock (ex: `GET /feed`), ele responderá com o dado de exemplo exato que está definido na documentação.

## Convenções da API

  - **A Convenção `/me`:** Para endpoints que operam no contexto do usuário autenticado, utilizamos o alias `/me` em vez de um ID de usuário explícito (ex: `GET /users/me/groups`). Esta abordagem oferece duas vantagens principais:

    1.  **Simplicidade para o Cliente:** A aplicação cliente não precisa armazenar o ID do usuário e inseri-lo em múltiplas URLs. Ela pode simplesmente usar os endpoints `/me` de forma consistente.
    2.  **Segurança:** A responsabilidade de identificar o usuário é inteiramente do backend, que extrai essa informação do token de autenticação. Isso previne que um cliente tente acidentalmente (ou maliciosamente) acessar os dados de outro usuário alterando um ID na URL.

  - **Paginação:** Endpoints que retornam listas de itens utilizam os parâmetros de query `limit` (quantidade de itens por página) e `offset` (a partir de qual item buscar) para paginação.

  - **Respostas de Erro:** Em caso de erro (`4xx` ou `5xx`), a API retornará um objeto JSON padronizado para facilitar o tratamento de falhas:

    ```json
    {
      "statusCode": 404,
      "message": "Recurso Não Encontrado",
      "details": "O check-in com o ID especificado não foi encontrado."
    }
    ```

  - **Códigos de Status HTTP:** Usamos os códigos HTTP de forma semântica para indicar o resultado de uma operação (ex: `201 Created` para criação de recursos, `204 No Content` para exclusão bem-sucedida, `403 Forbidden` para falta de permissão).