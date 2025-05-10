
import 'dart:developer';

import 'package:lista_de_compras/firebase_options.dart';
import 'package:lista_de_compras/view/login/verifyEmail.dart';
import 'package:lista_de_compras/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/view/home/home.dart';

late final FirebaseAuth auth;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
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
              /* print(snapshot.data!.uid); */
              return const VerifyEmail();
            }
            return const Intro();
            /* return const loginpage(); */
          },
        ));
  }
}
