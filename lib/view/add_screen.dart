import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:upmarket_test/res/utils.dart';

import '../provider/service_provider.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _nameController = TextEditingController();

  late ServiceProvider _serviceProvider;

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
  void initState() {
    _serviceProvider = Provider.of(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _serviceProvider = Provider.of(context);

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
                              isUploaded = true;
                              setState(() {});
                              uploadProfileImage().then((value) {
                                _serviceProvider.addData({
                                  "name": _nameController.text.trim(),
                                  "image": imageUrl
                                }).then((value) {
                                  _serviceProvider.fetchData();
                                  isUploaded = false;
                                  Navigator.pop(context);
                                  setState(() {});
                                });
                              });
                            }
                          },
                          child: const Text("Add Details")),
                    )
                  : const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
