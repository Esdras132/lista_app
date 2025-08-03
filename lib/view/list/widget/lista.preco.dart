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
  ListaPrecoController controller = ListaPrecoController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
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
                    style: TextStyle(fontSize: 27, color: Colors.white),
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
                      controller.editItem(
                        context,
                        widget.model,
                        item,
                        () => setState(() {}),
                      );
                    },
                    leading: Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: Checkbox(
                        value: item.checked,
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                        onChanged: (bool? value) {
                          setState(() {
                            item.checked = value!;
                          });
                        },
                      ),
                    ),
                    title: Text(
                      item.descricao!,
                      style: const TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantidade ${item.quantidade} ${item.quantidade?.truncateToDouble() == item.quantidade ? 'UN' : 'KG'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Valor ${UtilBrasilFields.obterReal(item.valor!.toDouble())}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Valor Total ${UtilBrasilFields.obterReal(item.getTotal())}',
                          style: const TextStyle(color: Colors.white),
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
