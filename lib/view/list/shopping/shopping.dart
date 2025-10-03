import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/shared.preferences.controller.dart';
import 'package:lista_de_compras/model/item.model.dart';
import 'package:lista_de_compras/model/lista.model.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.model, required this.refresh});

  final ListaModel model;
  final VoidCallback refresh;

  @override
  State<ShoppingPage> createState() => _ShoppingStatePage();
}

class _ShoppingStatePage extends State<ShoppingPage> {
  late List<double> _dragOffsets;
  AlertController alertController = AlertController();
  late final HistoricoModel historicoModel;
  
  SharedPreferencesController sharedPreferencesController =
      SharedPreferencesController();

  final GlobalKey _saveButtonKey = GlobalKey();
  final GlobalKey _tabBarKey = GlobalKey();
  final GlobalKey _totalKey = GlobalKey();
  final GlobalKey _firstItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    historicoModel = HistoricoModel(
      data: DateTime.now(),
      descricao: widget.model.descricao,
      items:
          widget.model.itensName!
              .map(
                (item) => ItemModel(
                  descricao: item.descricao,
                  quantidade: item.quantidade,
                  valor: 0.0,
                ),
              )
              .toList(),
    );
    _dragOffsets = List.filled(
      historicoModel.items!.where((a) => a.selected == false).length,
      0,
    );

     sharedPreferencesController.get(context, 'shopping_user_id').then((value) {
      value == null
          ? {
            sharedPreferencesController.set(
              context,
              'shopping_user_id',
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
                  'shopping_user_id',
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
    // Inicia a lista de alvos vazia
    List<TargetFocus> targets = [];

    // Só adiciona o alvo do primeiro item se a lista "A Comprar" não estiver vazia.
    if (historicoModel.items!.any((item) => item.selected == false)) {
      targets.add(
        TargetFocus(
          identify: "firstItem",
          keyTarget: _firstItemKey,
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
                child: const Text(
                  "Arraste um item para a direita para marcá-lo como comprado, ou para a esquerda para excluí-lo da lista.",
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
      );
    }

    // Adiciona os outros alvos que sempre existem na tela.
    targets.addAll([
      TargetFocus(
        identify: "tabBar",
        keyTarget: _tabBarKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                "Alterne entre os itens 'A Comprar' e os que já estão 'No Carrinho'.",
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
        identify: "total",
        keyTarget: _totalKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Text(
              "Aqui você vê o valor total dos itens que estão no seu carrinho.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "saveButton",
        keyTarget: _saveButtonKey,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Quando terminar, clique aqui para salvar sua compra no histórico.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    ]);


    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.green.shade900,
      textSkip: "PULAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      alignSkip: Alignment.bottomLeft,
    ).show(context: context);
  }

  void save() {
    alertController
        .confirmDialog(
          context,
          bodyMessage: 'Deseja salvar a lista?',
          btnCancel: () {},
          btnOk: () {
            alertController.showSnackBarSucesso(
              context,
              'Lista salva com sucesso',
            );
            final items =
                historicoModel.items!.where((a) => a.selected == true).toList();
            final item = HistoricoModel(
              data: historicoModel.data,
              descricao: historicoModel.descricao,
              items: items,
            );
            DBServiceHistorico.createMyList(item);
            widget.refresh();
            Navigator.pop(context);
            Navigator.pop(context);
          },
        )
        .show();
  }

  void saveitem(ItemModel item, Function refresh) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController items = TextEditingController(
      text: item.descricao,
    );
    final TextEditingController quantidade = TextEditingController(
      text: item.quantidade.toString(),
    );
    final TextEditingController valor = TextEditingController(
      text: item.valor.toString(),
    );
    alertController
        .bodyMessage(
          context,
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    cursorColor: Colors.green,
                    autofocus: true,
                    controller: items,
                    decoration: const InputDecoration(
                      labelText: 'Nome do item',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Este campo é obrigatorio';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    cursorColor: Colors.green,
                    controller: quantidade,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    cursorColor: Colors.green,
                    controller: valor,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      if (formKey.currentState!.validate()) {
                        item.selected = true;
                        item.quantidade = double.parse(
                          quantidade.text.replaceAll(',', '.'),
                        );
                        item.descricao = items.text;
                        item.valor = double.parse(
                          valor.text.replaceAll(',', '.'),
                        );
                        refresh();
                        Navigator.of(context).pop();
                      } else {
                        return;
                      }
                    },
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
                                borderRadius: BorderRadius.circular(2),
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
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                item.selected = true;
                                item.quantidade = double.parse(
                                  quantidade.text.replaceAll(',', '.'),
                                );
                                item.descricao = items.text;
                                item.valor = double.parse(
                                  valor.text.replaceAll(',', '.'),
                                );
                                refresh();
                                Navigator.of(context).pop();
                              } else {
                                return;
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
                ],
              ),
            ),
          ),
          null,
          null,
        )
        .show();
  }

  void _handleDragUpdate(int index, double delta) {
    setState(() {
      _dragOffsets[index] = (_dragOffsets[index] + delta).clamp(-150, 150);
    });
  }

  void _handleDragEnd(int index) {
    setState(() {
      if (_dragOffsets[index] > 80) {
        _dragOffsets[index] = 150;
      } else if (_dragOffsets[index] < -80) {
        _dragOffsets[index] = -150;
      } else {
        _dragOffsets[index] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.green[700],
        appBar: AppBar(
          title: const Text('Compras', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              key: _saveButtonKey,
              onPressed: () {
                save();
              },
              icon: Icon(Icons.check),
            ),
          ],
          bottom: TabBar(
            key: _tabBarKey,
            indicatorColor: Colors.white,
            dividerColor: Colors.green,
            tabs: [
              Tab(
                child: Text(
                  "A Comprar\n QTD: ${historicoModel.items!.where((a) => a.selected == false).length}",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  "No Carrinho\n QTD: ${historicoModel.items!.where((a) => a.selected == true).length}",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Hero(
          key: _totalKey,
          tag: 'fab',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total: ${UtilBrasilFields.obterReal(historicoModel.getTotal())}',
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount:
                  historicoModel.items!
                      .where((a) => a.selected == false)
                      .length,
              itemBuilder: (context, index) {
                final item = historicoModel.items!
                    .where((i) => i.selected == false)
                    .elementAt(index);

                return GestureDetector(
                  key: index == 0 ? _firstItemKey : null,
                  onHorizontalDragUpdate:
                      (details) => _handleDragUpdate(index, details.delta.dx),
                  onHorizontalDragEnd: (_) => _handleDragEnd(index),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade100,
                              Colors.red.shade100,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                saveitem(item, () {
                                  setState(() {});
                                  widget.refresh();
                                });
                              },
                              icon: Icon(Icons.check, size: 36),
                              color: Colors.green,
                            ),
                            IconButton(
                              onPressed: () {
                                historicoModel.items!.remove(item);
                                setState(() {});
                                widget.refresh();
                              },
                              icon: Icon(Icons.delete, size: 36),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          _dragOffsets[index],
                          0,
                          0,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        child: Card(
                          elevation: 6,
                          shadowColor: Colors.green.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  item.descricao!,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                'QTD ${item.quantidade} ${item.quantidade?.truncateToDouble() == item.quantidade ? 'UN' : 'KG'}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount:
                  historicoModel.items!.where((a) => a.selected == true).length,
              itemBuilder: (context, index) {
                final item = historicoModel.items!
                    .where((i) => i.selected == true)
                    .elementAt(index);

                return Center(
                  child: Card(
                    elevation: 6,
                    shadowColor: Colors.green.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.green, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            item.descricao!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap:
                            () => saveitem(item, () {
                              setState(() {});
                              widget.refresh();
                            }),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            historicoModel.items!.remove(item);
                            setState(() {});
                            widget.refresh();
                          },
                        ),
                        subtitle: Column(
                          children: [
                            Text(
                              'QTD ${item.quantidade} ${item.quantidade?.truncateToDouble() == item.quantidade ? 'UN' : 'KG'}',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              UtilBrasilFields.obterReal(item.valor!),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
