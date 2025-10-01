import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/excel.controller.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:lista_de_compras/main.dart';
import 'package:lista_de_compras/view/config/lista.personalizada.dart';
import 'package:lista_de_compras/view/list/lista.dart';
import 'package:lista_de_compras/view/list/historico.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/view/config/calculadora.dart';
import 'package:lista_de_compras/view/config/configuracoes.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  String? verNome = '';

  final excelController = ExcelController();
  List lista = [];
  bool _isloading = false;
  final TextEditingController _nomeController = TextEditingController();
  final AlertController alert = AlertController();
  final _formKey = GlobalKey<FormState>();

  var checkedList = [];
  final dbService = DBServiceHistorico();

  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _tabHistoricoKey = GlobalKey();
  final GlobalKey _tabListaKey = GlobalKey();

  List<TargetFocus> targets = [];

  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  @override
  void initState() {
    super.initState();
    sharedPreferencesController.get(context, 'home_user_id').then((value) {
      value == null
          ? {
            sharedPreferencesController.set(
              context,
              'home_user_id',
              FirebaseAuth.instance.currentUser!.uid,
            ),
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showTutorial();
            }),
          }
          : {
            if (value == FirebaseAuth.instance.currentUser!.uid)
              {log(value.toString())}
            else
              {
                sharedPreferencesController.set(
                  context,
                  'home_user_id',
                  FirebaseAuth.instance.currentUser!.uid,
                ),
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showTutorial();
                }),
              },
          };
    });
  }

  void _showTutorial() {
    targets.clear();

    targets.add(
      TargetFocus(
        identify: "FAB",
        keyTarget: _fabKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Aqui você adiciona um novo item à sua lista",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Menu",
        keyTarget: _menuKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Aqui ficam as configurações, exportação, criar uma lista personalizada e outras opções",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Aba Lista",
        keyTarget: _tabListaKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Aqui você acessa sua lista de compras",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Aba Histórico",
        keyTarget: _tabHistoricoKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Aqui você acessa o histórico de suas listas",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.green.shade900,
      textSkip: "PULAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      alignSkip: Alignment.bottomRight,
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      var teste = false;
      alert
          .confirmDialog(
            context,
            bodyMessage: 'Deseja sair do app?',
            btnOk: () {
              teste = true;
              Navigator.of(context).popUntil((route) => route.isFirst);
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            btnCancel: () {
              teste = false;
            },
          )
          .show();

      return teste;
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,

      child: WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          appBar: AppBar(
            elevation: 8,
            shadowColor: Colors.black87,
            leading: null,
            automaticallyImplyLeading: false,
            title: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Bem Vindo(a)',
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
              indicatorColor: Colors.white,
              dividerColor: Colors.green,
              tabs: [
                Tab(
                  key: _tabListaKey,
                  child: Text("Lista", style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  key: _tabHistoricoKey,
                  child: Text(
                    'Histórico',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton(
                key: _menuKey,
                color: Colors.green,
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 0,

                      child: Row(
                        children: [
                          Text(
                            "Exportar Excel",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.file_download, color: Colors.white),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Text(
                            "Calculadora",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.calculate_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Text(
                            "Lista Personalizada",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.list, color: Colors.white),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 4,
                      child: Row(
                        children: [
                          Text(
                            "Configurações",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.settings_outlined, color: Colors.white),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 5,
                      child: Row(
                        children: [
                          Text(
                            "Desconectar",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.logout_outlined, color: Colors.red),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (value) async {
                  if (value == 0) {
                    await excelController.exportarExcel(context);
                    if (!context.mounted) return;
                  } else if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalculatorView()),
                    );
                  } else if (value == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListaPersonalizada(),
                      ),
                    );
                  } else if (value == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Config()),
                    );
                  } else if (value == 5) {
                    alert.bodyMessage(
                      context,
                      Text('Você deseja sair da sua conta?'),
                      () async {
                        try {
                          await FirebaseAuth.instance.signOut();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyApp(),
                            ),
                          );
                        } catch (e) {
                          log(e.toString());

                          alert.showSnackBarError(
                            context,
                            'Erro ao sair da conta',
                          );
                        }
                      },
                      () {},
                    ).show();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                key: _fabKey,
                backgroundColor: Colors.green,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  alert
                      .bodyMessage(
                        context,
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Form(
                            key: _formKey,
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
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
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
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                ListaModel model = ListaModel(
                                                  descricao:
                                                      _nomeController.text,
                                                  personalizada: false,
                                                  itensName: [],
                                                );
                                                DBServiceLista.createMyList(
                                                  model,
                                                );
                                                _nomeController.text = '';
                                                Navigator.of(context).pop();
                                              });
                                            }
                                          },
                                          child: Text(
                                            'Salvar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        null,
                        null,
                      )
                      .show();
                },
              );
            },
          ),
          body: TabBarView(
            children: [
              _isloading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      backgroundColor: Colors.grey,
                    ),
                  )
                  : Lista(),
              ListaHistorico(),
            ],
          ),
        ),
      ),
    );
  }
}
