# CodeRats Mobile

Aplicativo Flutter do projeto CodeRats.

## Visão geral

O app foi desenvolvido para consumo da API do projeto e para operar com suporte local em partes do fluxo.

## Estrutura

* `core` - sessão, ambiente e configuração base
* `database` - tabelas e DAOs SQLite
* `domain` - modelos do aplicativo
* `repositories` - integração com API e dados
* `services` - clientes HTTP, conectividade e serviços auxiliares
* `shared` - componentes, tema e utilitários comuns
* `views` - telas e widgets das features

## Dependências principais

* Flutter SDK
* `http`
* `connectivity_plus`
* `sqflite`
* `shared_preferences`
* `flutter_dotenv`
* `google_fonts`
* `google_mobile_ads`

## Inicialização

O ponto de entrada é `lib/main.dart`.

Na inicialização o app:

1. carrega o arquivo `.env`
2. inicializa o Google Mobile Ads quando disponível
3. carrega a sessão local
4. registra as rotas do aplicativo

## Observação

Este README substitui o texto padrão de projeto novo do Flutter.
