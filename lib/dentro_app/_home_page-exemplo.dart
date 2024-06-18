import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePageteste extends StatefulWidget {
  const HomePageteste({Key? key}) : super(key: key);

  @override
  State<HomePageteste> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageteste> with WidgetsBindingObserver {
  var lista = [];
  List<bool> checkedList = [];
  List<double> quantidades = [];
  List<double> valores = [];
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _quantidadeController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  int selectedIndex = -1;
  void _deleteAllItems() {
    setState(() {
      lista.clear();
      checkedList.clear();
      quantidades.clear();
      valores.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveData();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _saveData();
    }
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lista = (prefs.getStringList('lista') ?? [])
          .map((item) => json.decode(item))
          .toList();
      checkedList = prefs
              .getStringList('checkedList')
              ?.map((item) => item == 'true')
              .toList() ??
          [];
      quantidades = prefs
              .getStringList('quantidades')
              ?.map((item) => double.parse(item))
              .toList() ??
          [];
      valores = prefs
              .getStringList('valores')
              ?.map((item) => double.parse(item.replaceAll(',', '.')))
              .toList() ??
          [];
    });
  }

  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'lista', lista.map((item) => json.encode(item)).toList());
    prefs.setStringList(
        'checkedList', checkedList.map((item) => item.toString()).toList());
    prefs.setStringList(
        'quantidades', quantidades.map((item) => item.toString()).toList());
    prefs.setStringList(
        'valores', valores.map((item) => item.toString()).toList());
  }

  // Função para exibir o AlertDialog
  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item para Comprar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome do Item'),
              ),
              TextField(
                controller: _quantidadeController,
                decoration: InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: false),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                // Verifica se os campos são preenchidos
                if (_nomeController.text.isEmpty ||
                    _quantidadeController.text.isEmpty ||
                    _valorController.text.isEmpty) {
                  // Exibe uma mensagem de alerta se algum campo estiver vazio
                  _showEmptyFieldsDialog();
                } else {
                  // Verifica se há mais de duas vírgulas ou dois pontos nos campos
                  if (_quantidadeController.text
                      .contains(RegExp(r'[.,].*[.,]')) ||
                      _valorController.text.contains(RegExp(r'[.,].*[.,]'))) {
                    _showInvalidInputAlert();
                    return;
                  }

                  // Adiciona o item à lista se todos os campos estiverem preenchidos
                  setState(() {
                    lista.add(_nomeController.text);
                    quantidades.add(double.parse(
                        _quantidadeController.text.replaceAll(',', '.')));
                    valores.add(double.parse(
                        _valorController.text.replaceAll(',', '.')));
                    checkedList.add(false);

                    // Limpa os campos após adicionar à lista
                    _nomeController.text = '';
                    _quantidadeController.text = '';
                    _valorController.text = '';

                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showInvalidInputAlert() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
            'Os campos de valor ou quantidade não podem conter mais de duas vírgulas ou dois pontos.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEmptyFieldsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Todos os campos são obrigatórios.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Função para exibir o EditDialog
  Future<void> _showEditDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome do Item'),
              ),
              TextField(
                controller: _quantidadeController,
                decoration: InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: false),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Atualizar'),
              onPressed: () {
                setState(() {
                  lista[selectedIndex] = _nomeController.text;
                  quantidades[selectedIndex] = double.parse(
                      _quantidadeController.text.replaceAll(',', '.'));
                  valores[selectedIndex] =
                      double.parse(_valorController.text.replaceAll(',', '.'));
                  selectedIndex = -1;
                  _nomeController.text = '';
                  _quantidadeController.text = '';
                  _valorController.text = '';
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Função para exibir um AlertDialog de confirmação
  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content:
              const Text('Deseja realmente excluir os itens selecionados?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                _deleteSelectedItems();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showitemDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Não tem itens selecionados'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Função para exibir um AlertDialog indicando que itens precisam ser selecionados
  Future<void> _showSelectionRequiredDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Para excluir, selecione os itens desejados.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialogAll() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente excluir todas as listas?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                _deleteAllItems();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNoItemsToDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Não há nenhum item na sua lista.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Função para deletar os itens selecionados
  void _deleteSelectedItems() {
    setState(() {
      int i = checkedList.length - 1;
      while (i >= 0) {
        if (checkedList[i]) {
          lista.removeAt(i);
          checkedList.removeAt(i);
          quantidades.removeAt(i);
          valores.removeAt(i);
        }
        i--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalGeral = 0;
    for (var i = 0; i < lista.length; i++) {
      totalGeral += quantidades[i] * valores[i];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quantidade de Itens: ${lista.length}",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              "Total Geral: ${UtilBrasilFields.obterReal(totalGeral)}",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        centerTitle: false,
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: 110, left: 33),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (checkedList.any((element) => element == true)) {
                  _showConfirmationDialog();
                } else {
                  _showSelectionRequiredDialog();
                }
              },
              child: Icon(Icons.delete, color: Colors.white),
              backgroundColor: Colors.green,
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                if (lista.isEmpty) {
                  _showNoItemsToDeleteDialog();
                } else {
                  _showConfirmationDialogAll();
                }
              },
              child: Icon(Icons.delete_forever, color: Colors.white),
              backgroundColor: Colors.red,
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                _showAlertDialog();
                _nomeController.text = '';
                _quantidadeController.text = '';
                _valorController.text = '';
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, i) {
                if (checkedList.length <= i) {
                  checkedList.add(false);
                  quantidades.add(0);
                  valores.add(0);
                }
                double total = quantidades[i] * valores[i];
                return ListTile(
                  title: Text(
                    lista[i].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 25),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Quantidade: ${(quantidades[i].truncateToDouble() == quantidades[i]) ? quantidades[i].toInt() : quantidades[i].toString().replaceAll('.', ',')} ${(quantidades[i].truncateToDouble() == quantidades[i]) ? 'UN' : 'KG'}'),
                      Text('Valor: ${UtilBrasilFields.obterReal(valores[i])}'),
                      Text(
                          'Total: ${UtilBrasilFields.obterReal(total)}') // Limitar o total a duas casas decimais
                    ],
                  ),
                  onLongPress: () {
                    _showEditDialog();
                  },
                  leading: Theme(
                    data: ThemeData(
                      checkboxTheme: CheckboxThemeData(
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return null;
                          }
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green;
                          }
                          return null;
                        }),
                      ),
                    ),
                    child: Checkbox(
                      value: checkedList[i],
                      onChanged: (bool? value) {
                        setState(() {
                          checkedList[i] = value!;
                        });
                      },
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        selectedIndex = i;
                        _nomeController.text = lista[i];
                        _quantidadeController.text = quantidades[i].toString();
                        _valorController.text = valores[i].toString();
                      });
                      _showEditDialog();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
