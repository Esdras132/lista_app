import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lista_de_compras/model/item.model.dart';


class ListaModel {
  DocumentReference? reference;
  String? descricao;
  List<ItemModel>? items;
  bool isEditting = false;

  getTotal() {
    if (items == null || items!.isEmpty) {
      return 0.0;
    }
    double total = items!
        .map((item) => item.valor!.toDouble() * item.quantidade!)
        .reduce((valorAtual, elemento) => valorAtual + elemento);

    return total;
  }

  ListaModel({this.descricao = '', this.items = const []});

  update() {
    reference!.update(toMap());
  }

  ListaModel.map(QueryDocumentSnapshot snapshot) {
    reference = snapshot.reference;
    descricao = snapshot.get('descricao');
    items =
        (snapshot.get('items') as List).map((e) => ItemModel.map(e)).toList();
  }

  toMap() {
    return {
      "descricao": descricao,
      "items": items!.map((e) => e.toMap()).toList()
    };
  }
}