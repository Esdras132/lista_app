import 'package:Lista_de_compras/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static void createLista(ListaModel lista) {
    _firestore
        .collection('minhas-listas')
        .add(lista.toMap())
        .then((value) => print("Lista Adicionada"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  static Stream<List<ListaModel>> fetchAll() {
    return _firestore
        .collection('minhas-listas')
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((e) => ListaModel.map(e)).toList();
        });
  }
}

