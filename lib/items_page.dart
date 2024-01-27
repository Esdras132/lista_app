import 'package:flutter/material.dart';
import 'package:Lista_de_compras/model.dart';
import 'package:brasil_fields/brasil_fields.dart';

class ItemsPage extends StatefulWidget {
  final ListaModel model;
  const ItemsPage({Key? key, required this.model}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  TextEditingController _items = TextEditingController();
  TextEditingController _quantidade = TextEditingController();
  TextEditingController _valor = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '   ${widget.model.descricao!.length > 25 ? '${widget.model.descricao!.substring(0, 25)}...' : widget.model.descricao!} ',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
                "Valor ${UtilBrasilFields.obterReal(widget.model.getTotal())} Quantidade ${widget.model.items!.length.toString()}",
                style: const TextStyle(fontSize: 17)),
          ],
        ),
        actions: <Widget>[
          (widget.model.items!.where((a) => a.checked == true).isNotEmpty)
              ? IconButton(
                  onPressed: () {
                    _showdeleteDialog();
                  },
                  icon: const Icon(Icons.delete))
              : Container(),
        ],
      ),
      body: widget.model.items!.isEmpty
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
              itemCount: widget.model.items!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      widget.model.items![index].checked =
                          !widget.model.items![index].checked;
                    });
                  },
                  onLongPress: () {
                    _edicaolista(index);
                  },
                  leading: Checkbox(
                    value: widget.model.items![index].checked,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.model.items![index].checked = value!;
                      });
                    },
                  ),
                  title: Text(
                    widget.model.items![index].descricao!,
                    style: const TextStyle(fontSize: 25),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Quantidade ${widget.model.items![index].quantidade} ${widget.model.items![index].quantidade?.truncateToDouble() == widget.model.items![index].quantidade ? 'UN' : 'KG'}'),
                      Text(
                          'Valor ${UtilBrasilFields.obterReal(widget.model.items![index].valor!)}'),
                      Text(
                          'Valor Total ${UtilBrasilFields.obterReal(widget.model.items![index].getTotal())}')
                    ],
                  ),
                );
              },
            ),
      floatingActionButton:
          Row(
        mainAxisAlignment: MainAxisAlignment.end, 
        children: [
        FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
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
          content: Column(mainAxisSize: MainAxisSize.min, 
          children: <Widget>[
            TextField(
              cursorColor: Colors.green,
              autofocus: true,
              controller: _items,
              decoration: const InputDecoration(labelText: 'Nome do item'),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              cursorColor: Colors.green,
              controller: _quantidade,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              cursorColor: Colors.green,
              controller: _valor,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
                textInputAction: TextInputAction.done,
            )
          ]),
          actions: <Widget>[
            IconButton(
             onPressed: () {
               _valor.text = '';
               _quantidade.text = '';
             },
             icon: const Icon(Icons.clear_sharp, color: Colors.green)
             ),
            TextButton(
              child: const Text('cancelar',selectionColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
                _valor.text = '';
                _quantidade.text = '';
                _items.text = '';
              },
            ),
            TextButton(
              child: const Text('adicionar', selectionColor: Colors.green),
              onPressed: () {
                if (_items.text.isEmpty) {
                  _showEmptyFieldsDialog();
                } else {
                  if (_valor.text.isEmpty) {
                    _valor.text = '0.0';
                  } else {
                    if (_quantidade.text.isEmpty || _valor.text.isEmpty) {
                      _quantidade.text = '0.0';
                      _valor.text = '0.0';
                    } else {
                      setState(() {
                        ItemModel item = ItemModel(
                            descricao: _items.text,
                            quantidade: double.parse(
                                _quantidade.text.replaceAll(',', '.')),
                            valor:
                                double.parse(_valor.text.replaceAll(',', '.')));
                        widget.model.items!.add(item);
                        widget.model.update();
                        _valor.text = '';
                        _quantidade.text = '';
                        _items.text = '';
                        Navigator.of(context).pop();
                      });
                    }
                  }
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
    TextEditingController controllerqtd = TextEditingController();
    TextEditingController controllervalor = TextEditingController();

    controller.text = widget.model.items![index].descricao!;
    controllerqtd.text = widget.model.items![index].quantidade.toString();
    controllervalor.text = widget.model.items![index].valor.toString();

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
            TextField(
              controller: controllerqtd,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: controllervalor,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
            ),
          ]),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  controllerqtd.text = '';
                  controllervalor.text = '';
                },
                child: const Text('limpar')),
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
                if (controller.text.isEmpty) {
                  _showEmptyFieldsDialog();
                } else {
                  if (controllervalor.text.isEmpty) {
                    controllervalor.text = '0';
                  } else {
                    if (controllervalor.text.isEmpty ||
                        controllerqtd.text.isEmpty) {
                      controllerqtd.text = '0';
                      controllervalor.text = '0';
                    } else {
                      widget.model.items![index].valor =
                          double.parse(controllervalor.text);
                      widget.model.items![index].quantidade =
                          double.parse(controllerqtd.text);
                      widget.model.items![index].descricao = controller.text;
                      widget.model.update();
                      Navigator.of(context).pop();
                    }
                  }
                }
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
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () async {
                  for (var i = widget.model.items!.length - 1; i >= 0; i--) {
                    if (widget.model.items![i].checked) {
                      widget.model.items!.removeAt(i);
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
          content: const Text('Precisa ter Pelomenos o Nome'),
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
