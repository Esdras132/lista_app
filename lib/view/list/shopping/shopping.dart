import 'dart:developer';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/model/item.model.dart';
import 'package:lista_de_compras/model/lista.model.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/services/db.service.dart';

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
  }

  void save() {
    alertController.confirmDialog(
      context,
      bodyMessage: 'Deseja salvar a lista?',
      btnOk: () {
        alertController.showSnackBarSucesso(context, 'Lista salva com sucesso');
        DBServiceHistorico.createMyList(historicoModel);
        widget.refresh();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    ).show();
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
      _dragOffsets[index] = (_dragOffsets[index] + delta).clamp(
        -150,
        150,
      ); // agora pode ir pros dois lados
    });
  }

  void _handleDragEnd(int index) {
    setState(() {
      if (_dragOffsets[index] > 80) {
        _dragOffsets[index] = 150; // trava no lado direito
      } else if (_dragOffsets[index] < -80) {
        _dragOffsets[index] = -150; // trava no lado esquerdo
      } else {
        _dragOffsets[index] = 0; // volta pro centro
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
              onPressed: () {
                save();
              },
              icon: Icon(Icons.check),
            ),
          ],
          bottom: TabBar(
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
        floatingActionButton: Container(
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
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount:
                  historicoModel.items!.where((a) => a.selected == false).length,
              itemBuilder: (context, index) {
                final item = historicoModel.items!
                    .where((i) => i.selected == false)
                    .elementAt(index);

                return GestureDetector(
                  onHorizontalDragUpdate:
                      (details) => _handleDragUpdate(index, details.delta.dx),
                  onHorizontalDragEnd: (_) => _handleDragEnd(index),
                  child: Stack(
                    children: [
                      // Fundo com dois ícones sempre visível
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
                                /* item.selected = true; */
                                /* widget.model.update(); */
                              },
                              icon: Icon(Icons.check, size: 36),
                              color: Colors.green,
                            ),
                            IconButton(
                              onPressed: () {
                                historicoModel.items!.removeAt(index);
                                widget.model.update();
                                setState(() {});
                                widget.refresh();
                              },
                              icon: Icon(Icons.delete, size: 36),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),

                      // Card que se move pros dois lados
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
                            historicoModel.items!.removeAt(index);
                            widget.model.update();
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
