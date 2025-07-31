import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';

class ListaNameController {
  AlertController alert = AlertController();

  addItem(BuildContext context, NameModel nameModel, VoidCallback? refresh) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController items = TextEditingController();
    final TextEditingController qtd = TextEditingController();
    alert
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

                  SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.green,
                    controller: qtd,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                    onEditingComplete: () {
                      if (!formKey.currentState!.validate()) {
                      } else {
                        ItensNameModel item = ItensNameModel(
                          descricao: items.text,
                          quantidade: qtd.text.isEmpty
                                      ? double.parse("0")
                                      : double.parse(
                                          qtd.text.replaceAll(',', '.'),
                                        ),
                        );
                        nameModel.itensName!.add(item);
                        nameModel.update();
                        refresh!();
                        items.text = '';
                        qtd.text = '';
                        Navigator.of(context).pop();
                      }
                    },
                    textInputAction: TextInputAction.done,
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
                                ItensNameModel item = ItensNameModel(
                                  descricao: items.text,
                                  quantidade: qtd.text.isEmpty
                                      ? double.parse("0")
                                      : double.parse(
                                          qtd.text.replaceAll(',', '.'),
                                        ),
                                );
                                nameModel.itensName!.add(item);
                                nameModel.update();
                                refresh!();
                                items.text = '';
                                qtd.text = '';
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

  editItem(
    BuildContext context,
    NameModel nameModel,
    ItensNameModel model,
    VoidCallback? refresh,
  ) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController items = TextEditingController(
      text: model.descricao!,
    );
    final TextEditingController qtd = TextEditingController(
      text: model.quantidade?.toString() ?? '0',
    );
    alert
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
                  SizedBox(height: 10),
                  TextFormField(
                    cursorColor: Colors.green,
                    autofocus: true,
                    controller: qtd,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Este campo é obrigatorio';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      if (!formKey.currentState!.validate()) {
                      } else {
                        model.descricao = items.text;
                        model.quantidade = qtd.text.isEmpty
                                      ? double.parse("0")
                                      : double.parse(
                                          qtd.text.replaceAll(',', '.'),
                                        );
                        nameModel.update();
                        refresh!();
                        items.text = '';
                        qtd.text = '';
                        Navigator.of(context).pop();
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
                                model.descricao = items.text;
                                model.quantidade = qtd.text.isEmpty
                                      ? double.parse("0")
                                      : double.parse(
                                          qtd.text.replaceAll(',', '.'),
                                        );
                                nameModel.update();
                                refresh!();
                                items.text = '';
                                qtd.text = '';
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

  deleteItem(BuildContext context, NameModel nameModel, VoidCallback? refresh) {
    alert.bodyMessage(
      context,

      Text('Tem certeza que deseja deletar itens selecionados?'),
      () async {
        for (var i = nameModel.itensName!.length - 1; i >= 0; i--) {
          if (nameModel.itensName![i].checked) {
            nameModel.itensName!.removeAt(i);
          }
        }
        nameModel.update();
        refresh!();
      },
      () => Navigator.of(context).pop(),
    ).show();
  }
}
