import 'package:app/features/group/presentation/screens/groups.screen.dart';
import 'package:flutter/material.dart';
import 'features/user/presentation/screen/login.user.dart';
import 'features/user/presentation/screen/cadastro.user.dart';
import 'shared/theme/app.theme.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Rats',
      theme: AppTheme.dark(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

