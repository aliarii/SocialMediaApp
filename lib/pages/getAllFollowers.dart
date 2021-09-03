import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/HomePage.dart';
import 'package:socialnetworkapp/pages/profilePage.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Followers extends StatefulWidget {
  final User? currentUser = auth.currentUser;
  final String? currentOnlineUserId;
  final GUser? gCurrentUser;

  Followers({this.currentOnlineUserId, this.gCurrentUser});

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  String showList = "followers";

  createListAndGridPostOrientation() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    width: 0.2,
                    color: showList == "followers"
                        ? Theme.of(context).hintColor
                        : Colors.transparent),
              ),
            ),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                setList("followers");
              },
              child: Text(
                'Followers',
                style:
                    TextStyle(fontSize: 15, color: Theme.of(context).hintColor),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 0.2,
            color: Theme.of(context).hintColor,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    width: 0.2,
                    color: showList == "followings"
                        ? Theme.of(context).hintColor
                        : Colors.transparent),
              ),
            ),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                setList("followings");
              },
              child: Text(
                'Following',
                style:
                    TextStyle(fontSize: 15, color: Theme.of(context).hintColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<QuerySnapshot>? futureSearchResults;

  getMembers() {
    if (showList == "followers") {
      Future<QuerySnapshot> allUsers = FirebaseFirestore.instance
          .collection("users")
          .where("following", arrayContains: widget.gCurrentUser!.id)
          .get();
      setState(() {
        futureSearchResults = allUsers;
      });
    } else {
      Future<QuerySnapshot> allUsers = FirebaseFirestore.instance
          .collection("users")
          .where("followers", arrayContains: widget.gCurrentUser!.id)
          .get();
      setState(() {
        futureSearchResults = allUsers;
      });
    }
  }

  displayUsers() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, AsyncSnapshot dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<FollowersResult> searchUserResult = [];
        dataSnapshot.data?.docs.forEach((document) {
          GUser eachUser = GUser.fromDocument(document);
          FollowersResult userResult = FollowersResult(eachUser);
          searchUserResult.add(userResult);
        });
        return ListView(
          shrinkWrap: true,
          children: searchUserResult,
        );
      },
    );
  }

  setList(String list) {
    setState(() {
      this.showList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    getMembers();
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).hintColor),
        title: Text(
          widget.gCurrentUser!.profileName.toString(),
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          createListAndGridPostOrientation(),
          //listFollowers(),
          displayUsers(),
        ],
      ),
    );
  }
}

class FollowersResult extends StatelessWidget {
  final GUser? eachUser;

  FollowersResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(17, 0, 17, 0),
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () =>
                  displayUserProfile(context, userProfileId: eachUser!.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser!.url.toString()),
                ),
                title: Text(
                  eachUser!.username.toString(),
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser!.username.toString(),
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String? userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }
}
