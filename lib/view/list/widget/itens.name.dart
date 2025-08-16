import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/controller/lista.name.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/view/list/shopping/shopping.dart';

class ItemsNamePage extends StatefulWidget {
  final ListaModel model;
  const ItemsNamePage({super.key, required this.model});

  @override
  State<ItemsNamePage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<ItemsNamePage> {
  List<ItensListaModel> itens = [];
  AlertController alert = AlertController();
  ListaNameController controller = ListaNameController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        elevation: 8,
        shadowColor: Colors.black87,
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
              : IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ShoppingPage(model: widget.model, refresh: () => setState(() {}),)),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
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
                    style: TextStyle(fontSize: 27, color: Colors.white),
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
