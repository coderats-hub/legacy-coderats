/**
 * TELA DE LISTA DE CHECK-INS
 * 
 * Esta tela exibe uma lista de check-ins (atividades) dos usuários do grupo.
 * Mostra cards com informações de cada check-in incluindo:
 * - Avatar e nome do usuário com pontuação
 * - Card visual colorido representando a atividade
 * - Título, descrição e tempo da atividade
 * - Link para visualizar no GitHub
 * 
 * Funcionalidades:
 * - Lista scrollável de check-ins
 * - Botão para criar novo check-in
 * - Estados de loading, erro e lista vazia
 * - Refresh manual dos dados
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/checkin.repository.dart';
import '../../domain/checkin.dart';
import 'checkin.details.screen.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/comments.modal.dart';

// Tela principal de lista de check-ins - StatefulWidget para gerenciar estados da UI
class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

// Estado da tela de check-ins - controla loading, dados e erros
class _CheckinScreenState extends State<CheckinScreen> {
  // Variáveis para controlar os diferentes estados da UI
  bool _isLoading = true;     // Estado de carregamento
  Object? _error;             // Armazena erro caso ocorra
  List<Checkin> _checkins = []; // Lista de check-ins carregados

  // Instância do repositório para buscar dados
  final _repository = CheckinRepository();

  // initState é chamado uma vez quando o widget é criado
  @override
  void initState() {
    super.initState();
    // A busca de dados é iniciada aqui
    _loadCheckins();
  }

  // Função para buscar os dados e atualizar o estado da tela
  Future<void> _loadCheckins() async {
    // Atualiza a UI para mostrar o estado de carregamento
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repository.fetchCheckins();
      // Em caso de sucesso, atualiza a UI com os dados
      if (mounted) { // Garante que o widget ainda está na árvore
        setState(() {
          _checkins = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Em caso de erro, atualiza a UI com a mensagem de erro
       if (mounted) { // Garante que o widget ainda está na árvore
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: SharedTheme.buildDarkTheme(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: 'Check-ins: Code Rats',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              tooltip: 'Recarregar',
              onPressed: _loadCheckins,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Conteúdo principal
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
        floatingActionButton: AppFAB(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CommitCheckinScreen(),
              ),
            );
          },
          icon: Icons.add,
          tooltip: 'Novo check-in',
        ),
      ),
    );
  }



  // Constrói o corpo da tela baseado no estado atual
  Widget _buildBody() {
    // Mostra loading spinner durante carregamento
    if (_isLoading) {
      return const AppLoading();
    }
    
    // Mostra tela de erro se houver problema
    if (_error != null) {
      return _buildErrorView();
    }
    
    // Mostra tela vazia se não há check-ins
    if (_checkins.isEmpty) {
      return _buildEmptyView();
    }
    
    // Mostra a lista de check-ins
    return _buildCheckinsList();
  }

  // Constrói a tela de erro com botão para tentar novamente
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar check-ins',
              style: SharedTheme.buildDarkTheme().textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro: $_error',
              style: SharedTheme.buildDarkTheme().textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SharedStyledButton(
              text: 'Tentar novamente',
              onPressed: _loadCheckins,
            ),
          ],
        ),
      ),
    );
  }

  // Constrói a tela quando não há check-ins para mostrar
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone ilustrativo
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: const Color(0xFF2BB6A5).withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            // Título da mensagem
            Text(
              'Nenhum check-in encontrado',
              style: SharedTheme.buildDarkTheme().textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Descrição explicativa
            Text(
              'Você ainda não possui check-ins registrados.',
              style: SharedTheme.buildDarkTheme().textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Botão para atualizar
            SharedStyledButton(
              text: 'Atualizar',
              onPressed: _loadCheckins,
            ),
          ],
        ),
      ),
    );
  }

  // Constrói a lista scrollável de check-ins (dados mockados por enquanto)
  Widget _buildCheckinsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posts estáticos baseados na imagem
          _PostCard(
            username: 'Nome Pessoa',
            title: 'Título da Atividade',
            description: 'Descrição da atividade aqui.',
            timeAgo: 'Há 2 dias',
            color: const Color(0xFF8B5A9F),
            isGradient: true,
            gradientColors: const [Color(0xFF4A0A77), Color(0xFF9A24DD)],
            likes: 23,
            comments: 3,
            points: 2,
            githubText: 'Visualizar atividade Github',
          ),
          const SizedBox(height: 16),
          
          _PostCard(
            username: 'Nome Pessoa',
            title: 'Título da Atividade',
            description: 'Descrição da atividade aqui.',
            timeAgo: 'Há 2 dias',
            color: const Color(0xFF25A18E),
            isGradient: true,
            gradientColors: const [Color(0xFF25A18E), Color(0x3325A18E)],
            likes: 15,
            comments: 2,
            points: 3,
            githubText: 'Visualizar atividade Github',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

}

// ======== WIDGETS CUSTOMIZADOS ========

// Widget para rótulos de seção (não usado atualmente, mas disponível)
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

// se não for usar, remover
/* class _CheckinTile extends StatelessWidget {
  const _CheckinTile({required this.checkin});
  final Checkin checkin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon do check-in
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2BB6A5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 24,
              color: Color(0xFF2BB6A5),
            ),
          ),
          const SizedBox(width: 16),
          
          // Informações do check-in
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkin.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(checkin.date),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de status
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF2BB6A5),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} - "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
} */



// Widget que representa um card de check-in/atividade individual
class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.username,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.color,
    required this.isGradient,
    this.gradientColors,
    required this.likes,
    required this.comments,
    required this.points,
    required this.githubText,
  });

  // Propriedades do card
  final String username;         // Nome do usuário
  final String title;           // Título da atividade
  final String description;     // Descrição da atividade
  final String timeAgo;         // Tempo relativo (ex: "Há 2 dias")
  final Color color;           // Cor de fundo do card
  final bool isGradient;       // Se deve usar gradiente
  final List<Color>? gradientColors; // Cores do gradiente
  final int likes;             // Número de likes (comentado no UI)
  final int comments;          // Número de comentários (comentado no UI)
  final int points;            // Pontos ganhos pela atividade
  final String githubText;     // Texto do link do GitHub

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com avatar e nome
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, AppSpacing.lg),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.person, color: AppColors.textPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                username,
                style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '$points pnts',
                style: AppTextStyles.inputHint,
              ),
            ],
          ),
        ),
        // Card colorido principal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Container(
            height: 329,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isGradient && gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: gradientColors!,
                    )
                  : null,
              color: isGradient ? null : AppColors.accent,
              borderRadius: BorderRadius.circular(AppCorners.md),
            ),
            child: Stack(
              children: [
                // Footer GitHub com background opaco
                if (githubText.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppCorners.md),
                          bottomRight: Radius.circular(AppCorners.md),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            githubText,
                            style: AppTextStyles.inputHint.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                            ),
                            child: const Icon(
                              Icons.code_outlined,
                              color: AppColors.textPrimary,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Informações e stats
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*  Stats (likes, comentários, pontos)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 24, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      likes.toString(),
                      style: AppTextStyles.inputHint,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton(
                      onPressed: () {
                        final sample = [
                          CommentItem(author: 'Gustavo', timeAgo: '7 min', text: 'Lorem ipsum dolor sit amet.'),
                          CommentItem(author: 'Você', timeAgo: '7 min', text: 'Lorem ipsum dolor sit amet.', canDelete: true),
                        ];
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CommentsModal(title: 'Comentários', comments: sample),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 24, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      comments.toString(),
                      style: AppTextStyles.inputHint,
                    ),
                    const Spacer(),
                    Text(
                      '$points pnts',
                      style: AppTextStyles.inputHint,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm), 
              */
              // Título e descrição lado a lado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        description,
                        style: AppTextStyles.inputHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Tempo separado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  timeAgo,
                  style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        // Linha divisória
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Container(
            height: 1,
            width: double.infinity,
            color: AppColors.border,
            margin: const EdgeInsets.only(top: AppSpacing.xs),
          ),
        ),
      ],
    );
  }
}



