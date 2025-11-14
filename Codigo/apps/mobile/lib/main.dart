/**
 * ARQUIVO PRINCIPAL DA APLICAÇÃO CODE RATS
 * 
 * Este é o ponto de entrada da aplicação Flutter.
 * Define a configuração global do app incluindo:
 * - Tema da aplicação (escuro)
 * - Roteamento entre telas
 * - Configurações do MaterialApp
 * - Tela inicial (TelaInicio)
 * 
 * Funcionalidades:
 * - Sistema de navegação por rotas nomeadas
 * - Tema customizado Code Rats
 * - Integração com todas as features do app
 */

import 'package:app/features/group/presentation/screens/group.ranking.screen.dart';
import 'package:app/features/group/presentation/screens/group.details.screen.dart';
import 'package:app/features/group/presentation/screens/group.join.screen.dart';
import 'package:app/features/group/presentation/screens/group.list.screen.dart';
import 'package:app/features/profile/presentation/screens/private.profile.screen.dart';
import 'package:app/features/user/presentation/screens/code_exchange.screen.dart';
import 'package:app/features/user/presentation/screens/register.screen.dart';
import 'package:app/features/user/presentation/screens/home.screen.dart';
import 'package:app/features/user/presentation/screens/onboarding.screen.dart';
import 'package:app/features/group/presentation/screens/group.create.screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/theme/app.theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
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
        '/register': (_) => const RegisterScreen(),
        '/groups': (_) => const GroupsPage(),
        '/profile': (_) => PrivateProfileScreen(),
        '/started': (_) => const CodeExchangeScreen(),
        '/onboarding': (_) => const OnboardingStartScreen(),
        '/create-group': (_) => const CreateGroupScreen(),
      },
    );
  }
}