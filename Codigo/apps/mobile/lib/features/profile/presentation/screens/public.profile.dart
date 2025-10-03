
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class PublicProfileScreen extends StatelessWidget {
  PublicProfileScreen({super.key});

  final DateTime _currentDate = DateTime.now();
  final EventList<Event> _markedDateMap = EventList<Event>(events: {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B1FA2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Perfil: Alice'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            color: Color(0xFF7B1FA2),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.person, color: Colors.white, size: 48)),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 6),
        _ChipButton(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
          color: const Color(0xFF2E7D32),
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: CalendarCarousel<Event>(
        thisMonthDayBorderColor: Colors.transparent,
        daysHaveCircularBorder: true,
        weekendTextStyle: const TextStyle(color: Colors.white70),
        weekdayTextStyle: const TextStyle(color: Colors.white54),
        daysTextStyle: const TextStyle(color: Colors.white),
        selectedDayTextStyle: const TextStyle(color: Colors.white),
        selectedDayButtonColor: const Color(0xFF2E7D32),
        todayButtonColor: Colors.transparent,
        todayBorderColor: const Color(0xFF2E7D32),
        selectedDateTime: currentDate,
        showOnlyCurrentMonthDate: true,
        headerTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
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
            const Text('Badges', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            color: warning ? Colors.red : Colors.white10,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
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
        SizedBox(height: 8),
        Text('Grupos em Comum', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('— em breve —', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
