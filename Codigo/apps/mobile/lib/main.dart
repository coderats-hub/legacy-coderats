import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/theme/app.theme.dart';
import 'features/user/presentation/screens/home.screen.dart';
import 'features/user/presentation/screens/code_exchange.screen.dart';
import 'features/user/presentation/screens/onboarding.screen.dart';
import 'features/group/presentation/screens/group.join.screen.dart';
import 'features/group/presentation/screens/group.create.screen.dart';
import 'features/group/presentation/screens/group.list.screen.dart';
import 'features/group/presentation/screens/group.details.screen.dart';
import 'features/group/presentation/screens/group.ranking.screen.dart';
import 'features/profile/presentation/screens/private.profile.screen.dart';
import 'features/feed/presentation/screens/feed.list.screen.dart';

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
        '/feed': (_) => const FeedListScreen(),
        '/join-group': (_) => const JoinGroupScreen(),
        '/group-ranking': (_) => GroupRankingScreen(),
        '/group-details': (_) => const GroupDetailPage(groupName: 'Nome do Grupo'),
        '/groups': (_) => const GroupListScreen(currentUserId: 'a1b2c3d4-e5f6-7890-1234-56789abcdef0'),
        '/profile': (_) => PrivateProfileScreen(),
        '/started': (_) => const CodeExchangeScreen(),
        '/onboarding': (_) => const OnboardingStartScreen(),
        '/create-group': (_) => const CreateGroupScreen(),
      },
    );
  }
}