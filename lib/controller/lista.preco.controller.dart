import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/model/item.model.dart';
import 'package:lista_de_compras/model/lista.model.dart';

class ListaPrecoController {
  final AlertController alert = AlertController();

  addItem(BuildContext context, ListaModel model, Function refresh) {
    final TextEditingController items = TextEditingController();
    final TextEditingController quantidade = TextEditingController(text: '0');
    final TextEditingController valor = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
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
                        ItemModel item = ItemModel(
                          descricao: items.text,
                          quantidade:
                              quantidade.text.isEmpty
                                  ? double.parse("0")
                                  : double.parse(
                                    quantidade.text.replaceAll(',', '.'),
                                  ),
                          valor:
                              valor.text.isEmpty
                                  ? double.parse("0")
                                  : double.parse(
                                    valor.text.replaceAll(',', '.'),
                                  ),
                        );
                        model.items!.add(item);
                        model.update();
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
                                ItemModel item = ItemModel(
                                  descricao: items.text,
                                  quantidade:
                                      quantidade.text.isEmpty
                                          ? double.parse("0")
                                          : double.parse(
                                            quantidade.text.replaceAll(
                                              ',',
                                              '.',
                                            ),
                                          ),
                                  valor:
                                      valor.text.isEmpty
                                          ? double.parse("0")
                                          : double.parse(
                                            valor.text.replaceAll(',', '.'),
                                          ),
                                );
                                model.items!.add(item);
                                model.update();
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

  deleteItem(BuildContext context, ListaModel model, Function refresh) {
    alert
        .bodyMessage(
          context,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Deseja Deletar todos os itens selecionados?'),
          ),
          () async {
            for (var i = model.items!.length - 1; i >= 0; i--) {
              if (model.items![i].checked) {
                model.items!.removeAt(i);
              }
            }
            await model.update();
            refresh();
          },
          () {},
          btnTitle: 'Deletar',
        )
        .show();
  }

  editItem(
    BuildContext context,
    ListaModel model,
    ItemModel item,
    Function refresh,
  ) {
    TextEditingController controller = TextEditingController();
    TextEditingController controllerqtd = TextEditingController();
    TextEditingController controllervalor = TextEditingController();
    final formKey = GlobalKey<FormState>();

    controller.text = item.descricao!;
    controllerqtd.text = item.quantidade.toString();
    controllervalor.text = item.valor.toString();
    alert
        .bodyMessage(
          context,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor insira um nome';
                      }
                      return null;
                    },
                    autofocus: true,
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  TextField(
                    controller: controllerqtd,
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextField(
                    controller: controllervalor,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
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
                                item.descricao = controller.text;
                                item.quantidade = double.parse(
                                  controllerqtd.text.replaceAll(',', '.'),
                                );
                                item.valor = double.parse(
                                  controllervalor.text.replaceAll(',', '.'),
                                );
                                model.update();
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
}
