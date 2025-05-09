import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/intro.dart';

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
  AlertController alertController = AlertController();

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

Future<void> deleteDocumentWithId(String collectionName, String id) async {
  try {
    // Verifica se o ID realmente existe na coleção
    var collectionRef = FirebaseFirestore.instance.collection(collectionName);
    
    var documents = await collectionRef.get(); // Obtém todos os documentos da coleção
    for (var doc in documents.docs) {
      debugPrint("Documento encontrado: ${doc.id}"); // Exibe os documentos existentes
    }

    // Referência ao documento no Firestore
    var docRef = collectionRef.doc(id);

    // Verifica se o documento existe antes de deletar
    var docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      await docRef.delete();
      debugPrint("Documento com ID '$id' foi deletado.");
    } else {
      debugPrint("Nenhum documento encontrado com ID '$id'.");
    }
  } catch (e) {
    debugPrint("Erro ao deletar documento: $e");
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
                    SnackBar(
                      content: Text('Por favor, insira um nome válido.'),
                    ),
                  );
                }
              },
              child:
                  _indicador
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
        centerTitle: true,
        title: Text(
          'Perfil do Usuário',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
/*         actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            color: Colors.red,
onPressed: () async {
  await alertController
      .bodyMessage(
        context,
        Text('Tem certeza que deseja deletar sua conta?'),
        () async {
          try {
            // Obtém o ID do usuário autenticado
            String? userId = FirebaseAuth.instance.currentUser?.uid;

            if (userId != null) {
              // Deleta o documento no Firestore que tem o mesmo nome do ID do usuário
              await deleteDocumentWithId("users", userId);

              // Deleta o usuário do Firebase Authentication
              await FirebaseAuth.instance.currentUser?.delete();

              // Navega para a tela de introdução
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Intro(),
                ),
              );
            }
          } catch (e) {
            alertController.showSnackBarError(
              context,
              'Erro ao deletar a conta',
            );
          }
        },
        () {},
        btnTitle: 'Deletar',
      )
      .show();
},

          ),
        ], */
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
              label: Text(
                'Atualizar Nome',
                style: TextStyle(color: Colors.white),
              ),
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
