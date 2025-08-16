class ItensListaModel {
  String? descricao;
  double? quantidade = 0;
  bool checked = false;


  ItensListaModel({this.descricao = '', this.quantidade = 0.0});

    ItensListaModel.map(dynamic map) {
    descricao = map["descricao"];
    quantidade = map["quantidade"];
  }
  toMap() {
    return {
      "descricao": descricao,
      "quantidade": quantidade,
    };
  }
}