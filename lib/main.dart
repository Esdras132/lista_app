
import 'package:lista_de_compras/dentro_app/home/home.dart';
import 'package:lista_de_compras/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

late final FirebaseAuth auth;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp();
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
        title: 'Minha lista',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.green)),
        home: StreamBuilder<User?>(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              /* print(snapshot.data!.uid); */
              return const ListaComprasPage();
            }
            return const Intro();
            /* return const loginpage(); */
          },
        ));
  }
}
