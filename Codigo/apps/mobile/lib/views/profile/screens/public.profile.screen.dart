/**
 * TELA DE PERFIL PÚBLICO
 * 
 * Exibe o perfil de outros usuários (não o próprio usuário logado).
 * Mostra informações públicas de membros do grupo.
 * 
 * Onde é usada:
 * - Navegação de GroupDetailPage (ao tocar em um membro)
 * - Navegação de listas de usuários/rankings
 * - Visualização de perfis de outros membros
 * 
 * Funcionalidades:
 * - Header com avatar, nome e botão "Ver GitHub"
 * - Calendário de atividades públicas (temporariamente comentado)
 * - Badges/conquistas visíveis (temporariamente comentado)
 * - Grupos em comum (temporariamente comentado)
 * - Layout responsivo com scroll
 * 
 * Diferenças do perfil privado:
 * - Não tem botões de ação (criar/entrar em grupo)
 * - Não tem bottom navigation
 * - Mostra apenas informações públicas
 * - Foco em visualização, não em ações
 */

import 'package:coderats/views/profile/widgets/profile_components.dart';
import 'package:coderats/views/checkin/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:coderats/shared/theme/app_theme.dart';
import 'package:coderats/shared/components/components.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:table_calendar/table_calendar.dart';

// Tela de perfil público de outros usuários (não o próprio)
class PublicProfileScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userImage;
  final String? githubUser;

  const PublicProfileScreen({
    super.key,
    this.userId,
    this.userName,
    this.userImage,
    this.githubUser,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final DateTime _currentDate = DateTime.now();            // Data atual para calendário
  final Map<DateTime, List<dynamic>> _markedDateMap = {};  // Mapa de datas com atividades
  bool _isLoading = false;
  Object? _error;

  Future<void> _openGitHubProfile(String githubUsername) async {
    final url = 'https://github.com/$githubUsername';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o perfil do GitHub')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir o perfil do GitHub')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exibe erro formatado se houver
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: 'Perfil',
        ),
        body: _buildErrorView(),
        bottomNavigationBar: AppNavbar(
          currentIndex: 2,
          onTap: (i) {
            if (i == 0) Navigator.of(context).pushNamed('/feed');
            else if (i == 1) Navigator.of(context).pushNamed('/groups');
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Perfil',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header padrão do perfil (avatar + nome + ação)
            ProfileHeader(
              name: widget.userName ?? "Usuário",           // Nome do usuário passado como parâmetro
              actionLabel: "Ver GitHub", // Ação para visualizar GitHub
              actionIcon: Icons.link,
              imageUrl: widget.userImage, // Imagem do usuário passada como parâmetro
              onAction: () async {
                if (widget.githubUser != null) {
                  await _openGitHubProfile(widget.githubUser!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('GitHub não está conectado!')),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            // TODO: Calendário temporariamente comentado
            // _CalendarCard(currentDate: _currentDate, markedDateMap: _markedDateMap),
            // const SizedBox(height: 16),
            // TODO: Badges temporariamente comentados
            // _BadgesRow(showSeeAll: true),
            // const SizedBox(height: 16),
            // TODO: Grupos em comum temporariamente comentados
            // _GroupsInCommon(),
          ],
        ),
      ),
      // Barra de navegação inferior
      bottomNavigationBar: AppNavbar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushNamed('/feed');
          } else if (i == 1) {
            Navigator.of(context).pushNamed('/groups');
          }
          // i == 2 é perfil, já está nessa tela
        },
      ),
    );
  }

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
              'Erro ao carregar perfil',
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
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                // TODO: Adicionar lógica de reload
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime currentDate;
  final Map<DateTime, List<dynamic>> markedDateMap;
  const _CalendarCard({required this.currentDate, required this.markedDateMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCorners.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SizedBox(
        height: 360,
        child: TableCalendar<dynamic>(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: currentDate,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleTextStyle: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white70),
            rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white70),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: AppTextStyles.inputLabel.copyWith(color: Colors.white),
            weekendTextStyle: AppTextStyles.inputHint.copyWith(color: Colors.white70),
            selectedTextStyle: AppTextStyles.inputLabel.copyWith(color: Colors.white),
            todayTextStyle: AppTextStyles.inputLabel.copyWith(color: Colors.white),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.inputHint.copyWith(color: Colors.white54),
            weekendStyle: AppTextStyles.inputHint.copyWith(color: Colors.white70),
          ),
          selectedDayPredicate: (day) => isSameDay(day, currentDate),
          eventLoader: (day) {
            final events = <dynamic>[];
            for (final entry in markedDateMap.entries) {
              if (isSameDay(entry.key, day)) {
                events.addAll(entry.value);
              }
            }
            return events;
          },
          onDaySelected: (selectedDay, focusedDay) {},
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final bool showSeeAll;
  const _BadgesRow({this.showSeeAll = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Badges', style: AppTextStyles.title),
            if (showSeeAll)
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos os badges'),
              ),
          ],
        ),
  const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _BadgePlaceholder(label: '2x'),
            const SizedBox(width: AppSpacing.sm),
            _BadgePlaceholder(label: '1x', warning: true),
          ],
        ),
      ],
    );
  }
}

class _BadgePlaceholder extends StatelessWidget {
  final String label;
  final bool warning;
  const _BadgePlaceholder({required this.label, this.warning = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: warning ? AppColors.error : Colors.white10,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events, color: Colors.white),
        ),
  const SizedBox(width: AppSpacing.xs),
  Text(label, style: AppTextStyles.inputLabel.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _GroupsInCommon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
  const SizedBox(height: AppSpacing.sm),
  Text('Grupos em Comum', style: AppTextStyles.title.copyWith(color: Colors.white)),
  const SizedBox(height: AppSpacing.sm),
  Text('— em breve —', style: AppTextStyles.inputHint.copyWith(color: Colors.white54)),
      ],
    );
  }
}
