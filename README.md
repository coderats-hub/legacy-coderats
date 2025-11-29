# CodeRats 🚀

**CodeRats** é um aplicativo que transforma a rotina de estudo de estudantes de tecnologia em um **jogo motivacional**. Através de check-ins diários, pontuação e rankings, os alunos acompanham sua evolução, competem de forma saudável e transformam consistência em hábito.

Em vez de estudar sozinho, os usuários participam de **desafios em grupo**, compartilham conquistas e recebem reconhecimento por pequenas vitórias, tornando o aprendizado mais leve, divertido e contínuo.

---

* Alice Salim Khouri Antunes
* Felipe Barros Ratton de Almeida
* Gustavo Henrique Rodrigues de Castro
* Laura Menezes Heráclito Alves
* Mariana Almeida Mendonça
* Raquel de Parde Motta

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
* Rosilane Ribeiro da Mota
* Pedro Henrique Ramos Costa
* Ilo Amy Saldanha Rivero

## Instruções de Utilização

### Versão Web

A aplicação Web pode ser acessada pelos ambientes abaixo:

  - **Ambiente  Produtivo (Em manutenção):**  
  http://coderats-web-estatico-prd.s3-website.us-east-2.amazonaws.com/

    ``` O ambiente produtivo acabou de ser migrado para uma nova conta da aws onde conseguimos USD 200 em créditos, portanto ainda está com falhas na infraestrutura, portanto utilize STG ou DEV que estão stable```
- **Ambiente de desenvolvimento:**  
  http://coderats-web-estatico-dev.s3-website.us-east-2.amazonaws.com/

- **Ambiente de homologação:**  
  http://coderats-web-estatico-stg.s3-website.us-east-2.amazonaws.com/

---

### Versão Mobile

#### Requisitos

1. Emulador Android que não utilize VMWare nativamente  
   (recomendado: **Android Studio** ou **BlueStacks 5**),  
   **OU**  
2. Dispositivo Android físico para instalação do APK.  
3. Observação: **iOS ainda não é suportado.**

---

#### Como Baixar

1. Vá até a nossa pipeline CI/CD no github actions do repositório, e então clique no arquivo ZIP contendo o APK:

   ![GIF_funcionamento](https://github.com/user-attachments/assets/9f10e2f8-430d-4014-b9ba-f506c6b34762)

   ```O APK a ser baixado deve ser o da run mais recente da pipeline ocorrido com sucesso na branch de Development para garantia de funcionamento correto das funcionalidades ```

2. O download será iniciado:

   <img width="430" height="99" src="https://github.com/user-attachments/assets/717bdaf3-310d-4ee6-959f-7db093b4c78a" />

3. Extraia o arquivo `.apk` de dentro do `.zip`:

   <img width="690" height="182" src="https://github.com/user-attachments/assets/11684cf3-8619-49e3-849d-608c7f3e9c43" />

---

### Instalação

#### Se estiver usando **Emulador**

- Arraste o arquivo **APK** para dentro do emulador.  
- A instalação começará automaticamente.

#### Se estiver usando **Dispositivo Android**

1. Envie o arquivo APK para o celular (USB, e-mail, Drive etc.).
2. Ative a permissão para instalar apps de fontes desconhecidas.
3. Abra o APK pelo gerenciador de arquivos e instale.

#### Se estiver usando **Outros Dispositvos**

  Suporte para outros dispositvios está chegando em breve!
  ```O suporte para ios e liberação do app na google store depende da criação de guardrails de segurança, completude da infraestrutura para múltiplos usuários e das estratégias de escalabilidade, adição de ads e criação de planos assinados dentro da plataforma```
  
  ---

