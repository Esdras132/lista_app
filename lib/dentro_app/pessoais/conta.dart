import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Conta extends StatefulWidget {
  @override
  _ContaState createState() => _ContaState();
}

class _ContaState extends State<Conta> {
  String? verNome;
  final TextEditingController _displayNameController = TextEditingController();
  String? verEmail;

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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Atualizar Nome de Usuário'),
                    content: TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Novo Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          String newName = _displayNameController.text.trim();
                          if (newName.isNotEmpty) {
                            updateDisplayName(newName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Por favor, insira um nome válido.')),
                            );
                          }
                        },
                        child: Text('Salvar'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Atualizar Nome'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }
}
