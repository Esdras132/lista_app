import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "dart:developer";
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';

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
  bool passenable = true;
  bool passenableCon = true;
  bool _indicador = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: 
          _indicador
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.green,
              backgroundColor: Colors.grey,
            ))
          : naoTemCadastro(),
        ));
  }

  naoTemCadastro() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Imagem principal
                  Image.asset(
                    "assets/logo_lista.png",
                    width: 100,
                    alignment: Alignment.center,
                  ),
                  //aqui é o final

                  //Email
                  TextFormField(
                    autofocus: true,
                    cursorColor: Colors.green,
                    autofillHints: const [AutofillHints.email],
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                    controller: _email,
                    validator: (value) {
                      if (value == null) {
                        return 'coloque um E-mail valido';
                      } else if (!EmailValidator.validate(value)) {
                        return 'coloque um E-mail valido';
                      } else {
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        suffix: Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.email,
                            color: Colors.green,
                          ),
                        )),
                    textInputAction: TextInputAction.next,
                  ),
                  //aqui finaliza

                  //Senha principal
                  TextFormField(
                    obscureText: passenable,
                    cursorColor: Colors.green,
                    controller: _senha,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      if (value!.length < 6) {
                        return 'Precisa que sua senha tenha mais de 6 digitos';
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
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  //Aqui termina

                  ///confirmação de Senha
                  TextFormField(
                    obscureText: passenableCon,
                    cursorColor: Colors.green,
                    controller: _confirmacaoSenha,
                    autofillHints: const [AutofillHints.password],
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                    validator: (value) {
                      if (value!.length < 6) {
                        return 'Precisa que sua senha tenha mais de 6 digitos';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirmação Senha',
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            if (passenableCon) {
                              passenableCon = false;
                            } else {
                              passenableCon = true;
                            }
                          });
                        },
                        icon: Icon(
                          passenableCon == true
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.green,
                          weight: 5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  //aqui finaliza

                  Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.green,
                      margin: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: () async {
                          final form = _formKey.currentState!;
                          if (form.validate()) {
                            if (_senha.text != _confirmacaoSenha.text) {
                              _naoEstao();
                            } else {
                              if (_senha.text == _confirmacaoSenha.text &&
                                  _email.text.isNotEmpty) {
                                    _indicador = true;
                                try {
                                  TextInput.finishAutofillContext();
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: _email.text.trim(),
                                          password: _senha.text.trim());
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                } catch (e) {
                                  _jaExiste();
                                  log(e.toString());
                                } finally{
                                  _indicador = false;
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
            ),
          )),
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

  Future<void> _jaExiste() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alerta'),
            content: const Text('Esse email ja esta logado em outra conta'),
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
