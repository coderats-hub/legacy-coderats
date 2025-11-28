
import 'package:app/domain/checkin/checkin.dart';
import 'package:app/repositories/checkin.repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checkin.details.screen.dart';
import '../widgets/shared_widgets.dart';

class CheckinScreen extends StatefulWidget {
  final String? groupId;
  final String? groupName;
  
  const CheckinScreen({super.key, this.groupId, this.groupName});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  bool _isLoading = true;
  Object? _error;
  List<Checkin> _checkins = [];
  final _repository = CheckinRepository();

  @override
  void initState() {
    super.initState();
    _loadCheckins();
  }

  Future<void> _loadCheckins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = widget.groupId != null
          ? await _repository.fetchGroupCheckins(widget.groupId!)
          : await _repository.fetchFeed();

      if (mounted) {
        setState(() {
          _checkins = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SharedTheme.buildDarkTheme(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: 'Check-ins: ${widget.groupName ?? 'Code Rats'}',
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
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
        floatingActionButton: AppFAB(
          onPressed: () async {
            final created = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommitCheckinScreen(
                  groupId: widget.groupId ?? dotenv.env['DEFAULT_GROUP_ID'],
                ),
              ),
            );
            if (created == true) {
              _loadCheckins();
            }
          },
          icon: Icons.add,
          tooltip: 'Novo check-in',
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoading();
    }
    
    if (_error != null) {
      return _buildErrorView();
    }
    
    if (_checkins.isEmpty) {
      return _buildEmptyView();
    }
    
    return _buildCheckinsList();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text('Erro ao carregar check-ins', style: SharedTheme.buildDarkTheme().textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Erro: $_error', style: SharedTheme.buildDarkTheme().textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SharedStyledButton(text: 'Tentar novamente', onPressed: _loadCheckins),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: const Color(0xFF2BB6A5).withOpacity(0.7)),
            const SizedBox(height: 16),
            Text('Nenhum check-in encontrado', style: SharedTheme.buildDarkTheme().textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Voc\u00ea ainda n\u00e3o possui check-ins registrados.', style: SharedTheme.buildDarkTheme().textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SharedStyledButton(
              text: 'Atualizar',
              onPressed: _loadCheckins,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinsList() {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _loadCheckins,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _checkins.length,
        itemBuilder: (context, index) {
          final checkin = _checkins[index];
          return _CheckinCard(
            checkin: checkin,
            onTap: () => _showCheckinDetails(checkin),
          );
        },
      ),
    );
  }

  void _showCheckinDetails(Checkin checkin) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CheckinDetailModal(checkin: checkin),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours} h';
    return 'Há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
  }
}

// Card moderno para cada check-in
class _CheckinCard extends StatelessWidget {
  final Checkin checkin;
  final VoidCallback onTap;

  const _CheckinCard({
    required this.checkin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasGithub = checkin.summaryAi != null && checkin.summaryAi!.isNotEmpty;
    final timeAgo = _formatTimeAgo(checkin.createdAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCorners.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppCorners.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com avatar e info do usuário
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        image: checkin.author.image != null && checkin.author.image!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(checkin.author.image!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: checkin.author.image == null || checkin.author.image!.isEmpty
                          ? Text(
                              checkin.author.name?.isNotEmpty == true 
                                  ? checkin.author.name![0].toUpperCase() 
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Info do usuário
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            checkin.author.name ?? 'Usuário Desconhecido',
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            timeAgo,
                            style: AppTextStyles.inputHint.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Points e badge GitHub
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppCorners.sm),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${checkin.points} pts',
                            style: AppTextStyles.inputLabel.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (hasGithub) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A00F4), Color(0xFF9B22FF)],
                              ),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'IA',
                                  style: AppTextStyles.inputLabel.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                
                if (checkin.image != null && checkin.image!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppCorners.md),
                    child: Image.network(
                      checkin.image!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        width: double.infinity,
                        color: AppColors.border,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ] else
                  const SizedBox(height: AppSpacing.md),
                
                // Título do check-in
                Text(
                  checkin.title,
                  style: AppTextStyles.inputLabel.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                // Descrição (limitada)
                if (checkin.description != null && checkin.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    checkin.description!,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: AppSpacing.sm),
                
                // Footer com indicador para mais detalhes
                Row(
                  children: [
                    if (hasGithub) ...[
                      Icon(
                        Icons.commit,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Com commits',
                        style: AppTextStyles.inputHint.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ] else 
                      const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays < 30) return 'Há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
    return 'Há ${(diff.inDays / 30).floor()} mês${(diff.inDays / 30).floor() > 1 ? 'es' : ''}';
  }
}

// Modal responsivo para exibir detalhes completos do check-in
class _CheckinDetailModal extends StatelessWidget {
  final Checkin checkin;

  const _CheckinDetailModal({required this.checkin});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final maxHeight = screenHeight * 0.85;
    
    final hasGithub = checkin.summaryAi != null && checkin.summaryAi!.isNotEmpty;
    final commits = _parseCommits(checkin.description ?? '');
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 500,
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(AppCorners.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        checkin.title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info do autor
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 36 : 40,
                            height: isSmallScreen ? 36 : 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              image: checkin.author.image != null && checkin.author.image!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(checkin.author.image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: checkin.author.image == null || checkin.author.image!.isEmpty
                                ? Text(
                                    checkin.author.name?.isNotEmpty == true 
                                        ? checkin.author.name![0].toUpperCase() 
                                        : '?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  checkin.author.name ?? 'Usuário Desconhecido',
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontSize: isSmallScreen ? 14 : 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _formatDate(checkin.createdAt),
                                  style: AppTextStyles.inputHint.copyWith(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                              border: Border.all(color: AppColors.primary, width: 1),
                            ),
                            child: Text(
                              '${checkin.points} pts',
                              style: AppTextStyles.inputLabel.copyWith(
                                fontSize: isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                      
                      // Descrição completa
                      if (checkin.description != null && checkin.description!.isNotEmpty) ...[
                        Text(
                          'Descrição',
                          style: AppTextStyles.inputLabel.copyWith(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppCorners.md),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _cleanDescription(checkin.description!),
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Resumo IA (se disponível)
                      if (hasGithub) ...[
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? AppSpacing.xs : AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6A00F4), Color(0xFF9B22FF)],
                                ),
                                borderRadius: BorderRadius.circular(AppCorners.sm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Resumo IA',
                                    style: AppTextStyles.inputLabel.copyWith(
                                      fontSize: isSmallScreen ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppCorners.md),
                            border: Border.all(
                              color: const Color(0xFF6A00F4).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            checkin.summaryAi!,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Lista de commits (se disponível)
                      if (commits.isNotEmpty) ...[
                        Text(
                          'Commits (${commits.length})',
                          style: AppTextStyles.inputLabel.copyWith(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...commits.asMap().entries.map((entry) {
                          final index = entry.key;
                          final commit = entry.value;
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: index < commits.length - 1
                                  ? (isSmallScreen ? AppSpacing.xs : AppSpacing.sm)
                                  : 0,
                            ),
                            padding: EdgeInsets.all(isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: isSmallScreen ? 4 : 6,
                                  height: isSmallScreen ? 4 : 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    commit,
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return 'Há ${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'mês' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'Há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inHours > 0) {
      return 'Há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Agora mesmo';
    }
  }
  
  String _cleanDescription(String description) {
    final parts = description.split('\n\nCommits selecionados:');
    if (parts.isEmpty) return description;
    return parts[0].trim().isEmpty ? description : parts[0].trim();
  }
  
  List<String> _parseCommits(String description) {
    if (!description.contains('Commits selecionados:')) return [];
    
    final parts = description.split('Commits selecionados:');
    if (parts.length < 2) return [];
    
    final commitSection = parts[1].trim();
    return commitSection
        .split('\n')
        .where((line) => line.trim().startsWith('-'))
        .map((line) => line.trim().substring(1).trim())
        .toList();
  }
}
