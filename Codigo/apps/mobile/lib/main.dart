import 'package:coderats/core/session_manager.dart';
import 'package:coderats/domain/group/group_participant.dart';
import 'package:coderats/views/feed/presentation/screens/feed.list.screen.dart';
import 'package:coderats/views/group/screens/group.create.screen.dart';
import 'package:coderats/views/group/screens/group.details.screen.dart';
import 'package:coderats/views/group/screens/group.join.screen.dart';
import 'package:coderats/views/group/screens/group.list.screen.dart';
import 'package:coderats/views/group/screens/group.ranking.screen.dart';
import 'package:coderats/views/profile/screens/private.profile.screen.dart';
import 'package:coderats/views/user/screens/code_exchange.screen.dart';
import 'package:coderats/views/user/screens/home.screen.dart';
import 'package:coderats/views/user/screens/onboarding.screen.dart';
import 'package:coderats/shared/ads/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'shared/theme/app.theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (AdHelper.isMobileSupported) {
    await MobileAds.instance.initialize();
  }
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
        '/feed': (_) => const FeedListScreen(),
        '/join-group': (_) => const JoinGroupScreen(),
        '/group-ranking': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as List<GroupParticipant>;
          return GroupRankingScreen(participants: args);
        },
        '/groups': (_) => const GroupListScreen(),
        '/profile': (_) => PrivateProfileScreen(),
        '/started': (_) => const CodeExchangeScreen(),
        '/onboarding': (_) => const OnboardingStartScreen(),
        '/create-group': (_) => const CreateGroupScreen(),
        '/group-details': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

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
