/**
 * TELA DE PERFIL PRIVADO
 * 
 * Esta é a tela do perfil do próprio usuário logado.
 * Mostra informações pessoais e ações que o usuário pode realizar:
 * - Header com avatar, nome e botão "Ver GitHub"
 * - Botões para "Criar grupo" e "Entrar via código"
 * - Calendário de atividades (temporariamente comentado)
 * - Badges conquistadas (temporariamente comentado)
 * - Grupos em comum (temporariamente comentado)
 * 
 * Funcionalidades:
 * - Navegação para criar grupo
 * - Navegação para entrar em grupo via código
 * - Bottom navigation para outras telas
 * - Link para GitHub pessoal
 */

import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:app/shared/components/profile_components.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/features/group/presentation/screens/group.create.screen.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';

// Tela de perfil do usuário logado (perfil privado/próprio)
class PrivateProfileScreen extends StatelessWidget {
  PrivateProfileScreen({super.key});

  final DateTime _currentDate = DateTime.now();
  final Map<DateTime, List<dynamic>> _markedDateMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Perfil: Alice',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(
              name: "Alice",
              actionLabel: "Ver GitHub",
              actionIcon: Icons.link,
              onAction: () {},
            ),
            const SizedBox(height: 12),
            _PrivateActions(),
            const SizedBox(height: 12),
            // TODO: Calendário temporariamente comentado
            // _CalendarCard(
            //   currentDate: _currentDate,
            //   markedDateMap: _markedDateMap,
            // ),
            // const SizedBox(height: 16),
            // TODO: Badges temporariamente comentados
            // _BadgesRow(
            //   showSeeAll: false,
            // ),
            // const SizedBox(height: 16),
            // TODO: Grupos em comum temporariamente comentados
            // _GroupsInCommon(),
          ],
        ),
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tela de Início não implementada')),
            );
          } else if (i == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GroupsPage()),
            );
          } else if (i == 2) {
            // já está na tela de perfil
          }
        },
      ),
    );
  }
}

// Widget com as ações principais do perfil privado (Criar/Entrar em grupo)
class _PrivateActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          // Botão para criar novo grupo
          Expanded(
            child: _ActionCard(
              label: "Criar grupo",
              icon: Icons.add_circle_outline,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Botão para entrar em grupo via código
          Expanded(
            child: _ActionCard(
              label: "Entrar via código",
              icon: Icons.group_add_outlined,
              onTap: () {
                Navigator.of(context).pushNamed('/join-group');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Card individual para cada ação (criar/entrar em grupo)
class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionCard({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppCorners.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              Expanded(
                child: Text(
                  label, 
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(AppSpacing.md),
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
            // header spacing handled by parent padding
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
            const Text('Badges', style: AppTextStyles.inputLabel),
            if (showSeeAll)
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos os badges'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _BadgePlaceholder(label: '2x'),
            const SizedBox(width: 12),
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
            color: warning ? AppColors.error : AppColors.surface,
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
