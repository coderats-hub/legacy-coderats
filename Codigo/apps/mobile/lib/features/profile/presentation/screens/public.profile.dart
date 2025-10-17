import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/features/profile/presentation/widgets/profile_shared_widgets.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 10, 10): ['Evento público'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B1FA2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Perfil: Alice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProfileHeader(
              name: "Alice",
              actionLabel: "Ver GitHub",
              actionIcon: Icons.link,
              onAction: null,
            ),
            const SizedBox(height: 12),
            CalendarCard(
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: _getEventsForDay,
            ),
            const SizedBox(height: 16),
            const BadgesRow(showSeeAll: true),
            const SizedBox(height: 16),
            const GroupsInCommon(),
          ],
        ),
      ),
    );
  }
}
