import 'package:app/features/group/presentation/screens/groups.screen.dart';
import 'package:flutter/material.dart';
import 'shared/theme/app.theme.dart';   // seu tema escuro (já criado)

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groups Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),          
      home: const GroupsPage(),
    );
  }
}
