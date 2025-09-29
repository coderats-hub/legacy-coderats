# Documento de Arquitetura e Planejamento

**Projeto:** CodeRats para Desenvolvedores (Mobile + API)
**Versão do Documento:** 1.13
**Responsáveis:** Equipe (6 integrantes) — coordenação compartilhada

---

## 0) Sumário Executivo

Este documento descreve a arquitetura proposta para um aplicativo mobile desenvolvido em **Flutter**, sustentado por um backend **SpringBoot** e persistência primária em **PostgreSQL**, complementada por armazenamento local **SQLite** para operações offline.

O sistema visa oferecer uma plataforma de acompanhamento de atividades de desenvolvedores, incluindo registro de check-ins com fotografia e geolocalização, definição de métodos avaliativos e integração futura com métricas de produtividade oriundas do GitHub.

### Objetivos Estratégicos

* **Release 1 (R1 – Check-ins):** Registro individual de atividades com evidências visuais e geoespaciais, gerenciamento de grupos e convites, implementação de método avaliativo inicial.
* **Release 2 (R2 – GitHub):** Integração via OAuth com GitHub para coleta de métricas de contribuição (commits, pull requests, issues), com persistência temporária em cache e agregação no backend.
* **Release 3 (R3 – Avaliação com IA):** Utilização de inteligência artificial para análise de código submetido pelos usuários, gerando feedback automatizado e reportado ao grupo participante.
* **Release 4 (R4 – Times/Repos específicos):** Associação de grupos a repositórios específicos, habilitando visualizações comparativas e análise de desempenho coletivo.

### Stack Tecnológica

* **Frontend:** Flutter (Android/iOS).
* **Backend:** SpringBoot.
* **Banco de Dados:** PostgreSQL (primário) + SQLite (cache offline).
* **Hospedagem:** AWS.
* **Armazenamento de mídia:** Diretamente no backend hospedado no AWS.
* **CI/CD:** GitHub Actions.
* **Ambiente Dev:** Docker.

### Abordagem Organizacional

Monorepo estruturado por módulos de aplicação e infraestrutura, **GitHub Flow** para PRs e revisões, convenções de código, lints e versionamento semântico.
Ferramentas recomendadas para o ambiente de desenvolvimento: **Prettier**, **ESLint**, **Husky** (hooks para commits), e **Commitlint** (padrão de mensagens de commit).
Equipe reduzida (6 integrantes), com responsabilidades primárias, mas todos atuando de forma transversal em tarefas críticas.

---

## 1) Escopo

* Aplicativo Flutter com paradigma **offline-first**, integrando cache e fila de sincronização.
* API RESTful em SpringBoot cobrindo autenticação, gerenciamento de grupos e convites, registro de check-ins, métodos avaliativos e integração GitHub.
* **PostgreSQL** como banco de dados primário; **SQLite** para cache e fila local.
* Armazenamento seguro de imagens e mídias diretamente no backend hospedado no AWS.
* Pipeline **CI/CD** completo para build, análise estática de código e deploy automatizado.
* Observabilidade básica com logs estruturados e métricas de healthcheck.


## 2) Stakeholders e Papéis

| Papel                    | Responsabilidades                                                                 | Nome(s) |
| ------------------------ | --------------------------------------------------------------------------------- | ------- |
| Product Owner            | Backlog, priorização, critérios de aceite                                         | —       |
| Tech Lead                | Decisões técnicas, revisões críticas de PR                                        | —       |
| Dev Mobile               | Implementação Flutter, UI, arquitetura de código, state management, offline, sync | —       |
| Dev Backend              | API, banco de dados, integrações                                                  | —       |
| DevOps                   | CI/CD, gestão de ambientes, custos e deploys                                      | —       |

> Cada membro tem responsabilidade primária em determinadas frentes, mas todos são capazes de contribuir transversalmente em outras áreas do projeto.

---

## 3) Glossário

* **Check-in:** Registro de atividade do usuário contendo fotografia, geolocalização e timestamp vinculado a um grupo.
* **Método avaliativo:** Conjunto de regras para atribuição de pontuação periódica.
* **Offline-first:** Capacidade do aplicativo de operar sem conectividade e sincronizar dados posteriormente.
* **Queue:** Fila local de operações pendentes para sincronização com o backend.
* **State Management:** Estratégia de organização de estado no Flutter (Bloc, Provider ou Riverpod).
* **Feature Modularization:** Organização do código por funcionalidades, promovendo manutenção e escalabilidade.

---

## 4) Decisões de Arquitetura

* **Monorepo** para colaboração e gestão integrada.
* * modular**, com injeção de dependência e validação robusta.
* **PostgreSQL** como persistência primária; **SQLite** para cache local e fila.
* **REST** como protocolo inicial; GraphQL avaliado apenas se necessário.
* **JWT** com refresh tokens, assegurando autenticação segura.
* **Docker** para padronização de ambiente e deploy consistente.
* **CI/CD** via GitHub Actions, com deploy no AWS App Service ou AWS Container Instances.
* **Frontend Flutter:** Arquitetura modular por features, gerenciamento de estado (Bloc/Provider/Riverpod), camadas de apresentação e dados, cache offline e fila de sincronização.

---

## 5) Conclusão

A arquitetura proposta equilibra simplicidade, escalabilidade e consistência técnica, garantindo um ambiente unificado para todos os integrantes do time.
A mudança para **PostgreSQL** como banco primário, a centralização da hospedagem no **AWS** e a inclusão de **IA para análise de código** fortalecem o alinhamento estratégico do projeto.s
