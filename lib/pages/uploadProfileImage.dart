import 'dart:io';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'homePage.dart';

class UploadProfileImage extends StatefulWidget {
  final GUser? gCurrentUser;

  UploadProfileImage({this.gCurrentUser});

  @override
  _UploadProfileImageState createState() => _UploadProfileImageState();
}

class _UploadProfileImageState extends State<UploadProfileImage>{
  XFile? file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController =
  TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  captureImageWithCamera() async {
    Navigator.pop(context);
    final image = await ImagePicker().pickImage(
        imageQuality: 60,
        source: ImageSource.camera,
        maxHeight: 680,
        maxWidth: 970,

    );
    setState(() {
      this.file = image;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    final image = await ImagePicker().pickImage(
      imageQuality: 60,
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = image;
    });
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    String? downloadUrl = await uploadPhoto(File(file!.path));

    savePostInfoToFireStore(
        //newPostId: postId,
        url: downloadUrl,
        //location: locationTextEditingController.text,
        //description: descriptionTextEditingController.text
    );
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      uploading = false;
      //postId = Uuid().v4();
    });
  }

  savePostInfoToFireStore(
      {String? url}) async {

    final snapshot = await FirebaseFirestore.instance.collection("users").doc(auth.currentUser!.uid).get();
    if (snapshot.exists) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser!.uid)
          .update({
        "url": url,
      });
    }
    else{
      FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser!.uid)
          .set({
        "url": url,
      });
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("followers").get();

    querySnapshot.docs.forEach((document) {
      var a = document;
      //print(a.id);
      FirebaseFirestore.instance.collection("users").doc(a.id)
          .collection("stories")
          .doc(auth.currentUser!.uid)
          .update({
        "url":url,
      });
    });

    FirebaseFirestore.instance.collection("users")
        .doc(auth.currentUser!.uid)
        .collection("stories")
        .doc(auth.currentUser!.uid)
        .update({
      "url":url,
    });

  }

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask =
    FirebaseStorage.instance.ref().child("Posts Pictures").child("post_$postId.jpg").putFile(mImageFile);
    TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
    String? downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "New Image",
              style:
              TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture Image",
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select Image From Gallery",
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }
  displayUploadScreen() {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_to_photos,
            color: Theme.of(context).hintColor,
            size: 200,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    )),
              ),
              child: Text(
                "Profile Picture",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              onPressed: () => takeImage(context),
            ),
          )
        ],
      ),
    );
  }
  String? newUrl;
  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          "New Profile Image",
          style: TextStyle(
              fontSize: 24, color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (uploading != true) {
                controlUploadAndSave();
              }
            },
            child: Text(
              "Upload",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          )
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).hintColor,
          ),
          onPressed: () => clearPostInfo(),
        ),
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: MediaQuery.of(context).size.height/2,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(File(file!.path)),
                        fit: BoxFit.cover)),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12)),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen(): displayUploadFormScreen();
  }
}
