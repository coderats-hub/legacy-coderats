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

import 'package:app/views/profile/widgets/profile_components.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:table_calendar/table_calendar.dart';

// Tela de perfil público de outros usuários (não o próprio)
class PublicProfileScreen extends StatelessWidget {
  PublicProfileScreen({super.key});

  final DateTime _currentDate = DateTime.now();            // Data atual para calendário
  final Map<DateTime, List<dynamic>> _markedDateMap = {};  // Mapa de datas com atividades

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Perfil: Alice', // TODO: Nome dinâmico baseado no usuário
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header padrão do perfil (avatar + nome + ação)
            ProfileHeader(
              name: "Alice",           // TODO: Nome dinâmico do usuário
              actionLabel: "Ver GitHub", // Ação para visualizar GitHub
              actionIcon: Icons.link,
              onAction: () {          // TODO: Implementar abertura do GitHub
                // Abrir perfil GitHub do usuário
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
