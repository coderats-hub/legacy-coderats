
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class PublicProfileScreen extends StatelessWidget {
  PublicProfileScreen({super.key});

  final DateTime _currentDate = DateTime.now();
  final EventList<Event> _markedDateMap = EventList<Event>(events: {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Perfil: Alice',
        // Não exibe botão de voltar
        onBack: null,
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(
              name: "Alice",
              actionLabel: "Ver GitHub",
              actionIcon: Icons.link,
              onAction: () {},
            ),
            const SizedBox(height: 12),
            _CalendarCard(currentDate: _currentDate, markedDateMap: _markedDateMap),
            const SizedBox(height: 16),
            _BadgesRow(showSeeAll: true),
            const SizedBox(height: 16),
            _GroupsInCommon(),
          ],
        ),
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
          decoration: const BoxDecoration(
                color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.person, color: Colors.white, size: 48)),
        ),
  const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          style: AppTextStyles.title.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        _ChipButton(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
          color: AppColors.primary,
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
  borderRadius: BorderRadius.circular(AppCorners.xl),
      child: InkWell(
        onTap: onPressed,
  borderRadius: BorderRadius.circular(AppCorners.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
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

class _CalendarCard extends StatelessWidget {
  final DateTime currentDate;
  final EventList<Event> markedDateMap;
  const _CalendarCard({required this.currentDate, required this.markedDateMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCorners.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
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
        headerMargin: const EdgeInsets.only(bottom: 8),
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
