import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _senha = TextEditingController();
  TextEditingController _confirmacaoSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: naoTemCadastro(),
        ));
  }

  naoTemCadastro() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
              controller: _email,
              //Não esta funcionado o codigo de baixo
              validator: (value) {
                if (!value!.contains('@gmail.com') &&
                    !value.contains('@outlook.com')) {
                  return 'Coloque o emal com @gmail.com ou @outlook.com';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Email'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              cursorColor: Colors.green,
              controller: _senha,
              validator: (value) {
                if (value!.length < 6) {
                  return 'Precisa que sua senha tenha mais de 6 digitos';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Senha'),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              cursorColor: Colors.green,
              controller: _confirmacaoSenha,
              validator: (value) {
                if (value!.length < 6) {
                  return 'Precisa que sua senha tenha mais de 6 digitos';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Confirmação Senha'),
              textInputAction: TextInputAction.done,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.green,
                margin: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_senha.text != _confirmacaoSenha.text) {
                        _naoEstao();
                      } else {
                        if (_senha.text == _confirmacaoSenha.text &&
                            _email.text.isNotEmpty) {
                           FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _email.text, password: _senha.text);
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Future _naoEstao() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atenção'),
            content: const Text(
                'Para continuar os campos senha e confirmação de senha precisão esta iquais'),
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
