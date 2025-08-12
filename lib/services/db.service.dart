
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lista_de_compras/model/lista.model.dart';
import 'package:lista_de_compras/model/name.model.dart';

class DBserviceCom {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static void createLista(ListaModel lista) {
    _firestore
        .collection('minhas-listas')
        .add(lista.toMap())
        .then((value) => print("Lista Adicionada"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  static Stream<List<ListaModel>>  fetchAll() {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      return _firestore
        .collection('users').doc(uid).collection("Listas com Preco")
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((e) => ListaModel.map(e)).toList();
        });
    }else{
      return const Stream.empty();
    }
    
  }
  
  static void createMyList(ListaModel lista) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      _firestore
        .collection('users').doc(uid).collection("Listas com Preco")
        .add(lista.toMap())
        .then((value) => print("Lista Adicionada"))
        .catchError((error) => print("Failed to add user: $error"));
    }
    
  }
}

class DBserviceListaPersonalizada {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static fetchAll() {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      return _firestore
        .collection('users').doc(uid).collection("Listas Personalizadas")
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((e) => NameModel.map(e)).toList();
        });
    }else{
      return const Stream.empty();
    }
    
  }

  static Future<void> deleteMyList() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      try {
        var collectionRef = _firestore
          .collection('users').doc(uid).collection("Listas Personalizadas");
        var snapshots = await collectionRef.get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
        print("Lista Deleted");
      } catch (error) {
        print("Failed to delete lista: $error");
      }
    }
  }


  
  static void createMyList(NameModel lista) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      _firestore
        .collection('users').doc(uid).collection("Listas Personalizadas")
        .add(lista.toMap())
        .then((value) => print("Lista Adicionada"))
        .catchError((error) => print("Failed to add user: $error"));
    }
    
  }
}

class DBserviceSem {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<NameModel>>  fetchAll() {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      return _firestore
        .collection('users').doc(uid).collection("Listas sem Preco")
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((e) => NameModel.map(e)).toList();
        });
    }else{
      return const Stream.empty();
    }
    
  }

    static Future<void> deleteMyList() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      try {
        var collectionRef = _firestore
          .collection('users').doc(uid).collection("Listas sem Preco");
        var snapshots = await collectionRef.get();
        for (var doc in snapshots.docs) {
          if (doc.get("personalizada") == true) {
            await doc.reference.delete();
          }
        }
        print("Lista Deleted");
      } catch (error) {
        print("Failed to delete lista: $error");
      }
    }
  }
  
  static void createMyList(NameModel lista) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      _firestore
        .collection('users').doc(uid).collection("Listas sem Preco")
        .add(lista.toMap())
        .then((value) => print("Lista Adicionada"))
        .catchError((error) => print("Failed to add user: $error"));
    }
    
  }
}