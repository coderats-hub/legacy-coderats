import 'package:flutter/material.dart';
import 'package:app/shared/theme/app_theme.dart';

class TaskDescriptionModal extends StatefulWidget {
  final BuildContext parentContext;
  final String title;
  final String description;

  const TaskDescriptionModal({
    super.key,
    required this.parentContext,
    this.title = 'Descrição Tarefa',
    this.description =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet.',
  });

  @override
  State<TaskDescriptionModal> createState() => _TaskDescriptionModalState();
}

class _TaskDescriptionModalState extends State<TaskDescriptionModal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                child: Text(
                  'descrição IA',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppCorners.xl),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.title.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          widget.description,
                          style: AppTextStyles.inputHint.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Integração com GitHub será implementada.'),
                                ),
                              );
                            },
                            icon: Image.asset(
                              'assets/icons/github.png',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            label: const Text('Ver atividade no GitHub', style: AppTextStyles.button),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 8,
                      top: -10,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
                        onPressed: () async {
                          try {
                            await _ctrl.reverse();
                          } catch (_) {}
                          if (mounted) Navigator.of(context).maybePop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
