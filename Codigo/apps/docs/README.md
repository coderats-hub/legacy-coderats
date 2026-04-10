# Documentação da API

Este diretório continha uma documentação baseada em um contrato `openapi.yaml` e em um SwaggerHub público. Isso não representa o estado atual do projeto.

## Situação atual

A API real está no backend Spring Boot e a documentação interativa agora é servida pelo próprio projeto através do Springdoc.

Os caminhos úteis são:

* `/swagger-ui`
* `/v3/api-docs`

## O que mudou

* removida a dependência de SwaggerHub como fonte principal da documentação
* removida a referência a `openapi.yaml` versionado neste repositório
* a documentação passa a descrever o contrato real do backend em execução

## Recursos cobertos hoje

* autenticação e perfil de usuário
* grupos e participantes
* check-ins e feed
* likes e comentários
* integração com GitHub
* avaliação de commits com OpenAI
* upload de imagens com S3

## Observação

Se for necessário gerar documentação estática ou uma coleção de testes, isso deve ser feito a partir do backend atual, não a partir do texto antigo deste arquivo.