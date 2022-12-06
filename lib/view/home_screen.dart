import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upmarket_test/provider/service_provider.dart';
import 'package:upmarket_test/res/utils.dart';
import 'package:upmarket_test/view/add_screen.dart';
import 'package:upmarket_test/view/auth_screen.dart';
import 'package:upmarket_test/view/edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ServiceProvider _serviceProvider;

  @override
  void initState() {
    _serviceProvider = Provider.of(context, listen: false);
    _serviceProvider.fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _serviceProvider = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LogInScreen()));
                });
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _serviceProvider.list.isNotEmpty
          ? ListView.builder(
              itemCount: _serviceProvider.list.length,
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
                                    docId: _serviceProvider.docList[index],
                                    data: {
                                      "image": _serviceProvider.list[index]
                                          ["image"],
                                      "name": _serviceProvider.list[index]
                                          ["name"]
                                    },
                                  )));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(_serviceProvider.list[index]["image"]),
                      ),
                      title: Text(_serviceProvider.list[index]["name"]),
                      trailing: SizedBox(
                        width: width(context) * 0.27,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => EditScreen(
                                              docId: _serviceProvider
                                                  .docList[index],
                                              data: {
                                                "image": _serviceProvider
                                                    .list[index]["image"],
                                                "name": _serviceProvider
                                                    .list[index]["name"]
                                              },
                                            )));
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _serviceProvider.deleteData(
                                    _serviceProvider.docList[index]);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
          : const Center(
              child: Text("No Data"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
