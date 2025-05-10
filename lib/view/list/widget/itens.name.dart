import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/lista.name.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';

class ItemsNamePage extends StatefulWidget {
  final NameModel model;
  const ItemsNamePage({super.key, required this.model});

  @override
  State<ItemsNamePage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsNamePage> {
  List<ItensNameModel> itens = [];
  AlertController alert = AlertController();
  ListaNameController controller = ListaNameController();

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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " Qtd: ${widget.model.itensName!.length.toString()}",
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ],
        ),
        actions: <Widget>[
          (widget.model.itensName!.where((a) => a.checked == true).isNotEmpty)
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
          widget.model.itensName!.isEmpty
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
                itemCount: widget.model.itensName!.length,
                itemBuilder: (context, index) {
                  itens = widget.model.itensName!;
                  final item = widget.model.itensName![index];
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
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                for (var item in itens) {
                  item.checked = !item.checked;
                }
              });
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.select_all, color: Colors.white),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              controller.addItem(context, widget.model, () {
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }
}
