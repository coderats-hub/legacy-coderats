# Documentação de Produto e Engenharia — CodeRats

Este diretório centraliza os artefatos de planejamento, requisitos e especificações técnicas do projeto CodeRats. Os arquivos aqui contidos documentam desde a visão macro do produto até regras de negócio, integrações e detalhamentos táticos.

## Produto

1. [Produto, GitHub e Microsoft Grader](overview/00-produto-github-grader.md)

## Série técnica

1. [Documento Base da Arquitetura](overview/doc_base.md)
2. [Fluxo GitHub e Governança](overview/doc_gitflow.md)
3. [Índice da Série Técnica](overview/README.md)

## PDF

Os documentos em PDF ficaram concentrados em [Documentacao/pdfs](pdfs).

A seguir, listam-se os artefatos, suas localizações e descrições:

---

- [**doc_CODERATS_projeto.pdf**](pdfs/doc_CODERATS_projeto.pdf)  
  Documentação técnica principal e apresentação do projeto. Contém a fundamentação teórica (baseada em gamificação e neurociência), a composição da equipe multidisciplinar e a visão arquitetural do sistema como ferramenta educacional.

- [**Features List.pdf**](pdfs/Features%20List.pdf)  
  Documento de visão do backlog do produto. Lista Requisitos Funcionais (RF) e Não-Funcionais (RNF), incluindo prioridades, distribuição por Sprint e identificadores (IDs) para rastreabilidade.

- [**Features List - csv.csv**](Features%20List%20-%20csv.csv)  
  Versão estruturada em CSV da lista de funcionalidades. Contém os mesmos dados do PDF (ID, Feature Name, Prioridade, Sprint, Tela), ideal para importação em ferramentas de gestão ou análise de dados.

- [**User Stories e Critérios de Aceite.pdf**](pdfs/User%20Stories%20e%20Crit%C3%A9rios%20de%20Aceite.pdf)  
  Documento que detalha requisitos em formato de Histórias de Usuário. Inclui regras de negócio essenciais, modos de pontuação ("Quantidade" vs. "Frequência"), regras de ranking e cenários de teste (Gherkin/BDD).

- [**Histórias de Tarefa.pdf**](pdfs/Hist%C3%B3rias%20de%20Tarefa.pdf)  
  Documento de planejamento tático da Sprint 01. Decompõe histórias de usuário em tarefas técnicas (Task Stories), definindo happy path inicial, configurações de ambiente (DevOps) e entregáveis de Back-end e Front-end.

- [**Funcionamento Conexão API GitHub.pdf**](pdfs/Funcionamento%20Conex%C3%A3o%20API%20GitHub.pdf)  
  Manual técnico da integração com o GitHub. Descreve a arquitetura OAuth 2.0, endpoints utilizados da API REST, estratégias de obtenção de commits e parâmetros de filtragem.

---
