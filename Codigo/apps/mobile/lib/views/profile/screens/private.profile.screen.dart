import 'package:app/domain/user/user.model.dart';
import 'package:app/domain/badge/badge.model.dart' as badge_model;
import 'package:app/services/user/user.service.dart';
import 'package:app/services/badge/badge.service.dart';
import 'package:app/views/checkin/widgets/shared_widgets.dart';
import 'package:app/views/group/screens/group.create.screen.dart';
import 'package:app/views/group/screens/group.join.screen.dart';
import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/shared/components/components.dart';
import 'package:app/shared/utils/string_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/views/checkin/screens/checkin.list.screen.dart';
import 'package:app/core/session_manager.dart';

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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppHeader(
          title: 'Perfil',
          showBackButton: false,
          actions: [LogoutButton()],
        ),
        body: const AppLoading(),
        bottomNavigationBar: AppNavbar(
          currentIndex: 2,
          onTap: (i) => _onNavbarTap(context, i),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Perfil',
        showBackButton: false,
        actions: [LogoutButton()],
      ),
      body: _error != null
          ? _buildErrorView()
          : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(
                        user: _currentUser,
                        onAction: () async {
                          if (_currentUser?.githubUser != null) {
                            await _openGitHubProfile(_currentUser!.githubUser!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('GitHub não está conectado!')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _PrivateActions(),
                      const SizedBox(height: 12),
                      _MyCheckinsButton(),
                      const SizedBox(height: 16),
                      _BadgesSection(),
                      // const SizedBox(height: 12),
                      // _CalendarCard(
                      //   currentDate: _currentDate,
                      //   markedDateMap: _markedDateMap,
                      // ),
                      // const SizedBox(height: 16),
                      // _GroupsInCommon(),
                    ],
                  ),
                ),
      bottomNavigationBar: AppNavbar(
        currentIndex: 2,
        onTap: (i) => _onNavbarTap(context, i),
      ),
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    if (index == 2) return; // Já está no perfil
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/feed');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/groups');
    }
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
                _loadUserData();
              },
            ),
          ],
        ),
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
                      return const AppLoading(size: 48, strokeWidth: 2);
                    },
                  )
                : const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 48),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          user?.name != null ? StringUtils.truncateName(user!.name) : 'Usuário',
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinGroupScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onNavbarTap(BuildContext context, int index) {
    if (index == 2) return; // Já está no perfil
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/feed');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/groups');
    }
  }
}

class _MyCheckinsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppCorners.md)),
      ),
      icon: const Icon(Icons.list_alt, color: Colors.white),
      label: const Text('Listar meus check-ins'),
      onPressed: () {
        final userId = SessionManager.instance.currentUserId;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CheckinScreen(
              onlyMine: true,
              userId: userId,
              titleOverride: 'Meus check-ins',
            ),
          ),
        );
      },
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

// Seção de Badges com informações detalhadas
class _BadgesSection extends StatefulWidget {
  @override
  State<_BadgesSection> createState() => _BadgesSectionState();
}

class _BadgesSectionState extends State<_BadgesSection> {
  final BadgeService _badgeService = BadgeService();
  List<badge_model.Badge> _badges = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserBadges();
  }

  Future<void> _loadUserBadges() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userBadges = await _badgeService.getBadgesForCurrentUser();
      final loadedBadges = userBadges
          .where((ub) => ub.badge != null)
          .map((ub) => ub.badge!.copyWith(
                obtainedAt: ub.awardedAt,
                imageAsset: _getBadgeImage(ub.badge!.id),
              ))
          .toList();

      setState(() {
        _badges = loadedBadges;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar badges: $e');
      setState(() {
        _error = e.toString();
        _badges = _getMockBadges(); // Fallback para mocks em caso de erro
        _isLoading = false;
      });
    }
  }

  String _getBadgeImage(String badgeId) {
    // Mapear IDs de badges para assets locais
    switch (badgeId) {
      case '0':
        return 'assets/images/ratoNormal (1).png';
      default:
        return 'assets/images/rats_groups.png';
    }
  }

  List<badge_model.Badge> _getMockBadges() {
    // Dados temporários para demonstração (fallback)
    return [
      badge_model.Badge(
        id: '0',
        name: 'Usuário Cadastrado',
        description: 'Faça o link com o GitHub pela primeira vez!',
        imageAsset: 'assets/images/ratoNormal (1).png',
        obtainedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCorners.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Badges Conquistados',
                style: AppTextStyles.title.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppLoading(),
              ),
            )
          else if (_badges.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Nenhum badge conquistado ainda',
                  style: AppTextStyles.inputHint.copyWith(color: Colors.white54),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _badges.map((badge) => SizedBox(
                    width: (constraints.maxWidth - 24) / 3, // 3 badges por linha
                    child: _BadgeItem(badge: badge),
                  )).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Item individual de badge com hover card profissional
class _BadgeItem extends StatefulWidget {
  final badge_model.Badge badge;

  const _BadgeItem({required this.badge});

  @override
  State<_BadgeItem> createState() => _BadgeItemState();
}

class _BadgeItemState extends State<_BadgeItem> {
  bool _isHovered = false;
  final _hoverKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    return GestureDetector(
      onTap: () {
        _showBadgeDialog(context, widget.badge, dateFormatter);
      },
      child: MouseRegion(
        key: _hoverKey,
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Badge Image
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppCorners.lg),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppCorners.lg),
                  child: Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      widget.badge.imageAsset ?? 'assets/images/rats_groups.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.emoji_events,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Hover Card - Minimalista
            if (_isHovered)
              Positioned(
                left: 0,
                right: 0,
                bottom: -65,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppCorners.sm),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.badge.name,
                          style: AppTextStyles.inputLabel.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.badge.description ?? '',
                          style: AppTextStyles.inputHint.copyWith(
                            color: Colors.white60,
                            fontSize: 10,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.badge.id != '0' && widget.badge.obtainedAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            dateFormatter.format(widget.badge.obtainedAt!),
                            style: AppTextStyles.inputHint.copyWith(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDialog(BuildContext context, badge_model.Badge badge, DateFormat formatter) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppCorners.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Conteúdo Principal
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagem do Badge
                    Container(
                      width: 160,
                      height: 160,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppCorners.lg),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppCorners.md),
                        child: Image.asset(
                          badge.imageAsset ?? 'assets/images/rats_groups.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.emoji_events,
                                color: AppColors.primary,
                                size: 80,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Nome do Badge
                    Text(
                      badge.name,
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Descrição
                    Text(
                      badge.description ?? '',
                      style: AppTextStyles.inputLabel.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Data de obtenção (não mostra para o badge de cadastro)
                    if (badge.id != '0' && badge.obtainedAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppCorners.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.white60,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Obtido em ${formatter.format(badge.obtainedAt!)}',
                              style: AppTextStyles.inputLabel.copyWith(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Botão de fechar (X)
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
