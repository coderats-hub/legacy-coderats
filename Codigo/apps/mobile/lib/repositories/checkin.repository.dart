// ==============================
// Arquivo: features/checkin/data/checkin.repository.dart
// ==============================
//
// Pasta 'data':
// Esta pasta é responsável por lidar com **todos os dados da feature**, ou seja:
// - Buscar, salvar ou atualizar informações vindas de **API**, **banco local** ou **cache**.
// - Transformar dados recebidos da API em modelos de domínio.
// - Fornecer dados de forma consistente para o domínio ou provider, sem que eles precisem saber a origem.
//
// Além do repositório, a pasta 'data' pode conter:
//
// 1. Datasources
//    - checkin.api.dart → comunicação com APIs externas
//    - checkin.local.dart → leitura/escrita em banco local (SQLite, Hive, SharedPreferences)
//    - checkin.cache.dart → cache temporário em memória ou disco
//
// 2. Interfaces / Abstrações
//    - i_checkin.repository.dart → define a “promessa” do repositório
//      permitindo trocar implementações sem impactar domínio ou UI
//
// 3. Mappers / Transformers
//    - checkin.mapper.dart → converte JSON para modelo de domínio e vice-versa
//
// 4. Mock ou dados de teste
//    - checkin.mock.dart → dados fictícios para demonstração ou testes sem backend
//
// 5. Exceções específicas da camada de dados
//    - checkin.exceptions.dart → erros relacionados a API, banco ou cache
//
// Dessa forma, a pasta 'data' concentra tudo que é relacionado à **obtenção e manipulação de dados**, mantendo
// a arquitetura limpa, desacoplada e facilitando testes.

import '../domain/checkin.dart';

class CheckinRepository {
  // Função que simula a busca de check-ins
  // Retorna uma lista de Checkin após 1 segundo de delay
  Future<List<Checkin>> fetchCheckins() async {
    // Simula tempo de resposta da API ou do banco de dados
    await Future.delayed(const Duration(seconds: 1));

    // Retorna dados fixos apenas para exemplo
    return [
      Checkin(id: '1', title: 'Check-in 1', date: DateTime.now()),
      Checkin(id: '2', title: 'Check-in 2', date: DateTime.now()),
    ];
  }
}

// ==============================
// Como usar esse repositório:
//
// Exemplo dentro de um Use Case ou Provider:
// final repository = CheckinRepository();
// final checkins = await repository.fetchCheckins();
//
// Observações:
//
// 1. Em um app real, você substituiria os dados fixos por:
//    - Chamadas HTTP para a API
//    - Leitura/escrita em SQLite ou SharedPreferences
//
// 2. O repositório **não deve conter lógica de UI** ou estado da tela.
//    Ele só entrega os dados prontos para a camada de domínio ou provider.
//
// 3. Caso a fonte de dados mude, só precisamos alterar este arquivo,
//    sem impactar as outras camadas.
//
// 4. Lembre-se: a pasta 'data' pode crescer e conter múltiplos arquivos
//    para gerenciar diferentes fontes de dados, mappers, mocks e exceções,
//    mantendo sempre a separação de responsabilidades.
