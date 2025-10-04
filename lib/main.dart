import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/firebase_options.dart';
import 'package:lista_de_compras/splash_screen.dart'; // Importe a nova tela

// Variável global para ser acessada em outros arquivos, como o auth_gate
late final FirebaseAuth auth;

Future<void> main() async {
  // Garante que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Instancia o FirebaseAuth
  auth = FirebaseAuth.instanceFor(app: app);

  // Desativa o App Check para seguran a
  await FirebaseAppCheck.instance.activate();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        ),
        useMaterial3: true,
      ),
      // A tela inicial do app agora é a tela com o vídeo
      home: const SplashScreenVideo(),
    );
  }
}