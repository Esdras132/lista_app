import 'package:flutter/material.dart';
import 'package:Lista_de_compras/services/model.dart';

class ItemsNamePage extends StatefulWidget {
  final NameModel model;
  const ItemsNamePage({Key? key, required this.model}) : super(key: key);

  @override
  State<ItemsNamePage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsNamePage> {
  TextEditingController _items = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.descricao!),
        actions: <Widget>[
          (widget.model.itensName!.where((a) => a.checked == true).isNotEmpty)
              ? IconButton(
                  onPressed: () {
                    _showdeleteDialog();
                  },
                  icon: const Icon(Icons.delete))
              : Container(),
        ],
      ),
      body: widget.model.itensName!.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    "assets/naotemnada.png",
                  ),
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
                return ListTile(
                  onTap: () {
                    setState(() {
                      widget.model.itensName![index].checked =
                          !widget.model.itensName![index].checked;
                    });
                  },
                  onLongPress: () {
                    _edicaolista(index);
                  },
                  leading: Checkbox(
                    value: widget.model.itensName![index].checked,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.model.itensName![index].checked = value!;
                      });
                    },
                  ),
                  title: Text(
                    widget.model.itensName![index].descricao!,
                    style: const TextStyle(fontSize: 25),
                  ),
                );
              },
            ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            _items.text = '';
            _showAlertDialog();
          },
        ),
      ]),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('itens para adicionar'),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextFormField(
              cursorColor: Colors.green,
              autofocus: true,
              controller: _items,
              decoration: const InputDecoration(labelText: 'Nome do item'),
              validator: (value) {
                if (!value!.contains('')) {
                  return 'Este campo é obrigatorio';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
          ]),
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
                if(_items.toString().isEmpty){
                  setState(() {
                  ItensNameModel item = ItensNameModel(descricao: _items.text);
                  widget.model.itensName!.add(item);
                  widget.model.update();

                  _items.text = '';
                  Navigator.of(context).pop();
                });
                }
                else{
                  _showEmptyFieldsDialog();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _edicaolista(int index) async {
    TextEditingController controller = TextEditingController();

    controller.text = widget.model.itensName![index].descricao!;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar'),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
          ]),
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
                  widget.model.itensName![index].descricao = controller.text;
                  widget.model.update();
                  Navigator.of(context).pop();

                  setState(() {});
                }),
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
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () async {
                  for (var i = widget.model.itensName!.length - 1;
                      i >= 0;
                      i--) {
                    if (widget.model.itensName![i].checked) {
                      widget.model.itensName!.removeAt(i);
                    }
                  }
                  await widget.model.update();
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text('deletar'))
          ],
        );
      },
    );
  }
    Future<void> _showEmptyFieldsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Para continuar é necessário o nome do item'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
