import 'package:app/core/session_manager.dart';
import 'package:app/views/group/screens/group.ranking.screen.dart';
import 'package:app/views/group/screens/group.details.screen.dart';
import 'package:app/views/group/screens/group.join.screen.dart';
import 'package:app/views/group/screens/group.list.screen.dart';
import 'package:app/views/profile/screens/private.profile.screen.dart';
import 'package:app/views/user/screens/code_exchange.screen.dart';
import 'package:app/views/user/screens/home.screen.dart';
import 'package:app/views/user/screens/onboarding.screen.dart';
import 'package:app/views/group/screens/group.create.screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/theme/app.theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SessionManager.instance.loadFromStorage();
  
  runApp(const App()); 
}

// Widget raiz da aplicação - configura MaterialApp e roteamento
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Configurações básicas do app
      title: 'Code Rats',
      theme: AppTheme.dark(), // Tema escuro personalizado
      home: const TelaInicio(), // Tela inicial (splash/welcome)
      debugShowCheckedModeBanner: false, // Remove banner de debug
      
      // Sistema de rotas nomeadas para navegação
      routes: {
        '/join-group': (_) => const JoinGroupScreen(),
        '/group-ranking': (_) => GroupRankingScreen(),
        '/group-details': (_) => GroupDetailPage(groupName: 'Nome do Grupo'),
        '/groups': (_) => const GroupListScreen(),
        '/profile': (_) => PrivateProfileScreen(),
        '/started': (_) => const CodeExchangeScreen(),
        '/onboarding': (_) => const OnboardingStartScreen(),
        '/create-group': (_) => const CreateGroupScreen(),
      },
    );
  }
}