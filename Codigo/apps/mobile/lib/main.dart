import 'package:app/features/group/presentation/screens/list.group.dart';
import 'package:app/features/profile/presentation/screens/private.profile.dart';
import 'package:app/features/user/presentation/screens/started.dart';
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
      home: const OnboardingStartScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/groups':  (_) => const GroupsPage(),
        '/profile': (_) => PrivateProfileScreen(),
      },
    );
  }
}

