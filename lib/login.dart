import "dart:developer";
import 'package:Lista_de_compras/sign-up_page.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginState();
}

class _loginState extends State<loginpage> {
  TextEditingController _login = TextEditingController();
  TextEditingController _senha = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: widgetTextField(),
    ));
  }

  widgetTextField() {
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
          TextField(
            cursorColor: Colors.green,
            controller: _login,
            decoration: const InputDecoration(labelText: 'Login'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            cursorColor: Colors.green,
            controller: _senha,
            decoration: const InputDecoration(
              labelText: 'Senhar',
            ),
            textInputAction: TextInputAction.done,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.green, 
            margin: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _login.text, password: _senha.text);
                } catch (e) {
                  log(e.toString());
                }
              },
              child: const Text(
                'Logar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),          
          Container(
  alignment: Alignment.centerLeft,
  child: TextButton(
    onPressed: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => sign-up_page()));
    },
    child: const Text('Não tem conta'),
  ),
),

        ],
      ),
    );
  }
}
