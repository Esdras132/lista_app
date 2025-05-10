import 'package:flutter/material.dart';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/lista.preco.controller.dart';
import 'package:lista_de_compras/model/item.model.dart';
import 'package:lista_de_compras/model/lista.model.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, required this.model});

  final ListaModel model;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<ItemModel> items = [];
  AlertController alert = AlertController();
  final _formKey = GlobalKey<FormState>();
  ListaPrecoController controller = ListaPrecoController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${widget.model.descricao!.length > 20 ? '${widget.model.descricao!.substring(0, 20)}...' : widget.model.descricao!} ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "${UtilBrasilFields.obterReal(widget.model.getTotal())} Qtd: ${widget.model.items!.length.toString()}",
              // "Valor ${UtilBrasilFields.obterReal(widget.model.getTotal())} Qtd: ${widget.model.items!.length.toString()}",
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ],
        ),
        actions: <Widget>[
          (widget.model.items!.where((a) => a.checked == true).isNotEmpty)
              ? IconButton(
                onPressed: () {
                  controller.deleteItem(
                    context,
                    widget.model,
                    () => setState(() {}),
                  );
                },
                icon: const Icon(Icons.delete),
              )
              : Container(),
        ],
      ),
      body:
          widget.model.items!.isEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset("assets/naotemnada.png"),
                  ),
                  const Text(
                    "Não tem Produtos",
                    style: TextStyle(fontSize: 27),
                  ),
                ],
              )
              : ListView.builder(
                itemCount: widget.model.items!.length,
                itemBuilder: (context, index) {
                  items = widget.model.items!;
                  final item = widget.model.items![index];

                  return ListTile(
                    onTap: () {
                      setState(() {
                        item.checked = !item.checked;
                      });
                    },
                    onLongPress: () {
                      TextEditingController controller =
                          TextEditingController();
                      TextEditingController controllerqtd =
                          TextEditingController();
                      TextEditingController controllervalor =
                          TextEditingController();

                      controller.text = item.descricao!;
                      controllerqtd.text = item.quantidade.toString();
                      controllervalor.text = item.valor.toString();
                      alert
                          .bodyMessage(
                            context,
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
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
                                      decoration: const InputDecoration(
                                        labelText: 'Nome',
                                      ),
                                    ),
                                    TextField(
                                      controller: controllerqtd,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantidade',
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                    ),
                                    TextField(
                                      controller: controllervalor,
                                      decoration: const InputDecoration(
                                        labelText: 'Valor',
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
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
                                                    ItemModel item = ItemModel(
                                                      descricao:
                                                          controller.text,
                                                      quantidade: double.parse(
                                                        controllerqtd.text
                                                            .replaceAll(
                                                              ',',
                                                              '.',
                                                            ),
                                                      ),
                                                      valor: double.parse(
                                                        controllervalor.text
                                                            .replaceAll(
                                                              ',',
                                                              '.',
                                                            ),
                                                      ),
                                                    );
                                                    widget.model.items!.add(
                                                      item,
                                                    );
                                                    widget.model.update();

                                                    Navigator.of(context).pop();
                                                  });
                                                } else {
                                                  return;
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

                      /*  _edicaolista(item); */
                    },
                    leading: Checkbox(
                      value: item.checked,
                      onChanged: (bool? value) {
                        setState(() {
                          item.checked = value!;
                        });
                      },
                    ),
                    title: Text(
                      item.descricao!,
                      style: const TextStyle(fontSize: 25),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantidade ${item.quantidade} ${item.quantidade?.truncateToDouble() == item.quantidade ? 'UN' : 'KG'}',
                        ),
                        Text(
                          'Valor ${UtilBrasilFields.obterReal(item.valor!.toDouble())}',
                        ),
                        Text(
                          'Valor Total ${UtilBrasilFields.obterReal(item.getTotal())}',
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                for (var item in items) {
                  item.checked = !item.checked;
                }
              });
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.select_all, color: Colors.white),
          ),
          SizedBox(height: 15),
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              controller.addItem(context, widget.model, () => setState(() {}));
            },
          ),
        ],
      ),
    );
  }
}

