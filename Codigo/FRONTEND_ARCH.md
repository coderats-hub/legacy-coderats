# Documentação de Arquitetura Flutter

## 1. Objetivo

Esta documentação tem como objetivo guiar o time na construção de aplicações Flutter usando um padrão **reduzido de Clean Architecture** com **Riverpod** para gerenciamento de estado.

Ela serve tanto como **manual de implementação** quanto **introdução teórica** aos conceitos usados, permitindo que todos compreendam o motivo das escolhas e consigam evoluir o projeto de forma organizada.

Se você não entendeu muito bem o que é Clean Architecture, Observer Pattern, ou SOLID, recomendamos uma rápida pesquisa sobre esses conceitos:

* Clean Architecture: Robert C. Martin (Uncle Bob)
* Observer Pattern: comportamento de “assinar e ser notificado”
* SOLID: princípios de design orientado a objetos

---

## 2. Estrutura do Projeto

### 2.1 Pastas principais

```
lib/
 ├─ main.dart
 ├─ core/              # Utilidades e constantes compartilhadas
 │   ├─ exceptions.dart
 │   └─ app_config.dart
 ├─ shared/            # Widgets reutilizáveis
 │   ├─ app_button.dart
 │   ├─ app_input.dart
 │   └─ theme.dart
 └─ features/          # Cada funcionalidade do app
     ├─ auth/
     │   ├─ data/         # Repositórios e fontes de dados (API, SQLite)
     │   ├─ domain/       # Modelos e regras de negócio
     │   └─ presentation/ # UI + Providers (estado)
     └─ checkin/
         ├─ data/
         ├─ domain/
         └─ presentation/
```

**Dica**: Se não entendeu a diferença entre domínio, dados e apresentação, veja sobre **camadas de Clean Architecture**.

---

## 3. Camadas e responsabilidades

| Camada                                      | O que contém                                                          | Observações                                                                                                                                   |
| ------------------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **UI (presentation/screens/widgets)**       | Widgets visuais, telas, componentes pequenos                          | Não deve conter regras de negócio nem acesso direto a banco/API. Use **providers** para ler e atualizar estado.                               |
| **Provider/State (presentation/providers)** | Estado da tela, ações que modificam o estado, chamadas a repositórios | Aqui aplica-se o **Observer Pattern**: widgets “assistem” mudanças de estado via `ref.watch`. Evite colocar regras complexas de negócio aqui. |
| **Domínio (domain)**                        | Modelos, entidades, serviços de regras de negócio                     | Aplicam princípios do **SRP e OCP do SOLID**. Se não entendeu, veja sobre **Use Cases** em Clean Architecture.                                |
| **Dados (data/repositories/datasources)**   | Comunicação com API, SQLite, cache local                              | Aplicam **Repository Pattern**. Não deve ter lógica de UI ou estado.                                                                          |

---

## 4. Providers e gerenciamento de estado

* **Provider/Riverpod** é responsável por **gerenciar o estado da tela** e **notificar a UI** quando algo muda.
* Use `ref.watch(provider)` quando o widget precisa **observar mudanças de estado**.
* Use `ref.read(provider.notifier)` quando quiser **disparar ações** sem reconstruir o widget.
* **Exemplo**: estado de check-ins (`loading`, `sucesso`, `erro`) deve estar no provider, não no widget.

**Se não entendeu bem o Provider**, veja sobre **Observer Pattern e State Management no Flutter**.

---

## 5. Implementação prática de uma feature (ex.: Check-in)

### 5.1 Data

* Arquivos: `checkin_repository.dart`, `checkin_api.dart`, `checkin_local.dart`
* Responsabilidade: buscar, salvar, atualizar dados.
* Deve expor **interfaces** simples, não detalhes da API ou SQLite.

### 5.2 Domain

* Arquivos: `checkin.dart`, `checkin_service.dart`
* Responsabilidade: regras de negócio da feature (ex.: validar check-in antes de salvar).
* Não deve se preocupar com UI ou estado da tela.

### 5.3 Presentation

* **Screens**: containers que exibem widgets e observam provider
* **Widgets**: componentes que recebem dados prontos e callbacks
* **Provider**: concentra estado, chama repositório, notifica widgets

**Exemplo visual de hierarquia:**

```
CheckinScreen (Container)
 ├─ CheckinFeedWidget
 │    ├─ CheckinCardWidget
 ├─ RankingWidget
 └─ FilterBarWidget
```

---

## 6. Boas práticas para manter o padrão

1. **Separation of Concerns**

   * Não misture UI, estado e lógica de negócio.
2. **Provider é o cérebro da tela**

   * Ele manipula o estado e dispara ações.
   * Evite colocar regras complexas dentro dele.
3. **Repositórios isolam a fonte de dados**

   * Mudou a API ou banco local? Só o repositório precisa mudar.
4. **Widgets pequenos e reaproveitáveis**

   * Cada widget deve ter **uma única responsabilidade visual**.
5. **Nomenclatura consistente**

   * Ex.: `*_screen.dart` para telas, `*_widget.dart` para componentes, `*_provider.dart` para providers.
6. **Teste sempre**

   * Teste use cases e repositórios isoladamente. UI é testada via integração.

**Se não entendeu bem essas boas práticas**, veja sobre **SOLID e Clean Architecture na prática**.

---

## 7. Evolução futura

Mesmo usando essa versão reduzida:

* É fácil adicionar **Use Cases** ou camadas mais formais.
* Pode migrar para **arquitetura completa MVVM + Clean Architecture** sem reescrever a UI.
* Providers podem ser trocados ou refinados sem quebrar o app.

---

## 8. Referências para estudo

* [Clean Architecture – Uncle Bob](https://www.amazon.com.br/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164)
* [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
* [Riverpod Documentation](https://riverpod.dev/)
* [Observer Pattern](https://refactoring.guru/design-patterns/observer)
