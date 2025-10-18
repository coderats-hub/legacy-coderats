import 'package:app/features/group/presentation/screens/group.ranking.screen.dart';
import 'package:app/features/group/presentation/screens/group.details.screen.dart';
import 'package:app/features/group/presentation/screens/group.join.screen.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';

import 'package:app/features/profile/presentation/screens/private.profile.screen.dart';

import 'package:app/features/user/presentation/screens/home.screen.dart';
import 'package:app/features/user/presentation/screens/login.screen.dart';
import 'package:app/features/user/presentation/screens/onboarding.screen.dart';
import 'package:app/features/user/presentation/screens/register.screen.dart';

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

