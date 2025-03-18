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