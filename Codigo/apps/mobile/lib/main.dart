import 'package:flutter/material.dart';
import 'features/user/presentation/screen/login.user.dart';
import 'shared/theme/app.theme.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

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
