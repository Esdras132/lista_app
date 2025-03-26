import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/model/name.item.model.dart';
import 'package:lista_de_compras/model/name.model.dart';

class ItemsNamePage extends StatefulWidget {
  final NameModel model;
  const ItemsNamePage({super.key, required this.model});

  @override
  State<ItemsNamePage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsNamePage> {
  final TextEditingController _items = TextEditingController();
  List<ItensNameModel> itens = [];
  final _formKey = GlobalKey<FormState>();
  AlertController alert = AlertController();

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
                  _showdeleteDialog();
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
                      _edicaolista(item);
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
              _items.text = '';
              alert
                  .bodyMessage(
                    context,
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              cursorColor: Colors.green,
                              autofocus: true,
                              controller: _items,
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
                              onEditingComplete: () {
                                if (!_formKey.currentState!.validate()) {
                                } else {
                                  setState(() {
                                    ItensNameModel item = ItensNameModel(
                                      descricao: _items.text,
                                    );
                                    widget.model.itensName!.add(item);
                                    widget.model.update();
                      
                                    _items.text = '';
                                    Navigator.of(context).pop();
                                  });
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
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            ItensNameModel item = ItensNameModel(
                                              descricao: _items.text,
                                            );
                                            widget.model.itensName!.add(item);
                                            widget.model.update();
                      
                                            _items.text = '';
                                            Navigator.of(context).pop();
                                          });
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
              /* _showAlertDialog(); */
            },
          ),
        ],
      ),
    );
  }

  /*   Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('itens para adicionar'),
          content:
          actions: <Widget>[
            TextButton(
              child: const Text('cancelar', selectionColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
                _items.text = '';
              },
            ),
            TextButton(
              child: const Text('adicionar', selectionColor: Colors.green),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                } else {
                  setState(() {

                  });
                }
              },
            ),
          ],
        );
      },
    );
  } */

  Future<void> _edicaolista(ItensNameModel model) async {
    TextEditingController controller = TextEditingController();

    controller.text = model.descricao!;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.text = '';
              },
            ),
            TextButton(
              child: const Text('Atualizar'),
              onPressed: () {
                model.descricao = controller.text;
                widget.model.update();
                Navigator.of(context).pop();

                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showdeleteDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletar'),
          content: const Text('Deseja Deletar todos os itens selecionados?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                for (var i = widget.model.itensName!.length - 1; i >= 0; i--) {
                  if (widget.model.itensName![i].checked) {
                    widget.model.itensName!.removeAt(i);
                  }
                }
                await widget.model.update();
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: const Text('deletar'),
            ),
          ],
        );
      },
    );
  }
}
