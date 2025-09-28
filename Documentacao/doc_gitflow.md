# Documentação do GitHub Flow para o Projeto CodeRats

## 1) Introdução

Este documento descreve a estratégia de **GitHub Flow** adotada para o desenvolvimento do projeto CodeRats, garantindo integração contínua, revisão de código estruturada e entregas consistentes em ambiente acadêmico.

## 2) Branches Principais

* **main**: Branch de produção. Contém sempre a versão estável do sistema.
* **develop**: Branch de integração. Aqui são mescladas as features prontas antes de ir para o main.
* **feature/**\*: Branches de funcionalidades. Cada nova feature ou bug fix possui uma branch derivada da develop, nomeada conforme `feature/nome-da-feature`.
* **hotfix/**\*: Branches rápidas para correção de problemas críticos em produção, derivadas de main.

## 3) Fluxo de Trabalho

1. Criar branch a partir de **develop**: `feature/nome-da-feature`.
2. Implementar a funcionalidade, realizando commits frequentes e descritivos.
3. Abrir **Pull Request (PR)** para develop, descrevendo as alterações e objetivos da feature.
4. Revisão do PR por outro integrante (ou Tech Lead), verificando consistência de código, padrões de arquitetura e testes.
5. Após aprovação, merge para develop.
6. Testes de integração automatizados executados via GitHub Actions.
7. Quando a develop estiver estável e pronta para release, merge em main.
8. Deploy automatizado através do pipeline CI/CD.

## 4) Boas Práticas

* Commits pequenos e atômicos.
* Mensagens de commit descritivas e no padrão: `tipo: descrição` (ex.: `feat: adicionar autenticação OAuth GitHub`).
* Revisão obrigatória de PRs para garantir qualidade e padronização.
* Uso de labels para categorizar PRs (`feature`, `bugfix`, `hotfix`).
* Atualizar develop antes de iniciar uma nova branch de feature para evitar conflitos.
* Testes automatizados devem ser incluídos sempre que possível.

## 5) Integração com CI/CD

* Cada PR dispara execução de testes via **GitHub Actions**.
* Build automatizado do container para validação da integração.
* Após merge em main, deploy automático em ambiente de produção (AWS ECS Fargate ou Azure Web App).

## 6) RACI Aplicado ao GitHub Flow

| Papel         | Responsabilidade                                                       |
| ------------- | ---------------------------------------------------------------------- |
| Desenvolvedor | Criar branch, commits frequentes, abrir PR, corrigir feedbacks.        |
| Tech Lead     | Revisar PRs críticos, aprovar merges para develop/main.                |
| DevOps        | Configurar e manter pipelines de CI/CD e deploy.                       |

## 7) Conclusão

A adoção do GitHub Flow assegura entregas contínuas, qualidade de código e colaboração eficiente em equipe, mesmo em contexto acadêmico. Este fluxo pode ser adaptado e escalado conforme o projeto evolui para releases mais complexas.
