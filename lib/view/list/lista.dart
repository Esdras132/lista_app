import 'package:flutter/material.dart';
import 'package:lista_de_compras/controller/alert.controller.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:lista_de_compras/model/name.model.dart';
import 'package:lista_de_compras/view/list/shopping/shopping.dart';

import 'items/itens.lista.dart';

class Lista extends StatefulWidget {
  const Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  AlertController alertController = AlertController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: DBServiceLista.fetchAll(),
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
                  const Text("Não tem listas", style: TextStyle(fontSize: 27)),
                ],
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                TextEditingController controller = TextEditingController(
                  text: snapshot.data![i].descricao,
                );

                return Dismissible(
                  key: UniqueKey(),

                  background: Container(
                    color: Colors.green,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.shopping_cart, color: Colors.white),
                      ),
                    ),
                  ),

                  secondaryBackground: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),

                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ShoppingPage(
                                model: snapshot.data![i],
                                refresh: () => setState(() {}),
                              ),
                        ),
                      );
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      alertController
                          .confirmDialog(
                            context,
                            bodyMessage: 'Deseja excluir a lista?',
                            btnOk: () {
                              snapshot.data![i].reference!.delete();
                            },
                            btnCancel: () {},
                          )
                          .show();
                    }
                    return false;
                  },

                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      snapshot.data![i].descricao.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    onLongPress: () {
    final formKey = GlobalKey<FormState>();
                      alertController
                          .bodyMessage(
                            context,
                            btnTitle: 'Editar',

                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome da lista',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, insira um nome';
                                        }
                                        return null;
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
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  snapshot.data![i].reference!
                                                      .update({
                                                        "descricao":
                                                            controller.text,
                                                      });
                                                  Navigator.of(context).pop();
                                                } else {
                                                  return;
                                                }
                                              },
                                              child: Text(
                                                'Salvar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
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
                    },

                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ItemsListaPage(model: snapshot.data![i]),
                        ),
                      );
                    },
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
    );
  }
}
