# Arquitetura do Front-End

Este documento descreve a implementação atual do aplicativo Flutter do CodeRats.

## 1. Visão geral

O app foi implementado com Flutter e Dart 3.2+, usando uma estrutura modular por responsabilidade, mas não segue a versão formal de Clean Architecture com Riverpod que estava no texto antigo.

Na prática, o projeto usa:

* telas em `views`
* entidades e modelos em `domain`
* acesso a API em `repositories` e `services`
* persistência local em `database`
* configuração e sessão em `core`
* componentes compartilhados em `shared`

## 2. Stack atual

As dependências presentes no projeto são:

* Flutter SDK
* `http`
* `connectivity_plus`
* `sqflite`
* `shared_preferences`
* `flutter_dotenv`
* `google_fonts`
* `google_mobile_ads`
* `flutter_file_dialog`
* `url_launcher`
* `intl`
* `table_calendar`
* `uuid`
* `path`

## 3. Estrutura real do código

As pastas existentes em `lib/` são:

* `core`
* `database`
* `domain`
* `repositories`
* `services`
* `shared`
* `views`

Essa é a organização realmente usada hoje. Não existe uma pasta `features/` no estado atual do repositório.

## 4. Inicialização do app

O ponto de entrada está em `main.dart`.

O que acontece na inicialização:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. carregamento do `.env`
3. inicialização do Google Mobile Ads quando suportado
4. carregamento da sessão pelo `SessionManager`
5. execução do `MaterialApp`

## 5. Navegação e telas

O app usa rotas nomeadas definidas no `MaterialApp`.

As telas principais hoje são:

* onboarding
* login / início
* home
* feed
* grupos
* criação de grupo
* entrada em grupo
* detalhes de grupo
* ranking de grupo
* perfil privado
* code exchange

## 6. Estado e padrão de desenvolvimento

O documento antigo citava Riverpod, mas isso não reflete o código atual.

O que existe hoje é uma abordagem mais simples, baseada em:

* `StatefulWidget`
* serviços e repositórios
* sessão persistida localmente
* detecção de conectividade

Ou seja: o estado não está centralizado em providers de Riverpod no código atual.

## 7. Camada de dados

O app trabalha com dois modos de acesso:

* remoto, via API HTTP
* local, via SQLite e preferências salvas

Os arquivos mais importantes desse fluxo são:

* `services/api_service.dart`
* `services/http_client.dart`
* `services/local_database.dart`
* `repositories/*`
* `database/*`

## 8. Offline e ambiente

O projeto já tem uma abstração para detectar o ambiente de dados.

O arquivo `core/data_environment.dart` identifica:

* se está rodando na web
* se há conectividade
* se existe banco local disponível
* qual é o usuário atual da sessão

Na prática, isso separa bem os cenários:

* web tende a operar remoto
* mobile pode operar com base local e sincronização parcial

## 9. Componentes e visual

O app possui uma camada de componentes compartilhados em `shared/components` e temas em `shared/theme`.

Isso inclui:

* botões
* avatares
* barras de navegação
* modais
* alertas e diálogos
* tipografia e tokens de tema

## 10. Correções em relação à versão anterior

O texto antigo foi ajustado porque ele descrevia um padrão de arquitetura que não está implementado hoje.

O que foi corrigido:

* removida a referência a Riverpod
* removida a pasta `features/` inexistente
* substituída a estrutura teórica por `core/database/domain/repositories/services/shared/views`
* descrita a inicialização real do app em `main.dart`
* descritos os fluxos reais de conectividade, sessão e ads

