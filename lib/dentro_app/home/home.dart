import 'dart:developer';

import 'package:lista_de_compras/dentro_app/home/widget/lista.dart';
import 'package:lista_de_compras/dentro_app/home/widget/lista.preco.dart';
import 'package:lista_de_compras/dentro_app/pessoais/configuracoes.dart';
import 'package:lista_de_compras/dentro_app/pessoais/conta.dart';
import 'package:lista_de_compras/main.dart';
import 'package:lista_de_compras/model/lista.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:flutter/widgets.dart';
import 'package:lista_de_compras/model/name.model.dart';

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  String? verNome;
  var lista = [];
  final TextEditingController _nomeController = TextEditingController();
  var checkedList = [];

  @override
  void initState() {
    super.initState();
    Name();
  }

  // ignore: non_constant_identifier_names
  Future<void> Name() async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    setState(() {
      verNome = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Exit App'),
                  content: Text('Você deseja sair do app?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Não'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Sim'),
                    ),
                  ],
                ),
          ) ??
          false;
    }

    // ignore: deprecated_member_use
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          appBar: AppBar(
          leading: null, // Removes the back button
            automaticallyImplyLeading: false,
            title: Text('Bem vindo ${verNome ?? ""}'),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Com preço',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    "Sem preço",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Text('Conta'),
                          SizedBox(width: 65),
                          Icon(Icons.account_circle_outlined),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Text("Configurações"),
                          SizedBox(width: 10),
                          Icon(Icons.settings),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Text(
                            "Desconectar",
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(width: 26),
                          Icon(Icons.logout, color: Colors.red),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Conta()),
                    );
                  } else if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Config()),
                    );
                  } else if (value == 2) {
                    _sair();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  final Offset buttonPosition = button.localToGlobal(
                    Offset.zero,
                    ancestor: overlay,
                  );
                  final RelativeRect position = RelativeRect.fromLTRB(
                    buttonPosition.dx,
                    buttonPosition.dy -
                        115, // Ajuste o valor conforme necessário
                    buttonPosition.dx + button.size.width,
                    buttonPosition.dy + button.size.height - 100,
                  );

                  showMenu(
                    context: context,
                    position: position,
                    items: <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap: () => _showAlertDialogCom(),
                        child: Text('Lista com preço'),
                      ),
                      PopupMenuItem<String>(
                        onTap: () => _showAlertDialogSem(),
                        child: Text('Lista sem preço'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          body: TabBarView(
            children: [
              RefreshIndicator(
                child: ListaPreco(),
                onRefresh:
                    () async => setState(() {
                      Name();
                    }),
              ),

              RefreshIndicator(
                child: Lista(),
                onRefresh:
                    () async => setState(() {
                      Name();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEmptyFieldsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Todos os campos são obrigatórios.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInvalidInputAlert() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
            'Não pode usar . nem , obrigado pela compreenção',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlertDialogSem() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item para Comprar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Item'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                _nomeController.text = '';
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (_nomeController.text.isEmpty) {
                  _showEmptyFieldsDialog();
                } else {
                  if (_nomeController.text.contains(RegExp(r'[.,].*[.,]'))) {
                    _showInvalidInputAlert();
                  } else {
                    setState(() {
                      NameModel model = NameModel(
                        descricao: _nomeController.text,
                        itensName: [],
                      );
                      DBserviceSem.createMyList(model);
                      _nomeController.text = '';
                      Navigator.pop(context);
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlertDialogCom() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item para Comprar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Item'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                _nomeController.text = '';
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (_nomeController.text.isEmpty) {
                  _showEmptyFieldsDialog();
                } else {
                  if (_nomeController.text.contains(RegExp(r'[.,].*[.,]'))) {
                    _showInvalidInputAlert();
                  } else {
                    setState(() {
                      ListaModel model = ListaModel(
                        descricao: _nomeController.text,
                        items: [],
                      );
                      DBserviceCom.createMyList(model);
                      _nomeController.text = '';
                      Navigator.pop(context);
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sair() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Você deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Não'),
            ),
            TextButton(
              child: const Text('sim'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp ()));
                }
                catch (e) {
                  log(e.toString());
                  _showAlert('Erro ao sair da conta');
                }
                
                
              },
            ),
          ],
        );
      },
    );
  }

    Future<void> _showAlert(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Text(
            message.toString(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
