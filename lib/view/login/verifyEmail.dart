import 'dart:async';
import 'dart:developer';
import 'package:lista_de_compras/view/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/main.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailverify = false;
  Timer? timer;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      isEmailverify = user.emailVerified;

      if (!isEmailverify) {
        sendVerifycationEmail();
        timer = Timer.periodic(
          const Duration(seconds: 2),
          (_) => checkEmailVerify(),
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerify() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    setState(() {
      isEmailverify = user.emailVerified;
    });

    if (isEmailverify) {
      timer?.cancel();
    }
  }

  Future sendVerifycationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Se o usuário for nulo, exibir tela de login
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Erro: Usuário não autenticado')),
      );
    }
    user.reload();
    if (user.emailVerified) {
      return const ListaComprasPage();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Verificação de E-mail'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: veryficacaocorpo(),
      ),
    );
  }

  Widget veryficacaocorpo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/logo_lista.png",
            width: 100,
            alignment: Alignment.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Verifique seu E-mail',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enviamos um e-mail de verificação. Por favor, verifique sua caixa de entrada e clique no link de confirmação.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Cor principal do app
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              } catch (e) {
                /* _showAlert('Erro ao reenviar e-mail de verificação'); */
              }
            },
            child: const Text(
              'Reenviar E-mail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red, // Cor vermelha para cancelar
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
