# CodeRats - Dados, Offline e Integracoes

## 1. Visao geral dos dados

O sistema trabalha com dados locais e remotos ao mesmo tempo. O backend armazena a verdade central no PostgreSQL, enquanto o mobile mantem uma copia local seletiva em SQLite para acelerar leituras e permitir funcionamento parcial sem internet.

Essa estrategia e conhecida como abordagem offline-first em partes do fluxo.

## 2. Modelagem de dados

O dominio do projeto inclui entidades como usuario, grupo, check-in, like, comentario e resumo de atividade. Esses objetos sustentam a maior parte das telas e dos endpoints principais.

A modelagem busca garantir que:

1. Cada usuario tenha identidade propria.
2. Grupos representem comunidades de estudo ou trabalho.
3. Check-ins registrem evidencias de atividade.
4. Interacoes sociais, como likes e comentarios, fiquem ligadas ao conteudo principal.

## 3. Banco local

No app mobile, SQLite e usado para persistir informacoes temporarias e suportar leitura rapida. O banco local e importante quando o usuario nao esta conectado ou quando a resposta da rede ainda nao chegou.

O objetivo aqui nao e substituir o backend, mas evitar que a experiencia fique totalmente bloqueada por dependencia de rede.

## 4. Sincronizacao

A sincronizacao acontece quando o cliente consegue reenviar ou atualizar dados locais no servidor. Em termos teoricos, isso exige:

1. Identificar o que foi criado localmente.
2. Controlar o estado da operacao pendente.
3. Reexecutar o envio quando a rede voltar.
4. Resolver conflitos simples de consistencia quando necessario.

Esse modelo reduz perda de informacao e melhora a experiencia em conexoes instaveis.

## 5. Integracao com GitHub

O projeto possui servicos e controllers dedicados a integrações com GitHub. Essa camada abstrai a comunicacao com a API externa e evita que o restante da aplicacao precise conhecer detalhes de OAuth ou de formatos especificos de resposta.

Conceitualmente, essa integracao serve para enriquecer o perfil do usuario com sinais de atividade tecnica e abrir caminho para metricas de evolucao.

## 6. Integracao com IA

A avaliacao automatizada por IA e tratada como um servico separado. Isso e importante porque o consumo de IA tende a ter latencia, custo e variabilidade maiores do que operacoes internas simples.

Separar esse fluxo ajuda a:

1. Controlar dependencias externas.
2. Limitar o impacto de falhas do provedor.
3. Preservar o restante do sistema mesmo quando a analise nao estiver disponivel.

## 7. Upload e armazenamento de imagem

As evidencias de check-in dependem de imagens. Em vez de manter o binario diretamente na camada de dominio, o sistema trabalha com referencias de arquivo e integra armazenamento remoto via backend.

Isso reduz o peso dos objetos persistidos e simplifica a distribuicao de conteudo.

## 8. Consistencia e rastreabilidade

Ao combinar dados locais, remotos e integrações externas, o maior desafio e manter rastreabilidade. Por isso, o sistema precisa de identificadores estaveis, contratos claros e respostas previsiveis entre app e API.

## 9. Resultado tecnico

Essa estrategia torna possivel:

1. Usar o app com conectividade irregular.
2. Reduzir retrabalho visual e tecnico no cliente.
3. Aumentar a confiabilidade da escrita remota.
4. Evoluir para novos conectores externos sem reescrever a base.
