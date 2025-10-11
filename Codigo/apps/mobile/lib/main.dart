import 'package:app/features/group/presentation/screens/group.ranking.dart';
import 'package:app/features/user/presentation/screens/started.dart';
import 'package:app/features/group/presentation/screens/details.group.dart';
import 'package:app/features/group/presentation/screens/join.group.dart';
import 'package:app/features/group/presentation/screens/list.group.dart';
import 'package:app/features/profile/presentation/screens/private.profile.dart';
import 'package:app/features/user/presentation/screens/tela.inicio.dart';
import 'package:app/features/user/presentation/screens/login.user.dart';
import 'package:app/features/user/presentation/screens/register.user.dart';
import 'package:flutter/material.dart';
import 'shared/theme/app.theme.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Rats',
      theme: AppTheme.dark(),
  home: const TelaInicio(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/started': (_) => const OnboardingStartScreen(),
        '/join-group': (_) => const JoinGroupScreen(),
  '/group-ranking': (_) => GroupRankingScreen(),
        '/group-details': (_) => GroupDetailPage(groupName: 'Nome do Grupo'),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/groups':  (_) => const GroupsPage(),
        '/profile': (_) => PrivateProfileScreen(),
      },
    );
  }
}

