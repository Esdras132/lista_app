import 'dart:async';
import 'package:Lista_de_compras/dentro_app/lista-compras.dart';
import 'package:Lista_de_compras/login/sign-up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class verifyEmail extends StatefulWidget {
  const verifyEmail({super.key});

  @override
  State<verifyEmail> createState() => _verifyEmailState();
}

class _verifyEmailState extends State<verifyEmail> {
  bool isEmailverify = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailverify = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailverify) {
      sendVerifycationEmail();

      Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerify());
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future checkEmailVerify() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailverify = FirebaseAuth.instance.currentUser!.emailVerified;
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
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) => isEmailverify
      ? const ListaComprasPage()
      : Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      alignment: Alignment.centerLeft,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ));
                      },
                      icon: const Icon(Icons.arrow_back))),
            ],
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: const Text(
              'Verificaçao Email',
              textAlign: TextAlign.center,
            ),
          ),
          body: Container(
            alignment: Alignment.topCenter,
            child: veryficacaocorpo(),
          ));

  veryficacaocorpo() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/logo_lista.png",
            width: 100,
            alignment: Alignment.center,
          ),
          const Text(
            'Verifique seu E-mail',
            style: TextStyle(fontSize: 30),
          ),
          TextButton(
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                } catch (e) {
                  e.toString();
                }
              },
              child: const Text('Enviar novamente'))
        ]));
  }
}
