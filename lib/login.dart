import "dart:developer";
import 'package:Lista_de_compras/sign-up_page.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginState();
}

class _loginState extends State<loginpage> {
  TextEditingController _login = TextEditingController();
  TextEditingController _senha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo_lista.png",
              width: 100,
              alignment: Alignment.center,
            ),
            TextFormField(
              cursorColor: Colors.green,
              controller: _login,
              validator: (String? value){
                if (!value!.contains('@gmail.com') && !value.contains('@outlook.com')){
                  return 'E-mail inválido!';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Login'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              cursorColor: Colors.green,
              controller: _senha,
              // validator: (String? value) {
              //   if(!value!.contains() ){
              //     return 'Tem mais de 5 digitos';
              //   }
              // },
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
                  if (_formKey.currentState!.validate()){
                    try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _login.text, password: _senha.text);
                  } catch (e) {
                    log(e.toString());
                  } 
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
                    Navigator.push(
                      context,
                     MaterialPageRoute(builder: (context) => const SignUpPage()));
                  }, child: const Text('Não tem conta')),
            ),
          ],
        ),
      ),
    );
  }
}
