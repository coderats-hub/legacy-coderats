/**
 * COMPONENTE DE FOTO DE PERFIL CLICÁVEL
 * 
 * Widget reutilizável para exibir fotos de perfil que navega para o perfil do usuário ao ser clicada.
 * Usado em toda a aplicação onde fotos de perfil são exibidas.
 * 
 * Características:
 * - Avatar circular clicável
 * - Navega para perfil público do usuário
 * - Tamanho configurável
 * - Fallback para inicial do nome quando não há imagem
 * - Suporte para usuário atual (navega para perfil privado)
 */

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../core/session_manager.dart';
import '../../views/profile/screens/public.profile.screen.dart';

class ClickableProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final String? userName;
  final String userId;
  final double radius;
  final bool enabled;

  const ClickableProfilePicture({
    super.key,
    required this.userId,
    this.imageUrl,
    this.userName,
    this.radius = 18,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _navigateToProfile(context) : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
          backgroundColor: AppColors.surface,
          child: imageUrl == null || imageUrl!.isEmpty
              ? Text(
                  _getInitial(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.7,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _getInitial() {
    if (userName != null && userName!.isNotEmpty) {
      return userName![0].toUpperCase();
    }
    return '?';
  }

  void _navigateToProfile(BuildContext context) {
    final currentUserId = SessionManager.instance.currentUserId;
    
    // Se é o próprio usuário, navega para o perfil privado
    if (currentUserId == userId) {
      Navigator.of(context).pushNamed('/profile');
    } else {
      // Se é outro usuário, navega para o perfil público
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PublicProfileScreen(
            userId: userId,
            userName: userName,
            userImage: imageUrl,
            githubUser: null, // TODO: Adicionar githubUser como parâmetro quando disponível
          ),
        ),
      );
    }
  }
}
