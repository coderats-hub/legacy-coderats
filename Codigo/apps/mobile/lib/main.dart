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

import 'package:app/core/session_manager.dart';
import 'package:app/views/group/screens/group.details.screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SessionManager.instance.loadFromStorage();
  
  runApp(const App()); 
}

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
        '/join-group': (_) => const JoinGroupScreen(),
        '/group-ranking': (_) => GroupRankingScreen(),
        '/groups': (_) => const GroupListScreen(),
        '/profile': (_) => PrivateProfileScreen(),
        '/started': (_) => const CodeExchangeScreen(),
        '/onboarding': (_) => const OnboardingStartScreen(),
        '/create-group': (_) => const CreateGroupScreen(),
        '/group-details': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          if (args == null || args['groupId'] == null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Erro")),
              body: const Center(child: Text("ID do grupo não fornecido")),
            );
          }
          return GroupDetailPage(
            groupId: args['groupId'], 
            groupNamePreview: args['groupNamePreview'],
            imageUrlPreview: args['imageUrlPreview'],  
          );
        },
      },
    );
  }
}