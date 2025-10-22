import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/features/group/presentation/screens/create.group.dart';
import 'package:app/features/group/presentation/screens/list.group.dart';

class PrivateProfileScreen extends StatelessWidget {
  PrivateProfileScreen({super.key});

  final DateTime _currentDate = DateTime.now();
  // final EventList<Event> _markedDateMap = EventList<Event>(events: {});
  final Map<DateTime, List<dynamic>> _markedDateMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const GroupsPage(),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text('Alice'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1, // esta é a página de Grupos
          onTap: (i) {
            const routeByIndex = ['/home', '/groups', '/profile'];
            final current = ModalRoute.of(context)?.settings.name;
            final target = routeByIndex[i];

            if (current != target) {
              Navigator.of(context).pushReplacementNamed(target);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_2_outlined), label: 'Grupos'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
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

class _PrivateActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: "Criar um grupo",
            icon: Icons.group_add,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            label: "Entrar via código",
            icon: Icons.code,
            onTap: () {},
          ),
        ),
      ],
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
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: currentDate,
        eventLoader: (date) {
          return markedDateMap[date] ?? [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          defaultDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          weekendDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          holidayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white70),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white70),
          titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          // Handle day selection
        },
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
        Text('Grupos em Comum', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('— em breve —', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
