import 'package:Lista_de_compras/items_page.dart';
import 'package:Lista_de_compras/model.dart';
import 'package:flutter/material.dart';
import 'package:Lista_de_compras/db.service.dart';

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  var lista = [];
  TextEditingController _nomeController = TextEditingController();
  var checkedList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAlertDialog();
        },
      ),
      body: StreamBuilder(
        stream: DBService.fetchAll(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ListaModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          "assets/naotemnada.png",
                        ),
                      ),
                      const Text(
                        "Não tem listas",
                        style: TextStyle(fontSize: 27),
                      ),
                    ],
                  );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                TextEditingController controller =
                    TextEditingController(text: snapshot.data![i].descricao);
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      snapshot.data![i].reference!.delete();
                    } else if (direction == DismissDirection.startToEnd) {
                      snapshot.data![i].reference!.delete();
                    }
                  },
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ItemsPage(
                                  model: snapshot.data![i],
                                )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                            icon: const Icon(Icons.folder_open),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ItemsPage(
                                        model: snapshot.data![i],
                                      )));
                            },
                          )),
                          onSubmitted: (String value) {
                            snapshot.data![i].reference!
                                .update({"descricao": controller.text});
                          },
                        ),
                      )),
                );
              },
            );
          } else if (snapshot.hasError) {
            // Tratar erro, se necessário
            return Text('Erro: ${snapshot.error}');
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.green,
              backgroundColor: Colors.grey,
            ));
          }
        },
      ),
    );
  }

  Future<void> _showEmptyFieldsDialog() async {
    return showDialog<void>(
      context: context,
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

  Future<void> _showInvalidInputAlert() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content:
              const Text('Não pode usar . nem , obrigado pela compreenção'),
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

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item para Comprar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                autofocus: true,
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Item'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                _nomeController.text = '';
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (_nomeController.text.isEmpty) {
                  _showEmptyFieldsDialog();
                } else {
                  if (_nomeController.text.contains(RegExp(r'[.,].*[.,]'))) {
                    _showInvalidInputAlert();
                  } else {
                    setState(() {
                      ListaModel model = ListaModel(
                          descricao: _nomeController.text, items: []);
                      DBService.createLista(model);
                      _nomeController.text = '';
                      Navigator.pop(context);
                    });
                  }
                  // Verifica se há mais de duas vírgulas ou dois pontos nos campos
                  // Adiciona o item à lista se todos os campos estiverem preenchidos
                }
              },
            ),
          ],
        );
      },
    );
  }
}
