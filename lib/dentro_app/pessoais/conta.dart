import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Conta extends StatefulWidget {
  const Conta({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContaState createState() => _ContaState();
}

class _ContaState extends State<Conta> {
  String? verNome = '';
  String? verEmail;
  bool _indicador = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      verNome = user?.displayName ?? "Usuário";
      verEmail = user?.email ?? "Email não disponível";
    });
  }

  Future<void> _atualizarNome(String novoNome) async {
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(novoNome);
      setState(() {
        verNome = novoNome;
      });
      Navigator.pop(context);
    } catch (e) {
      log('Erro ao atualizar o nome: $e');
    }
  }

  Future<void> _editarNome() async {
    TextEditingController controller = TextEditingController(text: verNome);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualizar Nome de Usuário'),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Novo Nome',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              labelStyle: TextStyle(color: Colors.green),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  setState(() => _indicador = true);
                  await _atualizarNome(controller.text);
                  Navigator.pop(context);
                  setState(() => _indicador = false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, insira um nome válido.')),
                  );
                }
              },
              child: _indicador
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Salvar'),
            ),
          ],
        );
      },
    );
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green.shade700,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              verNome!,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 10),
            Text(
              verEmail!,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _editarNome,
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text('Atualizar Nome', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
