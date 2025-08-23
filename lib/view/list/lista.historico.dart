import 'package:flutter/material.dart';
import 'package:lista_de_compras/model/lista.model.dart';
import 'package:lista_de_compras/services/db.service.dart';
import 'items/lista.historico.dart';

class ListaHistorico extends StatefulWidget {
  const ListaHistorico({super.key});

  @override
  State<ListaHistorico> createState() => _ListaHistoricoState();
}

class _ListaHistoricoState extends State<ListaHistorico> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: DBServiceHistorico.fetchAll(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<HistoricoModel>> snapshot,
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

            // Ordena a lista inteira: mais novo primeiro
            var items = snapshot.data!..sort((a, b) => b.data!.compareTo(a.data!));

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];

                return TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HistoricoPage(model: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    item.descricao.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    formatarData(item.data!),
                                    
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              color: Colors.black,
                              icon: const Icon(Icons.folder_open),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => HistoricoPage(model: item),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
  String formatarData(DateTime data) {
  String dia = data.day.toString().padLeft(2, '0');
  String mes = data.month.toString().padLeft(2, '0');
  String ano = data.year.toString();
  return "$dia/$mes/$ano";
}

}
