import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:app/features/group/presentation/screens/group.create.screen.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';

class PrivateProfileScreen extends StatelessWidget {
  PrivateProfileScreen({super.key});

  final DateTime _currentDate = DateTime.now();
  // final EventList<Event> _markedDateMap = EventList<Event>(events: {});
  final Map<DateTime, List<dynamic>> _markedDateMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: AppColors.background,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Perfil: Alice',
                  style: AppTextStyles.title,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              name: "Alice",
              actionLabel: "Adicionar GitHub",
              actionIcon: Icons.link,
              onAction: () {},
            ),
            const SizedBox(height: 12),
            _PrivateActions(),
            const SizedBox(height: 12),
            _CalendarCard(
              currentDate: _currentDate,
              markedDateMap: _markedDateMap,
            ),
            const SizedBox(height: 16),
            _BadgesRow(
              showSeeAll: false,
            ),
            const SizedBox(height: 16),
            _GroupsInCommon(),
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

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _ProfileHeader({
    required this.name,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.person, color: Colors.white, size: 48)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChipButton(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
          color: AppColors.primary, // verde padrão do app
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  const _ChipButton({required this.label, required this.icon, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppCorners.lg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppCorners.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivateActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              label: "Criar um grupo",
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

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionCard({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppCorners.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label, 
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600,
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
      child: CalendarCarousel<Event>(
        thisMonthDayBorderColor: Colors.transparent,
        daysHaveCircularBorder: true,
  weekendTextStyle: AppTextStyles.inputHint.copyWith(color: Colors.white70),
  weekdayTextStyle: AppTextStyles.inputHint.copyWith(color: Colors.white54),
  daysTextStyle: AppTextStyles.inputLabel.copyWith(color: Colors.white),
  selectedDayTextStyle: AppTextStyles.inputLabel.copyWith(color: Colors.white),
  selectedDayButtonColor: AppColors.primary,
  todayButtonColor: Colors.transparent,
  todayBorderColor: AppColors.primary,
        selectedDateTime: currentDate,
        showOnlyCurrentMonthDate: true,
        headerTextStyle: AppTextStyles.title.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        iconColor: Colors.white70,
        weekFormat: false,
        height: 360,
        isScrollable: false,
        headerMargin: const EdgeInsets.only(bottom: AppSpacing.xs),
        markedDatesMap: markedDateMap,
        onDayPressed: (date, events) {},
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
