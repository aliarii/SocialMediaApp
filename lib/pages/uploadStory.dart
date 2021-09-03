import 'dart:io';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'homePage.dart';

class UploadStory extends StatefulWidget {
  final GUser? gCurrentUser;

  UploadStory({this.gCurrentUser});

  @override
  _UploadStoryState createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory>{
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
        maxWidth: 970

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
        newPostId: postId,
        url: downloadUrl,
        location: locationTextEditingController.text,
        description: descriptionTextEditingController.text);
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  savePostInfoToFireStore(
      {String? newPostId,String? url, String? location, String? description}) async {

    final snapshot = await FirebaseFirestore.instance.collection("stories").doc(auth.currentUser!.uid).get();
    if (snapshot.exists) {
      FirebaseFirestore.instance
          .collection("stories")
          .doc(auth.currentUser!.uid)
          .update({
        "ownerId": widget.gCurrentUser!.id,
        "timestamp": DateTime.now(),
        "url": FieldValue.arrayUnion([url]),
      });
    }
    else{
      FirebaseFirestore.instance
          .collection("stories")
          .doc(auth.currentUser!.uid)
          .set({
        "ownerId": widget.gCurrentUser!.id,
        "timestamp": DateTime.now(),
        "url": FieldValue.arrayUnion([url]),
      });
    }


    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("followers").get();

    querySnapshot.docs.forEach((document) {
      var a = document;
      //print(a.id);
      FirebaseFirestore.instance.collection("users").doc("${a.id}")
          .collection("stories")
          .doc(auth.currentUser!.uid)
          .set({
        "userName":widget.gCurrentUser!.username,
        "url":widget.gCurrentUser!.url,
        "ownerId": widget.gCurrentUser!.id,
      });
    });

    FirebaseFirestore.instance.collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("stories")
        .doc(auth.currentUser!.uid)
        .set({
      "userName":widget.gCurrentUser!.username,
      "url":widget.gCurrentUser!.url,
      "ownerId": widget.gCurrentUser!.id,
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
              "New Story",
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture Image",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select Image From Gallery",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
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
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_to_photos,
            color: Colors.grey,
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
                "Share Story",
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
    if(widget.gCurrentUser!.url.toString()==""){
      newUrl="https://firebasestorage.googleapis.com/v0/b/social-network-e5ffd.appspot.com/o/emptyuser.png?alt=media&token=8e78232b-2f8e-4308-acbb-fdaf03d7764c";
    }
    else{
      newUrl=widget.gCurrentUser!.url.toString();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "New Post",
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (uploading != true) {
                controlUploadAndSave();
              }
            },
            child: Text(
              "Share",
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
            color: Colors.white,
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
