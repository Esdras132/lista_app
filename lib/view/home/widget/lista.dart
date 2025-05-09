import 'package:flutter/material.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'package:lista_de_compras/model/name.model.dart';


import '../../itens_name.page.dart';

class Lista extends StatefulWidget {
  const Lista({super.key});

  @override
  State<Lista> createState() => _ListaState();
}

class _ListaState extends State<Lista> {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
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
    );
  }
}