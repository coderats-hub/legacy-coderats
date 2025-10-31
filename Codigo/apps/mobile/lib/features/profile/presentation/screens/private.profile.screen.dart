import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/app_components.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/features/group/presentation/screens/group.create.screen.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';
import 'package:app/features/user/data/services/user.service.dart';
import 'package:app/features/user/domain/models/user.model.dart';

class PrivateProfileScreen extends StatefulWidget {
  PrivateProfileScreen({super.key});

  @override
  State<PrivateProfileScreen> createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends State<PrivateProfileScreen> {
  final DateTime _currentDate = DateTime.now();
  final Map<DateTime, List<dynamic>> _markedDateMap = {};
  final UserService _userService = UserService();
  
  User? _currentUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = await _userService.getCurrentUser();
      
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dados do usuário: $e';
        _isLoading = false;
      });
    }
  }

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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isLoading 
                          ? 'Perfil: Carregando...' 
                          : _currentUser != null 
                              ? 'Perfil: ${_currentUser!.name}'
                              : 'Perfil: Usuário',
                      style: AppTextStyles.title,
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: AppTextStyles.inputLabel.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(
                        user: _currentUser,
                        onAction: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('GitHub já está conectado!')),
                          );
                        },
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
  final User? user;
  final VoidCallback onAction;

  const _ProfileHeader({
    required this.user,
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
          child: ClipOval(
            child: user?.image != null && user!.image!.isNotEmpty
                ? Image.network(
                    user!.image!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.person, color: Colors.white, size: 48),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 48),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          user?.name ?? 'Usuário',
          style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (user?.githubUser != null) ...[
          const SizedBox(height: 4),
          Text(
            '@${user!.githubUser}',
            style: AppTextStyles.inputHint.copyWith(color: Colors.white70, fontSize: 14),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _ChipButton(
          label: user?.githubUser != null ? "GitHub Conectado" : "Conectar GitHub",
          icon: user?.githubUser != null ? Icons.check_circle : Icons.link,
          onPressed: onAction,
          color: user?.githubUser != null ? AppColors.primary : AppColors.surface,
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
