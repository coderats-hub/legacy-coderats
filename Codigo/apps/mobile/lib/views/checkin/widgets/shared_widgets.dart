/**
 * Widgets Compartilhados para Check-ins
 * 
 * Componentes reutilizáveis para telas de check-in:
 * - SharedTheme: Tema escuro personalizado (USADO)
 * - SharedStyledButton: Botões estilizados (USADO)
 * - SharedHeader: Header com título e botão de voltar/refresh (NÃO USADO - comentado)
 * - SharedBottomNav: Navegação inferior com 3 abas (NÃO USADO - comentado)
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/shared/theme/app_theme.dart';

/// Widget compartilhado para o header das telas - NÃO UTILIZADO
/* 
class SharedHeader extends StatelessWidget {
  const SharedHeader({
    super.key,
    required this.title,
    this.onRefresh,
    this.showRefreshButton = false,
  });

  final String title;
  final VoidCallback? onRefresh;
  final bool showRefreshButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Aumenta o espaçamento vertical para afastar o header do conteúdo
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _BackButton(color: Colors.white.withOpacity(0.92)),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.headerTitle,
          ),
          const Spacer(),
          if (showRefreshButton && onRefresh != null)
            _RefreshButton(onPressed: onRefresh!),
        ],
      ),
    );
  }
}
*/

/// Widget compartilhado para o bottom navigation - NÃO UTILIZADO
/* 
class SharedBottomNav extends StatefulWidget {
  const SharedBottomNav({super.key, this.currentIndex = 0});
  
  final int currentIndex;

  @override
  State<SharedBottomNav> createState() => _SharedBottomNavState();
}

class _SharedBottomNavState extends State<SharedBottomNav> {
  late int current;

  @override
  void initState() {
    super.initState();
    current = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
      height: 70,
      child: BottomNavigationBar(
        currentIndex: current,
        onTap: (i) => setState(() => current = i),
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF9E9E9E),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
*/

// Classe utilitária para tema compartilhado
class SharedTheme {
  static ThemeData buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFF25A18E),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF25A18E),
        secondary: Color(0xFFDA7B3A),
        surface: Color(0xFF1E1E1E),
        outline: Color(0xFF2A2A2A),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14, 
            color: Color(0xFFBDBDBD),
            fontWeight: FontWeight.w400,
          ),
          bodySmall: TextStyle(
            fontSize: 12, 
            color: Color(0xFF9E9E9E),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Widget compartilhado para botão de voltar - NÃO UTILIZADO
/* 
class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      onTap: () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: color),
      ),
    );
  }
}

}
*/

/// Widget compartilhado para botão de refresh - NÃO UTILIZADO
/* 
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.refresh,
          size: 20,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}
*/

/// Widget compartilhado para botões estilizados
class SharedStyledButton extends StatelessWidget {
  const SharedStyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });
  
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF25A18E),
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}