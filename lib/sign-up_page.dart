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
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            cursorColor: Colors.green,
            controller: _senha,
            decoration: const InputDecoration(labelText: 'Senha'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            cursorColor: Colors.green,
            controller: _confirmacaoSenha,
            decoration: const InputDecoration(labelText: 'confirmação Senha'),
            textInputAction: TextInputAction.done,
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.green,
              margin: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () {
                  if (_email.text.isEmpty) {
                    _senhasSemNada();
                  } else {
                    if (_confirmacaoSenha.text.isEmpty) {
                      _senhasSemNada();
                    } else {
                      if (_senha.text.isEmpty) {
                        _senhasSemNada();
                      } else {
                        if( _senha.text != _confirmacaoSenha.text){
                          _senhasSemNada();
                        }else{
                          if(_senha.text == _confirmacaoSenha.text|| _email.text.isNotEmpty){
                            FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _senha.text);
                            Navigator.pop(context);
                          }
                        }
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
    );
  }

  Future _senhasSemNada() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atenção'),
            content: const Text(
                'Para continuar os campos Email, Senha e confirmação precisão estar preenchidos e os campos senha e confirmação de senha precisão esta iquais'),
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
