import 'package:lista_de_compras/firebase_options.dart';
import 'package:lista_de_compras/view/login/verifyEmail.dart';
import 'package:lista_de_compras/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/view/home/home.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

late final FirebaseAuth auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase apenas uma vez
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth = FirebaseAuth.instanceFor(app: app);

  // Ativar App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('23e675ad-c211-4e2d-9ef2-e08b9fb8af7e'),
    androidProvider: AndroidProvider.playIntegrity, // Use debug só em dev
    appleProvider: AppleProvider.appAttest, // ou deviceCheck
  );

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
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              return const ListaComprasPage();
            }
            return const VerifyEmail();
          }
          return const Intro();
        },
      ),
    );
  }
}
