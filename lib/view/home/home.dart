import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/login/login.dart';
import 'package:lista_de_compras/view/calculadora.dart';
import 'package:lista_de_compras/view/home/widget/lista.dart';
import 'package:lista_de_compras/view/home/widget/lista.preco.dart';
import 'package:lista_de_compras/view/pessoais/configuracoes.dart';
import 'package:lista_de_compras/view/pessoais/conta.dart';

import 'package:lista_de_compras/model/lista.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/services/db.service.dart';
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
  final AlertController alert = AlertController();
  final _formKey = GlobalKey<FormState>();
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
            title: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Bem vindo ${verNome ?? ""}',
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  cursor: '|',
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: false,
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Com preço',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Tab(
                  child: Text(
                    "Sem preço",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton(
                color: Colors.green,
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Text("Conta",style: TextStyle(color: Colors.white),),
                          Spacer(),
                          Icon(Icons.account_circle_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                     const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Text("Calculadora",style: TextStyle(color: Colors.white),),
                          Spacer(),
                          Icon(Icons.calculate_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Text("Configurações",style: TextStyle(color: Colors.white),),
                          Spacer(),
                          Icon(Icons.settings_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Text(
                            "Desconectar",
                            style: TextStyle(color: Colors.red),
                          ),
                          Spacer(),
                          Icon(Icons.logout_outlined, color: Colors.red),
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
                      MaterialPageRoute(builder: (context) => CalculatorView()),
                    );
                  } else if (value == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Config()),
                    );
                  } else if (value == 3) {
                    alert.bodyMessage(
                      context,
                      Text('Você deseja sair da sua conta?'),
                      () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginpage(),
                            ),
                          );
                        } catch (e) {
                          log(e.toString());
                          // ignore: use_build_context_synchronously
                          alert.showSnackBarError(context, 'Erro ao sair da conta');
                        }
                      },
                      (){}
                    ).show();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                backgroundColor: Colors.green,
                child: const Icon(Icons.add, color: Colors.white),
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
                        onTap:
                            () =>
                                alert.bodyMessage(
                                  context,
                                  Form(
                                    key: _formKey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                          autofocus: true,
                                          cursorColor: Colors.green,
                                          validator:
                                              (value) =>
                                                  value!.isEmpty
                                                      ? 'Este campo é obrigatorio'
                                                      : null,
                                          controller: _nomeController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nome do Item',
                                          ),
                                        ),
                                                                                SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5),
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                                                           if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        ListaModel model = ListaModel(
                                          descricao: _nomeController.text,
                                          items: [],
                                        );
                                        DBserviceCom.createMyList(model);
                                        _nomeController.text = '';
                                        Navigator.of(context).pop();
                                      });
                                    }
                                      },
                                      child: Text(
                                        'Salvar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                                        ]
                                      ),
                                    ),
                                  ),
                                  null,null
                                ).show(),

                        child: Text('Lista com preço'),
                      ),
                      PopupMenuItem<String>(
                        onTap:
                            () =>
                                alert.bodyMessage(
                                  context,
                                  Form(
                                    key: _formKey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                          autofocus: true,
                                          cursorColor: Colors.green,
                                          validator:
                                              (value) =>
                                                  value!.isEmpty
                                                      ? 'Este campo é obrigatorio'
                                                      : null,
                                          controller: _nomeController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nome do Item',
                                          ),
                                        ),                                        SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ),

                                SizedBox(width: 5),
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        NameModel model = NameModel(
                                          descricao: _nomeController.text,
                                          itensName: [],
                                        );
                                        DBserviceSem.createMyList(model);
                                        _nomeController.text = '';
                                        Navigator.of(context).pop();
                                      });
                                    } 
                                      },
                                      child: Text(
                                        'Salvar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                                        ]
                                      ),
                                    ),
                                  ),
                                  null,null,
                                ).show(),
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
                    () async {setState(() {
                      Name();
                    });}, 
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
}
