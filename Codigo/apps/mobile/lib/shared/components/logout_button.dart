import 'package:app/core/session_manager.dart';
import 'package:app/views/user/screens/home.screen.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Deseja sair?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Você precisará fazer login novamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

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
