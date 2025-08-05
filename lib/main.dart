import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'views/bienvenida_view.dart';
import 'views/pagina_principal_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BlueDraftApp());
}

class BlueDraftApp extends StatelessWidget {
  const BlueDraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueDraft',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const BienvenidaView(),
        '/home': (context) => const PaginaPrincipalView(),
      },
    );
  }
}
