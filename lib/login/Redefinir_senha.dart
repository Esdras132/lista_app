import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Redefinir_Senha extends StatefulWidget {
  const Redefinir_Senha({super.key});

  @override
  State<Redefinir_Senha> createState() => _Redefinir_SenhaState();
}

class _Redefinir_SenhaState extends State<Redefinir_Senha> {
  TextEditingController _recuperar_senha = TextEditingController();
   bool passToggle = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(alignment: Alignment.center, child: recuperarSenha()),
    );
  }

  recuperarSenha() {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/logo_lista.png",
            width: 100,
            alignment: Alignment.center,
          ),
          TextField(
            autofocus: true,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
                labelText: 'Email',
                suffix: Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(
                    Icons.email,
                    color: Colors.green,
                  ),
                )),
            controller: _recuperar_senha,
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.green,
              margin: const EdgeInsets.all(16.0),
              child: TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _recuperar_senha.text);
                       const Center(
                child: CircularProgressIndicator(
              color: Colors.green,
              backgroundColor: Colors.grey,
            ));

                    } catch (e) {
                      log(e.toString());
                    }
                  },
                  child: const Text(
                    'Enviar email',
                    style: TextStyle(color: Colors.white),
                  )))
        ]));
  }
}
