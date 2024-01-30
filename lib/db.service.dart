import 'package:Lista_de_compras/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    var uid = FirebaseAuth.instance.currentUser!.uid;
    if (uid.isNotEmpty){
      return _firestore
        .collection('users').doc(uid).collection("minhas-listas")
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
        .collection('users').doc(uid).collection("minhas-listas")
        .add(lista.toMap())
        .then((value) => print("Lista Adicionada"))
        .catchError((error) => print("Failed to add user: $error"));
    }
    
  }
}

