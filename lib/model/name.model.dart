import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lista_de_compras/model/name.item.model.dart';


class NameModel {
  DocumentReference? reference;
  String? descricao;
  bool? personalizada;
  List<ItensNameModel>? itensName;

  NameModel({this.descricao = '', this.personalizada = false, this.itensName = const []});

  NameModel.map(QueryDocumentSnapshot snapshot) {
    reference = snapshot.reference;
    descricao = snapshot.get('descricao');
    personalizada = snapshot.get('personalizada');
    itensName = (snapshot.get('items') as List)
        .map((e) => ItensNameModel.map(e))
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


