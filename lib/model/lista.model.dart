import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lista_de_compras/model/item.model.dart';


class HistoricoModel {
  DocumentReference? reference;
  String? descricao;
  DateTime? data = DateTime.now();
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

  HistoricoModel({this.descricao = '', this.data, this.items = const []});

  update() {
    reference!.update(toMap());
  }

  HistoricoModel.map(QueryDocumentSnapshot snapshot) {
    reference = snapshot.reference;
    descricao = snapshot.get('descricao');
    data = (snapshot.get('data') as Timestamp).toDate();
    items =
        (snapshot.get('items') as List).map((e) => ItemModel.map(e)).toList();
  }

  toMap() {
    return {
      "descricao": descricao,
      "data": data,
      "items": items!.map((e) => e.toMap()).toList()
    };
  }
}