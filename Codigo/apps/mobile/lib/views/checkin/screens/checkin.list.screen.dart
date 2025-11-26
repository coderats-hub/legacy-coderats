
import 'package:app/core/session_manager.dart';
import 'package:app/database/checkin/checkin.dao.dart';
import 'package:app/domain/checkin/checkin.dart';
import 'package:app/repositories/checkin.repository.dart';
import 'package:app/services/checkin/checkin_remote_service.dart';
import 'package:app/services/connectivity_service.dart';
import 'package:app/services/http_client.dart';
import 'package:app/services/local_database.dart';
import 'package:app/views/group/screens/group.details.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checkin.details.screen.dart';
import '../widgets/shared_widgets.dart';

class CheckinScreen extends StatefulWidget {
  final String? groupId;
  const CheckinScreen({super.key, this.groupId});

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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _checkins.length,
      itemBuilder: (context, index) {
        final c = _checkins[index];
        final username = c.author.name ?? 'Desconhecido';
        final timeAgo = _formatTimeAgo(c.createdAt);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _PostCard(
            username: username,
            title: c.title,
            description: c.description ?? '',
            timeAgo: timeAgo,
            color: const Color(0xFF25A18E),
            isGradient: true,
            gradientColors: const [Color(0xFF25A18E), Color(0x3325A18E)],
            points: c.points,
            githubText: c.summaryAi ?? '',
          ),
        );
      },
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

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.username,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.color,
    required this.isGradient,
    this.gradientColors,
    required this.points,
    required this.githubText,
  });

  final String username;
  final String title;
  final String description;
  final String timeAgo;
  final Color color;
  final bool isGradient;
  final List<Color>? gradientColors;
  final int points;
  final String githubText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              Text(username, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('$points pnts', style: AppTextStyles.inputHint),
            ],
          ),
        ),
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
              color: isGradient ? null : color,
              borderRadius: BorderRadius.circular(AppCorners.md),
            ),
            child: Stack(
              children: [
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
                          Text(githubText, style: AppTextStyles.inputHint.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppCorners.sm),
                            ),
                            child: const Icon(Icons.code_outlined, color: AppColors.textPrimary, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.inputLabel.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(description, style: AppTextStyles.inputHint)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(timeAgo, style: AppTextStyles.inputHint.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
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
