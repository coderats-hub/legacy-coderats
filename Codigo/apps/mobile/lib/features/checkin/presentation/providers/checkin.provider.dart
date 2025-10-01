// ==============================
// Arquivo: features/checkin/presentation/providers/checkin.provider.dart
// ==============================
//
// Pasta 'presentation/providers':
// Esta pasta é responsável por **gerenciar o estado da tela** e concentrar
// a comunicação entre a UI e a camada de dados (repository) ou domínio (use cases).
//
// Aqui aplicamos o **Observer Pattern**: a UI "assiste" mudanças de estado
// e reage automaticamente sem precisar gerenciar dados diretamente.
//
// O provider nunca deve conter lógica de UI, apenas:
// - Estado da tela (loading, sucesso, erro, dados carregados)
// - Chamadas a repositórios ou use cases
// - Transformações simples dos dados se necessário

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/checkin.repository.dart';
import '../../domain/checkin.dart';

// Enum opcional para representar os estados possíveis da tela
enum CheckinState { loading, success, error }

// ==============================
// StateNotifier para gerenciar o estado da lista de Check-ins
//
// - Herda de StateNotifier do Riverpod, que permite notificar a UI
//   quando o estado muda.
// - Usa AsyncValue para lidar de forma padronizada com:
//     loading, success (dados) e error (erro)
class CheckinNotifier extends StateNotifier<AsyncValue<List<Checkin>>> {
  final CheckinRepository repository;
  CheckinNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadCheckins();
  }
  // Função para carregar os check-ins
  // - Chama o repositório
  // - Atualiza o estado com sucesso ou erro
  Future<void> loadCheckins() async {
    try {
      final checkins = await repository.fetchCheckins();
      state = AsyncValue.data(checkins); // sucesso
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current); // erro
    }
  }
}

// ==============================
// Provider que pode ser usado pela UI
//
// - StateNotifierProvider conecta o StateNotifier à UI
// - O Widget pode usar `ref.watch(checkinProvider)` para observar mudanças
// - O Widget pode usar `ref.read(checkinProvider.notifier)` para disparar ações
final checkinProvider =
    StateNotifierProvider<CheckinNotifier, AsyncValue<List<Checkin>>>(
        (ref) => CheckinNotifier(CheckinRepository()));

// ==============================
// Como usar na UI:
//
// 1. Observar estado:
// final state = ref.watch(checkinProvider);
//
// 2. Disparar ação para carregar dados:
// ref.read(checkinProvider.notifier).loadCheckins();
//
// Observações:
//
// - Todo estado e lógica de carregamento ficam aqui, deixando a UI simples.
// - Facilita testes unitários, pois podemos testar CheckinNotifier isoladamente.
// - AsyncValue ajuda a padronizar o tratamento de loading/success/error.
