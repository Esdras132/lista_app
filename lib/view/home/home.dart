import 'dart:convert';
import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/excel.controller.dart';
import 'package:lista_de_compras/main.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/view/config/lista.personalizada.dart';
import 'package:lista_de_compras/view/list/lista.dart';
import 'package:lista_de_compras/view/list/historico.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/view/config/calculadora.dart';
import 'package:lista_de_compras/view/config/configuracoes.dart';

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
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          appBar: AppBar(
            elevation: 8,
            shadowColor: Colors.black87,
            leading: null, // Removes the back button
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
                  child: Text("Lista", style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  child: Text(
                    'Histórico',
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
                      value: 2,
                      child: Row(
                        children: [
                          Text(
                            "Importar Lista \nPersonalizada",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.upload_file, color: Colors.white),
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
                  } else if (value == 2) {
                    setState(() {
                      _isloading = true;
                    });
                    try {
                      final lista =
                          await DBserviceListaPersonalizada.fetchAll().first;
                      log('Lista personalizada: ${lista.length}');
                      if (lista.length > 0) {
                        DBServiceLista.deleteMyList();
                        await Future.delayed(Duration(seconds: 1));
                        for (var item in lista) {
                          DBServiceLista.createMyList(item);
                        }
                      } else {
                        final String resposta = await rootBundle.loadString(
                          'assets/definicoes/definicoes.json',
                        );

                        final dados = json.decode(resposta);
                        List<String> nomes = (dados.keys.toList()).toList();
                        for (var nome in nomes) {
                          List<ItensListaModel> listaItens = [];
                          for (var item in (dados[nome] as List)) {
                            ItensListaModel itemModel = ItensListaModel(
                              descricao: (item['descricao'] as String?) ?? '',
                              quantidade:
                                  (item['quantidade'] as num?)?.toDouble(),
                            );
                            listaItens.add(itemModel);
                          }
                          ListaModel model = ListaModel(
                            descricao: nome,
                            itensName: listaItens,
                          );

                          DBServiceLista.createMyList(model);
                        }
                      }
                      setState(() {
                        _isloading = false;
                      });
                    } catch (e) {
                      setState(() {
                        _isloading = false;
                      });
                      throw Exception('Erro ao carregar o arquivo JSON: $e');
                    }
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
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyApp(),
                            ),
                          );
                        } catch (e) {
                          log(e.toString());
                          // ignore: use_build_context_synchronously
                          alert.showSnackBarError(
                            // ignore: use_build_context_synchronously
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
                backgroundColor: Colors.green,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  alert
                      .bodyMessage(
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
          /*           floatingActionButton: Builder(
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
                    color: Colors.green,
                    position: position,
                    items: <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap:
                            () =>
                                alert
                                    .bodyMessage(
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
                                                decoration:
                                                    const InputDecoration(
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
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  2,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Cancelar',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
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
                                                          backgroundColor:
                                                              Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  2,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            setState(() {
                                                              HistoricoModel
                                                              model = HistoricoModel(
                                                                descricao:
                                                                    _nomeController
                                                                        .text,
                                                                items: [],
                                                              );
                                                              DBServiceHistorico.createMyList(
                                                                model,
                                                              );
                                                              _nomeController
                                                                  .text = '';
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
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
                                    .show(),

                        child: Text(
                          'Lista com preço',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem<String>(
                        onTap:
                            () =>
                                alert
                                    .bodyMessage(
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
                                                decoration:
                                                    const InputDecoration(
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
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  2,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Cancelar',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
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
                                                          backgroundColor:
                                                              Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  2,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            setState(() {
                                                              ListaModel
                                                              model = ListaModel(
                                                                descricao:
                                                                    _nomeController
                                                                        .text,
                                                                personalizada:
                                                                    false,
                                                                itensName: [],
                                                              );
                                                              DBServiceLista.createMyList(
                                                                model,
                                                              );
                                                              _nomeController
                                                                  .text = '';
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
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
                                    .show(),
                        child: Text(
                          'Lista sem preço',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ), */
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
