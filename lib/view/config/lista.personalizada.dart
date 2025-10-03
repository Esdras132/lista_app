import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:lista_de_compras/view/config/widget/itens.personalizada.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ListaPersonalizada extends StatefulWidget {
  const ListaPersonalizada({super.key});

  @override
  State<ListaPersonalizada> createState() => _ListaPersonalizadaState();
}

class ListaItem {
  String id;
  String title;
  String table;
  String subtitle;
  bool personalizada;

  ListaItem({
    required this.id,
    required this.table,
    required this.title,
    required this.subtitle,
    this.personalizada = false,
  });
}

class _ListaPersonalizadaState extends State<ListaPersonalizada> {
  AlertController alertController = AlertController();
  bool _loading = false;
  final personalizada = DBserviceListaPersonalizada.fetchAll().first;
  final List<ListaItem> _itens = [
    ListaItem(
      id: 'cafe',
      table: 'Café',
      title: 'Lista do Café',
      subtitle: 'Café, Pão, Leite, Açúcar, Achocolatado, Filtro para Café',
    ),
    ListaItem(
      id: 'almoco',
      table: 'Almoço',
      title: 'Lista do Almoço',
      subtitle:
          'Arroz, Feijão, Óleo, Sal, Macarrão, Molho de tomate, Tempero pronto',
    ),
    ListaItem(
      id: 'janta',
      table: 'Jantar',
      title: 'Lista do Jantar',
      subtitle: 'Sopa, Pão, Macarrão, Cebola, Alface',
    ),
    ListaItem(
      id: 'higiene',
      table: 'Higiene',
      title: 'Lista de Higiene',
      subtitle:
          'Shampoo, Condicionador, Sabonete, Desodorante, Papel higiênico, Creme dental, Fio dental, Escova de dentes, Cotonete, Algodão, Absorvente ',
    ),
    ListaItem(
      id: 'lanche',
      table: 'Lanche',
      title: 'Lista do Lanche',
      subtitle: 'Pão, Achocolatado, Leite, Biscoito, Queijo, Presunto',
    ),
  ];

  // Chaves para o tutorial
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _descriptionKey = GlobalKey();
  final GlobalKey _simOrNoKey = GlobalKey();

  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  @override
  void initState() {
    super.initState();

    sharedPreferencesController.get(context, 'personalizada_user_id').then((
      value,
    ) {
      value == null
          ? {
            sharedPreferencesController.set(
              context,
              'personalizada_user_id',
              FirebaseAuth.instance.currentUser!.uid,
            ),
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showTutorial();
            }),
          }
          : {
            if (value != FirebaseAuth.instance.currentUser!.uid)
              {
                sharedPreferencesController.set(
                  context,
                  'personalizada_user_id',
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
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "Title",
        keyTarget: _titleKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child:Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Aqui você vê o nome da lista.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                )
              )
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Description",
        keyTarget: _descriptionKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Esta é uma breve descrição do que a lista contém.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "YesNoToggle",
        keyTarget: _simOrNoKey,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Use 'Sim' ou 'Não' para decidir se os itens predefinidos desta lista farão parte da sua lista de compras final.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    ];

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
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Lista Personalizada',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _loading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Carregando Sua \n Lista Personalizada...',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _itens.length,
                          itemBuilder: (context, index) {
                            final item = _itens[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSettingItem(item, index),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildSaveButton(0.7),
                          const SizedBox(width: 6),
                          _buildViewButton(0.2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSaveButton(double porcentagem) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * porcentagem,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            _loading = true;
          });

          DBServiceLista.deleteMyList();

          final lista = await DBserviceListaPersonalizada.fetchAll().first;
          log('Lista personalizada: ${lista.length}');

          if (lista.isNotEmpty) {
            await DBserviceListaPersonalizada.deleteMyList();
          }

          try {
            final Map<String, dynamic> dados = {};

            for (var item in _itens) {
              if (item.personalizada) {
                final String resposta = await rootBundle.loadString(
                  'assets/definicoes/${item.id}.json',
                );
                dados[item.table] = json.decode(resposta);
              } else {
                final String resposta = await rootBundle.loadString(
                  'assets/definicoes/nao_${item.id}.json',
                );
                dados[item.table] = json.decode(resposta);
              }
            }

            for (var item in dados.entries) {
              List<ItensListaModel> modelItems = [];
              for (var item in item.value) {
                modelItems.add(
                  ItensListaModel(
                    descricao: item['descricao']?.toString() ?? '',
                    quantidade: (item['quantidade'] as num?)?.toDouble(),
                  ),
                );
              }
              ListaModel model = ListaModel(
                descricao: item.key.toString(),
                personalizada: true,
                itensName: modelItems,
              );

              DBserviceListaPersonalizada.createMyList(model);
            }
            await Future.delayed(Duration(seconds: 1));

            try {
              final lista = await DBserviceListaPersonalizada.fetchAll().first;
              log('Lista personalizada: ${lista.length}');
              if (lista.length > 0) {
                DBServiceLista.deleteMyList();
                await Future.delayed(Duration(seconds: 1));
                for (var item in lista) {
                  DBServiceLista.createMyList(item);
                }
                log('Lista personalizada salva: ${lista.length}');
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
                      quantidade: (item['quantidade'] as num?)?.toDouble(),
                    );
                    listaItens.add(itemModel);
                  }
                  ListaModel model = ListaModel(
                    descricao: nome,
                    itensName: listaItens,
                  );

                  DBServiceLista.createMyList(model);
                }
                log('Lista padrão salva: ${nomes.length}');
              }
            } catch (e) {
              throw Exception('Erro ao salvar lista personalizada: $e');
            }

            if (mounted) {
              alertController
                  .successMessage(
                    context,
                    'Lista personalizada\nCriada com sucesso!',
                  )
                  .show();
            }
          } catch (e) {
            throw Exception('Erro ao salvar lista personalizada: $e');
          } finally {
            setState(() {
              _loading = false;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Salvar',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(double porcentagem) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * porcentagem,
      child: IconButton(
        onPressed: () async {
          final lista = await DBserviceListaPersonalizada.fetchAll().first;
          alertController
              .bodyMessage(
                context,
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      const Text(
                        'Edite sua Lista:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (var item in lista)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ItemsListaPersonalizadaPage(
                                              model: item,
                                            ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                item.descricao,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Divider(),
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.8,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  _loading = true;
                                });
                                try {
                                  final lista =
                                      await DBserviceListaPersonalizada.fetchAll()
                                          .first;
                                  log('Lista personalizada: ${lista.length}');
                                  if (lista.isNotEmpty) {
                                    DBServiceLista.deleteMyList();
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    for (var item in lista) {
                                      DBServiceLista.createMyList(item);
                                    }
                                    log(
                                      'Lista personalizada salva: ${lista.length}',
                                    );
                                  } else {
                                    final String resposta = await rootBundle
                                        .loadString(
                                          'assets/definicoes/definicoes.json',
                                        );

                                    final dados = json.decode(resposta);
                                    List<String> nomes =
                                        (dados.keys.toList()).toList();
                                    for (var nome in nomes) {
                                      List<ItensListaModel> listaItens = [];
                                      for (var item in (dados[nome] as List)) {
                                        ItensListaModel itemModel =
                                            ItensListaModel(
                                              descricao:
                                                  (item['descricao']
                                                      as String?) ??
                                                  '',
                                              quantidade:
                                                  (item['quantidade'] as num?)
                                                      ?.toDouble(),
                                            );
                                        listaItens.add(itemModel);
                                      }
                                      ListaModel model = ListaModel(
                                        descricao: nome,
                                        itensName: listaItens,
                                      );

                                      DBServiceLista.createMyList(model);
                                    }
                                    log('Lista padrão salva: ${nomes.length}');
                                  }
                                  if (mounted) {
                                    alertController
                                        .successMessage(
                                          context,
                                          'Lista personalizada\nRecriada com sucesso!',
                                        )
                                        .show();
                                  }
                                } catch (e) {
                                  throw Exception(
                                    'Erro ao salvar lista personalizada: $e',
                                  );
                                } finally {
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                alignment: Alignment.center,
                                maximumSize: Size(
                                  MediaQuery.of(context).size.width * 0.8,
                                  MediaQuery.of(context).size.height * 0.8,
                                ),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Recriar Lista!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                null,
                null,
              )
              .show();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.library_books_sharp, color: Colors.green),
      ),
    );
  }

  Widget _buildSettingItem(ListaItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade900,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          item.title,
          key: index == 0 ? _titleKey : null,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  item.subtitle,
                  key: index == 0 ? _descriptionKey : null,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            const SizedBox(height: 8),
            _buildToggleRow(
              index: index,
              label: 'Personalizada:',
              value: item.personalizada,
              onChanged: (value) {
                setState(() {
                  item.personalizada = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required int index,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        Row(
          key: index == 0 ? _simOrNoKey : null,
          children: [
            _buildToggleButton(
              label: 'Sim',
              selected: value,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 8),
            _buildToggleButton(
              label: 'Não',
              selected: !value,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.green[700]! : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.green[700] : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
