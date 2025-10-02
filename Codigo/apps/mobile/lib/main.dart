import 'dart:async'; // Importe para usar runZonedGuarded
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Removido
import 'features/checkin/presentation/screens/checkin.screen.dart';
import 'features/profile/presentation/screens/public_profile.dart';
import 'features/profile/presentation/screens/private_profile.dart';

void main() {
  // runZonedGuarded continua sendo útil para capturar erros
  runZonedGuarded<Future<void>>(() async {
    // Apenas o MyApp é executado, sem o ProviderScope
    runApp(const MyApp());
  }, (error, stack) {
    // Se houver qualquer erro durante a inicialização, ele será impresso aqui!
    print('ERRO NÃO CAPTURADO NA INICIALIZAÇÃO: $error');
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-in App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home:  PrivateProfileScreen(),
    );
  }
}

