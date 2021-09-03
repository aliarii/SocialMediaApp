import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/loginControl/landingPage.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/HomePage.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final User? currentUser = auth.currentUser;
  final String? currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  GUser? user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  void initState() {
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot =
        await usersReference.doc(widget.currentOnlineUserId).get();
    user = GUser.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user!.profileName.toString();
    bioTextEditingController.text = user!.bio.toString();

    setState(() {
      loading = false;
    });
  }

  updateUserData() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      usersReference.doc(widget.currentOnlineUserId).update({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile has been updated successfully.'),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).hintColor),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              color: Theme.of(context).hintColor,
              size: 30.0,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                        child: CircleAvatar(
                          radius: 52.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user!.url.toString()),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            createProfileNameTextFormField(),
                            createBioTextFormField()
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.blue))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: updateUserData,
                          child: Text(
                            "          Update          ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          //color: Colors.red,
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.red))),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: () => logoutUser(),
                          child: Text(
                            "Logout",
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LandingPage()));
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
        TextField(
          cursorColor: Theme.of(context).hintColor,
          style: TextStyle(color: Theme.of(context).hintColor),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "Write profile name here...",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).hintColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).hintColor),
            ),
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            errorText: _profileNameValid ? null : "Profile name is very short",
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
        TextField(
          style: TextStyle(color: Theme.of(context).hintColor),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Write Bio here...",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).hintColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).hintColor),
            ),
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            errorText: _bioValid ? null : "Bio is very Long.",
          ),
        ),
      ],
    );
  }
}
