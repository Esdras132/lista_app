import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:lista_de_compras/main.dart'; // Para acessar a variável 'auth'
import 'package:lista_de_compras/intro.dart';
import 'package:lista_de_compras/view/home/home.dart';
import 'package:lista_de_compras/view/login/verifyEmail.dart';

// ignore: must_be_immutable
class AuthGate extends StatelessWidget {
  AuthGate({super.key});
  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  @override
  Widget build(BuildContext context) {
    Future<void> verify() async {
      sharedPreferencesController.get(context, 'user_id').then((value) async {
        if (value == null) {
          final storage = FlutterSecureStorage();
          await storage.deleteAll();

          await FirebaseAuth.instance.signOut();
          // ignore: use_build_context_synchronously
          sharedPreferencesController.set(context, 'user_id', '1');
        }
        if(value == '1'){
          log('Usuário autenticado');
        }

      });
    }

    // Este StreamBuilder "ouve" as mudanças no estado de autenticação do usuário
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        verify();
        // Se não houver dados de usuário (ninguém logado)
        if (snapshot.data == null) {
          return const Intro(); // Mostra a tela de introdução/login
        }

        // Se o usuário está logado mas não verificou o email
        if (!snapshot.data!.emailVerified) {
          return const VerifyEmail(); // Mostra a tela de verificação de email
        }

        if (snapshot.hasData) {
          // Se o usuário está logado e com email verificado
          verify();
          return const ListaComprasPage(); // Mostra a tela principal do app
        }

        return const CircularProgressIndicator(); // Indicador de carregamento padrão
      },
    );
  }
}
