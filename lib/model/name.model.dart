import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lista_de_compras/model/name.item.model.dart';


class ListaModel {
  DocumentReference? reference;
  String? descricao;
  bool? personalizada;
  List<ItensListaModel>? itensName;

  ListaModel({this.descricao = '', this.personalizada = false, this.itensName = const []});

  ListaModel.map(QueryDocumentSnapshot snapshot) {
    reference = snapshot.reference;
    descricao = snapshot.get('descricao');
    personalizada = snapshot.get('personalizada');
    itensName = (snapshot.get('items') as List)
        .map((e) => ItensListaModel.map(e))
        .toList();
  }
  toMap() {
    return {
      "descricao": descricao,
      "personalizada": personalizada,
      "items": itensName!.map((e) => e.toMap()).toList()
    };
  }


    update() {
    reference!.update(toMap());
  }
}


