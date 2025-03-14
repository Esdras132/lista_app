import 'package:lista_de_compras/dentro_app/items_page.dart';
import 'package:lista_de_compras/dentro_app/itens_name.page.dart';
import 'package:lista_de_compras/dentro_app/pessoais/configuracoes.dart';
import 'package:lista_de_compras/dentro_app/pessoais/conta.dart';
import 'package:lista_de_compras/services/Lista.model.dart';
import 'package:lista_de_compras/services/item.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:flutter/widgets.dart';

class ListaComprasPage extends StatefulWidget {
  const ListaComprasPage({super.key});

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  String? verNome;
  var lista = [];
  TextEditingController _nomeController = TextEditingController();
  var checkedList = [];

  @override
  void initState() {
    super.initState();
    Name();
  }

  Future<void> Name() async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    setState(() {
      verNome = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Exit App'),
                  content: Text('Você deseja sair do app?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Não'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Sim'),
                    ),
                  ],
                ),
          ) ??
          false;
    }

    // ignore: deprecated_member_use
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Bem vindo ${verNome!}'),
            bottom: TabBar(
              tabs: [Tab(text: "Com preço"), Tab(text: "Sem preço")],
            ),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Text('Conta'),
                          SizedBox(width: 65),
                          Icon(Icons.account_circle_outlined),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Text("Configurações"),
                          SizedBox(width: 10),
                          Icon(Icons.settings),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Text(
                            "Desconectar",
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(width: 26),
                          Icon(Icons.logout, color: Colors.red),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Conta()),
                    );
                    print("My account menu is selected.");
                  } else if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Config()),
                    );
                    print("Settings menu is selected.");
                  } else if (value == 2) {
                    print("Logout menu is selected.");
                    _sair();
                  }
                },
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject()
                          as RenderBox;
                  final Offset buttonPosition = button.localToGlobal(
                    Offset.zero,
                    ancestor: overlay,
                  );
                  final RelativeRect position = RelativeRect.fromLTRB(
                    buttonPosition.dx,
                    buttonPosition.dy -
                        115, // Ajuste o valor conforme necessário
                    buttonPosition.dx + button.size.width,
                    buttonPosition.dy + button.size.height - 100,
                  );

                  showMenu(
                    context: context,
                    position: position,
                    items: <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap: () => _showAlertDialogCom(),
                        child: Text('Lista com preço'),
                      ),
                      PopupMenuItem<String>(
                        onTap: () => _showAlertDialogSem(),
                        child: Text('Lista sem preço'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          body: TabBarView(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    Name();
                  });
                },
                child: Container(
                  child: StreamBuilder(
                    stream: DBserviceCom.fetchAll(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<ListaModel>> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset("assets/naotemnada.png"),
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
                                TextEditingController(
                                  text: snapshot.data![i].descricao,
                                );
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
                              /*                       secondaryBackground: Container(
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
                        ), */
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  snapshot.data![i].reference!.delete();
                                } /* else if (direction == DismissDirection.startToEnd) {
                            snapshot.data![i].reference!.delete();
                          } */
                              },
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              ItemsPage(model: snapshot.data![i]),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                          width: 1.0,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        color: Colors.black,
                                        icon: const Icon(Icons.folder_open),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ItemsPage(
                                                    model: snapshot.data![i],
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    onSubmitted: (String value) {
                                      snapshot.data![i].reference!.update({
                                        "descricao": controller.text,
                                      });
                                    },
                                  ),
                                ),
                              ),
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
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                child: StreamBuilder(
                  stream: DBserviceSem.fetchAll(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<NameModel>> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset("assets/naotemnada.png"),
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
                              TextEditingController(
                                text: snapshot.data![i].descricao,
                              );
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
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                snapshot.data![i].reference!.delete();
                              }
                            },
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ItemsNamePage(
                                          model: snapshot.data![i],
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: controller,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 1.0,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      color: Colors.black,
                                      icon: const Icon(Icons.folder_open),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ItemsNamePage(
                                                  model: snapshot.data![i],
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  onSubmitted: (String value) {
                                    snapshot.data![i].reference!.update({
                                      "descricao": controller.text,
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _editar() async {
  //   TextEditingController controller = TextEditingController();
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(title: const Text('Editar'), actions: <Widget>[
  //           TextField(
  //             controller: controller,
  //             decoration: const InputDecoration(labelText: 'Nome'),
  //           ),
  //           TextButton(
  //             child: const Text('Editar'),
  //             onPressed: () {
  //               if (controller.text == '') {
  //                 _showEmptyFieldsDialog();
  //               } else {

  //               }
  //               setState(() {});
  //             },
  //           ),
  //         ]);
  //       });
  // }

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
          content: const Text(
            'Não pode usar . nem , obrigado pela compreenção',
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

  Future<void> _showAlertDialogSem() async {
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
                      NameModel model = NameModel(
                        descricao: _nomeController.text,
                        itensName: [],
                      );
                      DBserviceSem.createMyList(model);
                      _nomeController.text = '';
                      Navigator.pop(context);
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlertDialogCom() async {
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
                        descricao: _nomeController.text,
                        items: [],
                      );
                      DBserviceCom.createMyList(model);
                      _nomeController.text = '';
                      Navigator.pop(context);
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sair() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Você deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Não'),
            ),
            TextButton(
              child: const Text('sim'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
