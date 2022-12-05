import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upmarket_test/res/utils.dart';

class EditScreen extends StatefulWidget {
  final String docId;

  const EditScreen({Key? key, required this.docId}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _nameController = TextEditingController();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  ImagePicker imagePicker = ImagePicker();
  File? file;
  late String imageUrl;

  Future pickImageCamera() async {
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  Future<void> uploadProfileImage() async {
    Reference reference =
        FirebaseStorage.instance.ref().child('Images/${(file!.path)}');
    UploadTask uploadTask = reference.putFile(file!);
    TaskSnapshot snapshot = await uploadTask;
    imageUrl = await snapshot.ref.getDownloadURL();
    print(imageUrl);
  }

  bool isUploaded = false;

  updateData(docId, data) {
    _firebaseFirestore.collection("Persons").doc(docId).update(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Person"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(21),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              file == null
                  ? const SizedBox()
                  : Container(
                      height: height(context) * 0.5,
                      child: Image.file(file!),
                    ),
              GestureDetector(
                onTap: () {
                  pickImageCamera();
                },
                child: Container(
                    width: width(context),
                    decoration: myOutlineBoxDecoration(Colors.blue),
                    padding: const EdgeInsets.all(21),
                    margin: const EdgeInsets.all(21),
                    child: const Icon(Icons.camera_alt)),
              )
              /* Image(image: NetworkImage(""))
              ,*/
              ,
              Container(
                decoration: myOutlineBoxDecoration(Colors.blue),
                padding: const EdgeInsets.symmetric(horizontal: 21),
                width: width(context),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      hintText: "Name", border: InputBorder.none),
                ),
              ),
              isUploaded == false
                  ? SizedBox(
                      width: width(context),
                      child: ElevatedButton(
                          onPressed: () {
                            if (file != null &&
                                _nameController.text.trim().isNotEmpty) {
                              uploadProfileImage().then((value) {
                                _firebaseFirestore
                                    .collection("Persons")
                                    .doc(widget.docId)
                                    .update({
                                  "name": _nameController.text.trim(),
                                  "image": imageUrl
                                }).then((value) {
                                  isUploaded = true;
                                  Navigator.pop(context);
                                  setState(() {});
                                });
                              });
                            }
                          },
                          child: const Text("Update")),
                    )
                  : const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
