
class ItemModel {
  String? descricao;
  bool checked = false;
  double? quantidade = 0;
  double? valor = 0;

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
      "valor": valor?? 0,
      "quantidade": quantidade??0,
    };
  }
}



