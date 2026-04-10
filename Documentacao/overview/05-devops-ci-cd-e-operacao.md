# CodeRats - Operacao, Docker e CI/CD

## 1. Objetivo operacional

A camada operacional existe para tornar o projeto reproduzivel em diferentes ambientes. O mesmo codigo precisa rodar em desenvolvimento, homologacao e producao com o minimo de divergencia possivel.

Para isso, o projeto usa conteinerizacao, variaveis de ambiente e pipelines automatizados.

## 2. Docker no desenvolvimento

O arquivo docker-compose organiza os servicos principais:

1. PostgreSQL como banco de dados.
2. PgAdmin para administracao visual.
3. Backend em container proprio.
4. Mobile em container para desenvolvimento web.

Esse arranjo facilita a subida do ambiente completo sem depender de instalacoes manuais em cada maquina.

## 3. Perfis de ambiente

O backend possui perfis separados para local, desenvolvimento, staging e producao. Essa divisao permite variar configuracoes como URLs, credenciais e ajustes de runtime sem alterar o codigo-fonte.

Em termos práticos, perfis evitam que uma configuracao de teste seja acidentalmente promovida para producao.

## 4. Entrega continua

O fluxo de entrega do projeto se apoia em GitHub Actions. A pipeline ajuda a automatizar tarefas como:

1. Build.
2. Execucao de testes.
3. Geração de artefatos.
4. Publicacao em ambiente adequado.

Essa automacao reduz erro humano e melhora a confianca no merge de novas funcionalidades.

## 5. Publicacao e ambientes

O projeto trabalha com ambientes separados para desenvolvimento, homologacao e producao. Essa separacao e importante para validar comportamento antes da liberacao final ao usuario.

Na pratica, o ambiente de homologacao serve como filtro tecnico e funcional antes do deploy definitivo.

## 6. Observabilidade basica

A operacao de sistemas distribuídos precisa de sinais minimos de saude. O projeto se beneficia de logs estruturados, healthchecks e mensagens de erro consistentes para facilitar suporte e depuracao.

## 7. Confiabilidade do deploy

Conteinerizacao e migracoes de banco reduzem variações entre ambientes. Quando o deploy sobe com a mesma base de dependencias, o risco de falhas por diferenca local diminui consideravelmente.

## 8. Porque isso importa no projeto

Como o CodeRats tem multiplas partes integradas, uma operacao previsivel e tao importante quanto a implementacao das features. Sem isso, bugs de ambiente podem ser confundidos com bugs de codigo.
