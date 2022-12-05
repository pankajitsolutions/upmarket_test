import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:upmarket_test/res/utils.dart';
import 'package:upmarket_test/view/add_screen.dart';
import 'package:upmarket_test/view/edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final _list = [];
  final _docList = [];

  get list => _list;

  get docList => _docList;

  fetchData() {
    _firebaseFirestore.collection("Persons").get().then((value) {
      _list.clear();
      for (var doc in value.docs) {
        _docList.add(doc.id);
        _list.add(doc.data());
        setState(() {});
      }
      log(list.toString());
    });
  }

  deleteData(docId) {
    _firebaseFirestore.collection("Persons").doc(docId).delete();
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: list.isNotEmpty
          ? ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: myOutlineBoxDecoration(Colors.blue),
                  child: GestureDetector(
                    onHorizontalDragStart: (start) {
                      log("Start");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => EditScreen(
                                    docId: docList[index],
                                  )));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(list[index]["image"]),
                      ),
                      title: Text(list[index]["name"]),
                      trailing: IconButton(
                        onPressed: () {
                          log("End");
                          deleteData(docList[index]);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  ),
                );
              })
          : Center(
              child: Text("No Data"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
