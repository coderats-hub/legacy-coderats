import 'package:app/core/session_manager.dart';
import 'package:app/views/user/screens/home.screen.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionManager.instance.clearSession();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaInicio()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sair',
      icon: const Icon(Icons.logout, color: AppColors.textPrimary),
      onPressed: () => _logout(context),
    );
  }
}
