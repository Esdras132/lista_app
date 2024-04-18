import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Conta extends StatefulWidget {
  @override
  _ContaState createState() => _ContaState();
}

class _ContaState extends State<Conta> {
  String? verNome;
  String? verEmail;
  bool _indicador = false;

  @override
  void initState() {
    super.initState();
    Name();
    Email();
  }

  Future<void> Email() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    setState(() {
      verEmail = email;
    });
  }

  Future<void> Name() async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    setState(() {
      verNome = name;
    });
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      setState(() {
        verNome = newName;
      });
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao atualizar o nome de usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nome de Usuário: ' + verNome!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ' + verEmail!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                EditName();
              },
              child: Text('Atualizar Nome'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> EditName() async {
    TextEditingController controller = TextEditingController();
    controller.text = verNome!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atualizar Nome de Usuário'),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Novo Nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            _indicador
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.green,
                    backgroundColor: Colors.grey,
                  ))
                : Text(''),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _indicador = true;
                  setState(() {});
                  log(_indicador.toString());
                  try {
                    setState(() {});
                    updateDisplayName(controller.text);
                  } catch (e) {
                    log(e.toString());
                  } finally {
                    _indicador = false;
                    log(_indicador.toString());
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Por favor, insira um nome válido.')),
                  );
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
  // Future<void> EditNome() async {
  //   TextEditingController controller = TextEditingController();
  //   controller.text = verNome!;
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Atualizar Nome de Usuário'),
  //         content: Column(
  //           children: [
  //             TextFormField(
  //               controller: controller,
  //               decoration: InputDecoration(
  //                 labelText: 'Novo Nome',
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Cancelar'),
  //           ),
  //           _indicador
  //               ? Text('Atualizando')
  //               : TextButton(
  //                   onPressed: () {
  //                     if (controller.text.isNotEmpty) {
  //                       _indicador = true;
  //                       try {
  //                         _indicador = false;
  //                         updateDisplayName(controller.text);
  //                       } catch (e) {
  //                         _indicador = false;
  //                         log(e.toString());
  //                       } finally {
  //                         _indicador = false;
  //                       }
  //                     } else {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         SnackBar(
  //                             content:
  //                                 Text('Por favor, insira um nome válido.')),
  //                       );
  //                     }
  //                   },
  //                   child: Text('Salvar'),
  //                 ),
  //         ],
  //       );
  //     },
  //   );
  // }
