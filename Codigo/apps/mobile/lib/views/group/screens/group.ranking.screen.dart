/**
 * TELA DE RANKING DO GRUPO
 * 
 * Exibe a classificação de todos os membros do grupo ordenados
 * por pontuação de atividades realizadas.
 * 
 * Onde é usada:
 * - Navegação da GroupDetailPage
 * - Rota '/group-ranking' no main.dart
 * 
 * Funcionalidades:
 * - Lista scrollável de usuários ordenados por pontos
 * - Cards individuais para cada membro
 * - Indicador visual de posição no ranking
 * - Troféus especiais para top 3 (ouro, prata, bronze)
 * - Nome e pontuação de cada usuário
 * - Header com título e botão voltar
 * 
 * Dados:
 * - Recebe lista opcional de rankings
 * - Usa dados mockados (sampleRanking) como fallback
 * - Futuramente será integrado com API
 * 
 * Navegação:
 * - Vem de: GroupDetailPage
 * - Volta para: tela anterior (pop)
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';

// Tela que exibe o ranking completo de membros do grupo
class GroupRankingScreen extends StatelessWidget {
  final List<UserRanking>? rankings; // Lista opcional de rankings
  GroupRankingScreen({super.key, this.rankings});

  @override
  Widget build(BuildContext context) {
    // Usa rankings fornecidos ou dados mockados como fallback
    final rankingList = rankings ?? sampleRanking;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      // Header padrão com título e botão voltar
      appBar: AppHeader(
        title: 'Ranking do Grupo',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          itemCount: rankingList.length, // Número de itens na lista
          separatorBuilder: (context, i) => const SizedBox(height: AppSpacing.md), // Espaçamento entre itens
          itemBuilder: (context, i) {
            final user = rankingList[i];
            return Container(
              // Card visual para cada usuário
              decoration: BoxDecoration(
                color: AppColors.surface,                              // Fundo do card
                borderRadius: BorderRadius.circular(AppCorners.md),   // Bordas arredondadas
                border: Border.all(color: AppColors.border, width: 1), // Borda sutil
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  // Indicador de posição circular
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.accent, // Cor roxa do tema
                    child: Text(
                      user.position.toString(),        // Número da posição
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,   // Texto bold
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  
                  // Informações do usuário (nome e pontos)
                  Expanded(
                    child: UserAvatarInfo(
                      label: user.name,                      // Nome do usuário
                      subtitle: '${user.points} pontos',     // Pontuação
                      showAvatar: false,                     // Não mostra avatar extra
                    ),
                  ),
                  
                  // Troféus especiais para top 3
                  if (user.position == 1)
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28) // Ouro
                  else if (user.position == 2)
                    const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28) // Prata
                  else if (user.position == 3)
                    const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 28) // Bronze
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Modelo de dados para representar um usuário no ranking
class UserRanking {
  final int position;     // Posição no ranking (1º, 2º, etc.)
  final String name;      // Nome do usuário
  final double points;    // Pontuação total

  UserRanking({
    required this.position,
    required this.name,
    required this.points,
  });
}

// Dados mockados para demonstração (futuramente virá da API)
final List<UserRanking> sampleRanking = [
  UserRanking(position: 1, name: 'Alice', points: 49.5),     // 1º lugar
  UserRanking(position: 2, name: 'Felipe', points: 45.5),    // 2º lugar
  UserRanking(position: 3, name: 'Gustavo', points: 45.5),   // 3º lugar (empate)
  UserRanking(position: 4, name: 'Bruna', points: 40.0),     // 4º lugar
  UserRanking(position: 5, name: 'Lucas', points: 38.0),     // 5º lugar
  UserRanking(position: 6, name: 'Marina', points: 35.0),    // 6º lugar
  UserRanking(position: 7, name: 'João', points: 30.0),      // 7º lugar
  UserRanking(position: 8, name: 'Paula', points: 28.0),     // 8º lugar
  UserRanking(position: 9, name: 'Rafael', points: 25.0),    // 9º lugar
  UserRanking(position: 10, name: 'Carla', points: 20.0),    // 10º lugar
];
