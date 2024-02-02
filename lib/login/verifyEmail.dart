import 'dart:async';

import 'package:Lista_de_compras/lista-compras.dart';
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

      Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerify());
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
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
      ? ListaComprasPage()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Verificaçao Email'),
          ),
          body: Container(
            alignment: Alignment.topCenter,
            child: veryficacaocorpo(),
          ));

  veryficacaocorpo() {
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
              
              Text('Verifique seu email', style: TextStyle(fontSize: 30),)
              ]));

  }
}
