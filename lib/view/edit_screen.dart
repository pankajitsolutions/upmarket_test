import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:upmarket_test/res/utils.dart';

import '../provider/service_provider.dart';

class EditScreen extends StatefulWidget {
  final String docId;
  final Map data;

  const EditScreen({Key? key, required this.docId, required this.data})
      : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController _nameController = TextEditingController();

  late ServiceProvider _serviceProvider;

  @override
  void initState() {
    _serviceProvider = Provider.of(context, listen: false);
    _serviceProvider.fetchData();
    _nameController.text = widget.data["name"];
    imageUrl = widget.data["image"];
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    _serviceProvider = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.data["name"]),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(21),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              file == null
                  ? SizedBox(
                      height: height(context) * 0.4,
                      child: Image.network(widget.data["image"]),
                    )
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
              ),
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
                                _serviceProvider.updateData(widget.docId, {
                                  "name": _nameController.text.trim(),
                                  "image": imageUrl
                                }).then((value) {
                                  _serviceProvider.fetchData();
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
