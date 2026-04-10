# CodeRats - Visão Geral da Arquitetura

## 1. Propósito técnico do sistema

O CodeRats é uma plataforma de acompanhamento de estudos e produtividade voltada para estudantes de tecnologia. Do ponto de vista de engenharia, o projeto combina aplicativo mobile em Flutter, API em Spring Boot, persistencia relacional em PostgreSQL e suporte local em SQLite para cenários offline.

O sistema foi desenhado para evoluir em releases incrementais, começando com check-ins, grupos e feed de atividades, e abrindo espaço para integrações futuras com GitHub e análise automatizada de código.

## 2. Visao arquitetural

A arquitetura segue uma divisão clara entre apresentação, regras de negocio e infraestrutura. Na pratica, isso significa que a interface do app e os controladores da API apenas coordenam entradas e saidas, enquanto a logica de negocio fica isolada em servicos, modelos de dominio e casos de uso.

Essa separacao reduz acoplamento, simplifica testes e torna a evolucao do projeto mais previsivel. O resultado e uma base tecnica mais facil de manter mesmo com multiplos fluxos funcionais.

## 3. Componentes principais

### Frontend mobile

O aplicativo foi construido com Flutter para entregar a mesma base de codigo em Android e, futuramente, iOS. A estrutura interna segue uma organizacao por features, com pastas dedicadas para telas, widgets, dominio, repositorios, banco local e servicos de rede.

### Backend

A API usa Spring Boot 3.4.x com Java 21. O backend expõe endpoints REST, aplica validacoes, trata autenticação com JWT, persiste dados com JPA e executa migracoes de schema com Flyway.

### Persistencia

O banco principal e PostgreSQL. No lado mobile, SQLite e usado para cache local e suporte a operacoes sem conectividade. Essa combinacao viabiliza um comportamento offline-first em partes da experiencia do usuario.

### Infraestrutura

O ambiente local e orquestrado com Docker e o ciclo de entrega usa GitHub Actions. Para arquivos de imagem e outras referencias externas, o backend conta com integracao de armazenamento em AWS S3.

## 4. Principios adotados

### Modularizacao por feature

Cada funcionalidade relevante e agrupada em um conjunto de arquivos proximos entre si. Isso evita uma arvore de pastas excessivamente profunda por camada e facilita localizar tudo que pertence ao mesmo caso de uso.

### Baixo acoplamento entre camadas

O dominio nao depende de framework, o que preserva a regra de negocio de detalhes de persistencia, interface ou transporte HTTP. A infraestrutura implementa os contratos definidos pelas camadas superiores.

### Evolucao incremental

O projeto foi pensado para crescer em releases. Primeiro, a base de engajamento e compartilhamento. Depois, integrações externas, avaliacao automatizada e refinamento da experiencia de grupo.

## 5. Fluxo macro de funcionamento

1. O usuario interage com a interface Flutter.
2. A tela chama um repositorio ou servico de apresentacao.
3. A requisicao pode ser atendida pelo banco local ou pela API.
4. O backend valida a entrada, aplica regras de negocio e persiste no PostgreSQL.
5. Se houver dependencia de arquivo, a referencia e tratada por meio de armazenamento externo.
6. A resposta volta para o app e atualiza a UI.

## 6. Beneficios da abordagem

Essa estrutura favorece:

1. Evolucao mais segura do codigo.
2. Reutilizacao de regras de negocio.
3. Testes mais simples em cada camada.
4. Melhor suporte a modo offline.
5. Menor risco ao integrar servicos externos como GitHub e OpenAI.
