import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceProvider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final _list = [];
  final _docList = [];

  get list => _list;

  get docList => _docList;

  Future<void> fetchData() async {
    await _firebaseFirestore.collection("Persons").get().then((value) {
      _list.clear();
      for (var doc in value.docs) {
        _docList.add(doc.id);
        _list.add(doc.data());
      }
      log(list.toString());
    });
    notifyListeners();
  }

  Future<void> addData(data) async {
    await _firebaseFirestore
        .collection("Persons")
        .add(data)
        .then((value) {
      fetchData();
    });
    notifyListeners();
  }
  Future<void> updateData(docId, data) async {
    await _firebaseFirestore
        .collection("Persons")
        .doc(docId)
        .update(data)
        .then((value) {
      fetchData();
    });
    notifyListeners();
  }

  Future<void> deleteData(docId) async {
    await _firebaseFirestore
        .collection("Persons")
        .doc(docId)
        .delete()
        .then((value) {
      fetchData();
    });
    notifyListeners();
  }
}
