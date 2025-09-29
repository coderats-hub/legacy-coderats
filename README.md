# CodeRats 🚀

**CodeRats** é um aplicativo que transforma a rotina de estudo de estudantes de tecnologia em um **jogo motivacional**. Através de check-ins diários, pontuação e rankings, os alunos acompanham sua evolução, competem de forma saudável e transformam consistência em hábito.

Em vez de estudar sozinho, os usuários participam de **desafios em grupo**, compartilham conquistas e recebem reconhecimento por pequenas vitórias, tornando o aprendizado mais leve, divertido e contínuo.

---

## 🎯 Objetivos

* Incentivar a **constância nos estudos** por meio de **gamificação**.
* Facilitar a criação de **grupos com metas definidas**.
* Registrar **check-ins com foto e geolocalização**.
* Destacar evolução em **placares semanais**.
* Futuras integrações com **GitHub** e **IA** para feedback de código.

---

## 🛠 Stack Tecnológica

| Camada         | Tecnologia                    |
| -------------- | ----------------------------- |
| Frontend       | Flutter                       |
| Backend        | SpringBoot                    |
| Banco de Dados | PostgreSQL + SQLite (offline) |
| Hospedagem     | AWS                           |
| CI/CD          | GitHub Actions                |
| Ambiente Dev   | Docker                        |

---

## 📦 Estrutura do Repositório

O projeto segue o padrão **monorepo**, organizado em:

```
Codigo/
├── .github/               → Configurações de automação e workflows
│   └── workflows/main.yml → Pipeline de build, testes e deploy
├── apps/                  → Aplicações do projeto
│   ├── backend            → API em Node.js (NestJS)
│   └── mobile             → Aplicativo Flutter (Android/iOS)
├── packages/              → Pacotes e utilitários compartilhados
├── .gitignore             → Arquivos ignorados pelo Git
├── docker-compose.yml     → Containers para desenvolvimento
└── README.md              → Este documento

Documentacao/                  → Documentação do projeto
├── doc_base.md        → Arquitetura e planejamento
└── doc_gitflow.md     → Guia de fluxo de trabalho (GitHub Flow)
```

---

## 🚀 Releases

| Release | Funcionalidade                                         |
| ------- | ------------------------------------------------------ |
| **R1**  | Check-ins com foto e geolocalização                    |
| **R2**  | Integração com GitHub via OAuth                        |
| **R3**  | Análise de código com IA e feedback automatizado       |
| **R4**  | Associações de grupos a repositórios para comparativos |

---

## 👥 Equipe

**Integrantes:**

[![Alice](https://img.shields.io/badge/GitHub-Alice-<cor>?style=for-the-badge&logo=github)](https://github.com/alicesalim)

[![Felipe](https://img.shields.io/badge/GitHub-Felipe-<cor>?style=for-the-badge&logo=github)](https://github.com/nkdwon)

[![Gustavo](https://img.shields.io/badge/GitHub-Gustavo-<cor>?style=for-the-badge&logo=github)](https://github.com/GhrCastro)

[![Laura](https://img.shields.io/badge/GitHub-Laura-<cor>?style=for-the-badge&logo=github)](https://github.com/username)

[![Mariana](https://img.shields.io/badge/GitHub-Mariana-<cor>?style=for-the-badge&logo=github)](https://github.com/marialmeida1)

[![Raquel](https://img.shields.io/badge/GitHub-Mariana-<cor>?style=for-the-badge&logo=github)](https://github.com/raksmotta)

**Professores responsáveis:**

* Cristiane Neri Nobre
* Cristiano Neves Rodrigues

**Papéis na equipe:**

* **Product Owner** Raquel de Parde
* **Tech Lead:** Mariana Almeida
* **Dev Mobile:**
* **Dev Backend:** Alice Salim
* **DevOps:** Gustavo
* **Trainee:** Laura Menezes

> Todos atuam de forma colaborativa e transversal em tarefas críticas.

---

## ✅ Status Atual

* Versão do documento de arquitetura: **1.13**
* Projeto em fase inicial: definição de arquitetura, planejamento e organização de repositório.
* Funcionalidades principais de **gamificação e check-ins** já em desenvolvimento.

---

## 📖 Contribuição

Para contribuir, siga nosso **GitHub Flow** descrito em [`docs/doc_gitflow.md`](./docs/doc_gitflow.md) e consulte [`docs/doc_base.md`](./docs/doc_base.md) para referência de arquitetura e padrões.
