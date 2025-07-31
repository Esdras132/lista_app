class ItensNameModel {
  String? descricao;
  double? quantidade = 0;
  bool checked = false;

  ItensNameModel({this.descricao = '', this.quantidade = 0.0});

    ItensNameModel.map(dynamic map) {
    descricao = map["descricao"];
    quantidade = map["quantidade"];
  }
  toMap() {
    return {
      "descricao": descricao,
      "quantidade": quantidade ,
    };
  }
}