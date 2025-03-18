import 'package:flutter/material.dart';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:lista_de_compras/model/item.model.dart';
import 'package:lista_de_compras/model/lista.model.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, required this.model});

  final ListaModel model;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final TextEditingController _items = TextEditingController();
  final TextEditingController _quantidade = TextEditingController(text: '0' );
  final TextEditingController _valor = TextEditingController(text: '0');
  List<ItemModel> items = [];
  final _formKey = GlobalKey<FormState>();

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
              '${widget.model.descricao!.length > 20 ? '${widget.model.descricao!.substring(0, 20)}...' : widget.model.descricao!} ',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "${UtilBrasilFields.obterReal(widget.model.getTotal())} Qtd: ${widget.model.items!.length.toString()}",
              // "Valor ${UtilBrasilFields.obterReal(widget.model.getTotal())} Qtd: ${widget.model.items!.length.toString()}",
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
        actions: <Widget>[
          (widget.model.items!.where((a) => a.checked == true).isNotEmpty)
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
                      _edicaolista(widget.model.items![index]);
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
            child: const Icon(Icons.select_all),
          ),
          SizedBox(height: 15),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _quantidade.text = '';
              _valor.text = '';
              _items.text = '';
              _showAlertDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  cursorColor: Colors.green,
                  autofocus: true,
                  controller: _items,
                  decoration: const InputDecoration(labelText: 'Nome do item'),
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
                  controller: _quantidade,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  /*                 validator: (value) {
                    if (value!.isEmpty) {
                      return 'Este campo é obrigatorio';
                    }
                    return null;
                  }, */
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  cursorColor: Colors.green,
                  controller: _valor,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  /*                 validator: (value) {
                    if (value!.isEmpty) {
                      return 'Este campo é obrigatorio';
                    }
                    return null;
                  }, */
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        ItemModel item = ItemModel(
                          descricao: _items.text,
                          quantidade: _quantidade.text.isEmpty ? double.parse("0") :
                          double.parse(
                            _quantidade.text.replaceAll(',', '.'),
                          ),
                          valor: _valor.text.isEmpty
                          ? double.parse("0") : double.parse(_valor.text.replaceAll(',', '.')),
                        );
                        widget.model.items!.add(item);
                        widget.model.update();
                        _valor.text = '';
                        _quantidade.text = '';
                        _items.text = '';
                        Navigator.of(context).pop();
                      });
                    }else{
                      return;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.green,
                shape: CircleBorder(),
              ),
              child: IconButton(
                color: Colors.white,
                onPressed: () {
                  if (_quantidade.text.isNotEmpty || _valor.text.isNotEmpty) {
                    _valor.text = '';
                    _quantidade.text = '';
                    FocusScope.of(context).requestFocus(FocusNode());
                  } else {
                  }
                },
                icon: const Icon(Icons.clear_sharp),
              ),
            ),
            TextButton(
              child: const Text('cancelar', selectionColor: Colors.green),
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
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        ItemModel item = ItemModel(
                          descricao: _items.text,
                          quantidade: _quantidade.text.isEmpty ? double.parse("0") :
                          double.parse(
                            _quantidade.text.replaceAll(',', '.'),
                          ),
                          valor: _valor.text.isEmpty
                          ? double.parse("0") : double.parse(_valor.text.replaceAll(',', '.')),
                        );
                        widget.model.items!.add(item);
                        widget.model.update();
                        _valor.text = '';
                        _quantidade.text = '';
                        _items.text = '';
                        Navigator.of(context).pop();
                      });
                    }else{
                      return;
                    }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _edicaolista(ItemModel model) async {
    TextEditingController controller = TextEditingController();
    TextEditingController controllerqtd = TextEditingController();
    TextEditingController controllervalor = TextEditingController();

    controller.text = model.descricao!;
    controllerqtd.text = model.quantidade.toString();
    controllervalor.text = model.valor.toString();

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
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                controllerqtd.text = '';
                controllervalor.text = '';
              },
              child: const Text('limpar'),
            ),
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
                      model.valor = double.parse(controllervalor.text);
                      model.quantidade = double.parse(controllerqtd.text);
                      model.descricao = controller.text;
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
              child: const Text('Cancelar'),
            ),
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
              child: const Text('deletar'),
            ),
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
