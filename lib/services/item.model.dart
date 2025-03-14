import 'package:cloud_firestore/cloud_firestore.dart';


class ItemModel {
  String? descricao;
  bool checked = false;
  double? quantidade;
  double? valor;

  ItemModel({this.descricao = '', this.quantidade = 0.0, this.valor = 0.0});

  getTotal() {
    return quantidade! * valor!;
  }

  getRegra() {
    if (getTotal().toString().length > 15) {
      return getTotal().toString().substring(0, 15);
    } else {
      return getTotal();
    }
  }

  ItemModel.map(dynamic map) {
    descricao = map["descricao"];
    quantidade = map["quantidade"];
    valor = map["valor"];
  }

  toMap() {
    return {
      "descricao": descricao,
      "valor": valor,
      "quantidade": quantidade,
    };
  }
}



//name
class NameModel {
  DocumentReference? reference;
  String? descricao;
  List<ItensNameModel>? itensName;

  NameModel({this.descricao = '', this.itensName = const []});

  NameModel.map(QueryDocumentSnapshot snapshot) {
    reference = snapshot.reference;
    descricao = snapshot.get('descricao');
    itensName = (snapshot.get('items') as List)
        .map((e) => ItensNameModel.map(e))
        .toList();
  }
  toMap() {
    return {
      "descricao": descricao,
      "items": itensName!.map((e) => e.toMap()).toList()
    };
  }
    update() {
    reference!.update(toMap());
  }
}

class ItensNameModel {
  String? descricao;
  bool checked = false;

  ItensNameModel({this.descricao = ''});

    ItensNameModel.map(dynamic map) {
    descricao = map["descricao"];
  }
  toMap() {
    return {
      "descricao": descricao,
    };
  }
}
