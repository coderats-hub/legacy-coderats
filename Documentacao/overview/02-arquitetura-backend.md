# CodeRats - Arquitetura do Backend

## 1. Papel do backend

O backend e a camada responsavel por concentrar as regras centrais do sistema. Ele autentica usuarios, organiza grupos, registra check-ins, consolida feeds, controla likes e comentarios, integra com GitHub e apoia fluxos de avaliacao automatizada.

Na pratica, ele funciona como a fonte confiavel de verdade para os dados compartilhados entre usuarios e dispositivos.

## 2. Stack tecnica

O backend utiliza:

1. Java 21.
2. Spring Boot 3.4.10.
3. Spring Web para endpoints REST.
4. Spring Data JPA para persistencia.
5. Spring Security para autenticacao e autorizacao.
6. JWT com JJWT para tokens.
7. Flyway para migracoes de banco.
8. Springdoc OpenAPI para documentacao da API.
9. PostgreSQL como banco principal.
10. AWS SDK S3 para armazenamento de arquivos.

## 3. Organizaçao interna

O codigo esta organizado por responsabilidade tecnica. Os pacotes mais importantes sao:

1. domain, com entidades e regras de negocio.
2. service, com orquestracao de casos de uso.
3. web, com controllers, DTOs e tratamento de respostas HTTP.
4. infra, com repositorios, integracoes e detalhes de implementacao.
5. security, com filtros, contexto de autenticacao e configuracao JWT.

Essa separacao permite que a logica central seja lida sem depender de detalhes de banco, HTTP ou infraestrutura externa.

## 4. Fluxo de uma requisicao

Um endpoint tipico segue este caminho:

1. O controller recebe a requisicao HTTP.
2. Os dados sao convertidos para um DTO e validados.
3. O service aplica regras de negocio e coordena chamadas internas.
4. Os repositorios consultam ou persistem no banco.
5. O controller devolve o DTO de resposta adequado.

Esse fluxo evita que o controller acumule logica indevida e mantem a API previsivel.

## 5. Seguranca

O backend usa autenticacao baseada em JWT. Depois do login, o cliente recebe um token que precisa ser enviado nas requisicoes protegidas. O filtro de seguranca valida esse token antes de liberar acesso aos recursos autenticados.

Do ponto de vista conceitual, isso permite:

1. Autenticacao stateless.
2. Escalabilidade melhor do que sessoes tradicionais.
3. Separacao entre identidade e dados de dominio.

## 6. Persistencia e migracoes

As entidades persistidas sao mapeadas com JPA, enquanto as alteracoes de schema sao versionadas com Flyway. Esse arranjo reduz riscos de divergencia entre ambiente de desenvolvimento, homologacao e producao.

O uso de migracoes tambem cria um historico claro da evolucao estrutural do banco.

## 7. Integracoes externas

O projeto contem pontos de extensao para GitHub, avaliacao automatica de commits e armazenamento de imagens.

### GitHub

A integracao com GitHub permite capturar informacoes externas relacionadas a atividade de desenvolvimento, como dados de commit e vinculacao futura com contas autenticadas.

### IA e avaliacao

O backend possui servicos preparados para consumir analises automatizadas, isolando a comunicacao com o provedor de IA do restante da aplicacao.

### Imagens

O upload de imagens e tratado de forma centralizada, e a referencia final e armazenada no backend com apoio de S3.

## 8. Tratamento de erros

A aplicacao usa um manipulador global de excecoes para transformar erros tecnicos em respostas HTTP consistentes. Isso melhora a previsibilidade do contrato para o frontend e simplifica a depuracao.

## 9. Por que essa arquitetura funciona bem aqui

O backend precisa equilibrar simplicidade e extensibilidade. A solucao adotada entrega um monolito modular, facil de implantar e de entender, sem impedir que novas funcionalidades sejam incorporadas depois.
