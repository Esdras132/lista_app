import "dart:developer";
import 'package:Lista_de_compras/login/sign-up_page.dart';
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
  bool passenable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: widgetTextField(),
    ));
  }

  widgetTextField(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AutofillGroup(
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
                autofocus: true,
                autofillHints: const [AutofillHints.email],
                cursorColor: Colors.green,
                controller: _login,
                validator: (String? value) {
                  if (!value!.contains('@gmail.com') &&
                      !value.contains('@outlook.com')) {
                    return 'E-mail inválido!';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Login',
                    suffix: Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.email,
                        color: Colors.green,
                      ),
                    )),
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                obscureText: passenable,
                cursorColor: Colors.green,
                controller: _senha,
                autofillHints: const [AutofillHints.password],                
                validator: (String? value) {
                  if (value!.length < 6) {
                    return 'Tem mais de 6 dígitos';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Senha",
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        if (passenable) {
                          passenable = false;
                        } else {
                          passenable = true;
                        }
                      });
                    },
                    icon: Icon(
                      passenable == true
                          ? Icons.remove_red_eye
                          : Icons.password,
                      color: Colors.green,
                    ),
                  ),
                ),
                onEditingComplete: () => TextInput.finishAutofillContext(),
                textInputAction: TextInputAction.done,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.green,
                margin: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _login.text, password: _senha.text);
                        const Center(
                            child: CircularProgressIndicator(
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                        ));
                      } catch (e) {
                        //mensagem de senha incorreta
                        _senhaOuEmailErro();
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
                    _login.text = '';
                    _senha.text = '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text('Não tem conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _senhaOuEmailErro() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atenção'),
            content: const Text('Login ou Senha incorretos'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}
