
import 'package:app/domain/checkin/checkin.dart';

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
