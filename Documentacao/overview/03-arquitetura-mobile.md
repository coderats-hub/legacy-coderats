# CodeRats - Arquitetura do Mobile

## 1. Papel do aplicativo mobile

O app mobile e a principal interface de uso do CodeRats. Ele concentra telas de onboarding, autenticacao, grupos, feed, check-ins, perfil e recursos de suporte ao fluxo diario do usuario.

A aplicacao foi estruturada para entregar uma experiencia consistente em dispositivos moveis e, quando necessario, em ambiente web durante desenvolvimento.

## 2. Stack tecnica

O mobile foi implementado com Flutter e Dart 3.x, usando bibliotecas para interface, rede, armazenamento local e utilidades de plataforma.

Dependencias de destaque:

1. http para chamadas de API.
2. connectivity_plus para monitorar conectividade.
3. sqflite para armazenamento local.
4. shared_preferences para preferencia e estado simples.
5. google_fonts e componentes compartilhados para consistencia visual.
6. flutter_dotenv para configuracoes de ambiente.
7. google_mobile_ads para monetizacao futura ou blocos de publicidade.

## 3. Estrutura de codigo

O codigo segue uma organizacao orientada a responsabilidade:

1. core para configuracoes centrais, ambiente e sessao.
2. database para persistencia local e tabelas SQLite.
3. domain para modelos e entidades de negocio.
4. repositories para integracao com API e dados locais.
5. services para orquestracao tecnica e acesso a recursos externos.
6. views para telas, widgets e composicao visual.
7. shared para componentes e temas reutilizaveis.

Essa separacao deixa claro o que e UI, o que e regra de negocio e o que e acesso a dados.

## 4. Estado e experiencia do usuario

No aplicativo, o estado precisa ser previsivel porque a interface muda com frequencia conforme os dados carregam, falham ou sao sincronizados. Por isso, as telas se apoiam em servicos e repositores para manter a logica fora dos widgets.

O beneficio pratico e simples:

1. Widgets ficam mais leves.
2. Reutilizacao aumenta.
3. Testes ficam menos dependentes da UI.
4. Erros de rede e cache podem ser tratados sem contaminar a tela.

## 5. Camadas de apresentacao

As telas sao organizadas por feature. Cada modulo possui seus proprios screens, widgets e componentes visuais, reduzindo a necessidade de compartilhamento excessivo entre partes nao relacionadas do app.

Essa abordagem e util em sistemas com varias areas funcionais, como feed, grupos, perfil e check-ins.

## 6. Componentizacao visual

O projeto possui um conjunto de componentes compartilhados, como cabecalho, botao, avatar, barra de navegacao e modais. Isso reduz duplicacao e torna a interface mais consistente.

Na pratica, componentes pequenos facilitam:

1. Ajustes de layout.
2. Padronizacao de estilo.
3. Acessibilidade e responsividade.
4. Evolucao da identidade visual do produto.

## 7. Tema e design system

O uso de temas centralizados permite controlar tipografia, cores e tokens visuais a partir de um ponto unico. Em um aplicativo com muitas telas, isso evita divergencias estéticas e simplifica manutencao.

## 8. Responsividade

Como o app e executado em telas pequenas e grandes, a interface usa estruturas adaptaveis e componentes reaproveitaveis. Isso ajuda a manter a experiencia aceitavel em Android mobile e em execucoes de desenvolvimento via navegador.

## 9. Contribuicao da arquitetura

O desenho atual evita misturar acesso a rede, cache local e renderizacao em um unico ponto. Esse isolamento torna o mobile mais facil de evoluir e mais resistente a mudancas no backend.
