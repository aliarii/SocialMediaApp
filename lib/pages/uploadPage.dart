import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'homePage.dart';

class UploadPage extends StatefulWidget {
  final GUser? gCurrentUser;

  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
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
        maxWidth: 970);
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

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "New Post",
              style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold),
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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        color: Theme.of(context).accentColor.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
              child: Icon(
                Icons.add_to_photos,
                color: Theme.of(context).hintColor,
                size: 200,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  )),
                ),
                child: Text(
                  "Share Image",
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
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
    });
  }

  getCurrentLocation() async {
    Position position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placeMarks[0];
    String? completeAddressInfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country}';
    String? specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;
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
      {String? newPostId,
      String? url,
      String? location,
      String? description}) async {
    FirebaseFirestore.instance.collection("posts").doc(newPostId).set({
      "profileImg": widget.gCurrentUser!.url,
      "postId": newPostId,
      "ownerId": widget.gCurrentUser!.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "userName": widget.gCurrentUser!.username,
      "description": description,
      "location": location,
      "url": url,
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("followers")
        .get();

    querySnapshot.docs.forEach((document) {
      var a = document;
      //print(a.id);
      FirebaseFirestore.instance
          .collection("users")
          .doc("${a.id}")
          .collection("timeline")
          .doc(newPostId)
          .set({
        "postId": newPostId,
        "ownerId": widget.gCurrentUser!.id,
      });
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("timeline")
        .doc(newPostId)
        .set({
      "postId": newPostId,
      "ownerId": widget.gCurrentUser!.id,
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask = FirebaseStorage.instance
        .ref()
        .child("Posts Pictures")
        .child("post_$postId.jpg")
        .putFile(mImageFile);
    TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
    String? downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String? newUrl;

  displayUploadFormScreen() {
    if (widget.gCurrentUser!.url.toString() == "") {
      newUrl =
          "https://firebasestorage.googleapis.com/v0/b/social-network-e5ffd.appspot.com/o/emptyuser.png?alt=media&token=8e78232b-2f8e-4308-acbb-fdaf03d7764c";
    } else {
      newUrl = widget.gCurrentUser!.url.toString();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          "New Post",
          style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold),
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
            color: Theme.of(context).hintColor,
          ),
          onPressed: () => clearPostInfo(),
        ),
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(file!.path)),
                          fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(newUrl!),
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Theme.of(context).hintColor),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                    hintText: "description",
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              color: Theme.of(context).hintColor,
              size: 36,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Theme.of(context).hintColor),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                    hintText: "Location",
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 220,
            height: 110,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.location_on,
                color: Theme.of(context).hintColor,
              ),
              label: Text(
                "Add Current Location",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                )),
              ),
              onPressed: getCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}
