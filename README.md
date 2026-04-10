# CodeRats

Repositório do projeto CodeRats, dividido entre aplicações, artefatos de documentação e materiais de divulgação.

## Visão geral

O projeto é um monorepo com:

* backend em Spring Boot
* aplicativo mobile em Flutter
* documentação técnica em Markdown e PDF
* artefatos de banco e modelagem

## Estrutura principal

```
Codigo/
├── apps/
│   ├── backend/
│   ├── docs/
│   └── mobile/
├── docker-compose.yml
└── README.md

Documentacao/
├── overview/
├── pdfs/
├── doc_base.md
└── doc_gitflow.md

Artefatos/
└── arquivos do banco e modelagem

Divulgacao/
└── apresentações e vídeos
```

## Stack atual

| Camada | Tecnologia |
| --- | --- |
| Mobile | Flutter |
| Backend | Java 21 + Spring Boot 3.4.10 |
| Banco | PostgreSQL |
| Local | SQLite no mobile |
| Segurança | JWT |
| Documentação da API | Springdoc / Swagger UI |
| Infra local | Docker |
| Integrações | GitHub OAuth, S3, OpenAI |

## Documentação útil

* [Arquitetura do Projeto](Codigo/ARQUITETURA_DO_PROJETO.md)
* [Arquitetura do Backend](Codigo/BACKEND_ARCH.md)
* [Arquitetura do Front-End](Codigo/FRONTEND_ARCH.md)
* [Índice Técnico](Documentacao/overview/README.md)

## Status dos ambientes

Os links públicos antigos de web foram mantidos apenas como referência histórica. A documentação atual deve ser conferida no backend e no app mobile dentro de `Codigo/apps`.

## Equipe

Mantém-se a lista de integrantes já existente no projeto, sem alteração neste ajuste de documentação.

