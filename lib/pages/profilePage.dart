import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/getAllFollowers.dart';
import 'package:socialnetworkapp/widgets/HeaderWidget.dart';
import 'package:socialnetworkapp/pages/homePage.dart';
import 'package:socialnetworkapp/widgets/PostTileWidget.dart';

import 'package:socialnetworkapp/widgets/PostWidget.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final String? userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final String? currentOnlineUserId = gCurrentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  GUser? userInfo;
  String postOrientation = "grid";
  String? newUrl;
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;

  void initState() {
    super.initState();
    getAllProfilePosts();
    getSearchedUserInfo();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userProfileId)
        .collection("following")
        .get();

    setState(() {
      countTotalFollowings = querySnapshot.docs.length;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userProfileId)
        .collection("followers")
        .get();

    setState(() {
      countTotalFollowers = querySnapshot.docs.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("following")
        .doc(widget.userProfileId)
        .get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .update({
      "following": FieldValue.arrayRemove([widget.userProfileId])
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userProfileId)
        .update({
      "followers": FieldValue.arrayRemove([auth.currentUser!.uid])
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("following")
        .doc(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc("${widget.userProfileId}")
        .collection("followers")
        .doc(auth.currentUser!.uid)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc("${widget.userProfileId}")
        .collection("notifications")
        .doc(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc(gCurrentUser?.id)
        .collection("timeline")
        .where('ownerId', isEqualTo: widget.userProfileId)
        .get()
        .then((querySnapshot) => {
              querySnapshot.docs.forEach((element) {
                element.reference.delete();
              })
            });
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userProfileId)
        .update({
      "followers": FieldValue.arrayUnion([currentOnlineUserId])
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentOnlineUserId)
        .update({
      "following": FieldValue.arrayUnion([widget.userProfileId])
    });

    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userProfileId)
        .collection("followers")
        .doc(currentOnlineUserId)
        .set({});

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentOnlineUserId)
        .collection("following")
        .doc(widget.userProfileId)
        .set({});

    FirebaseFirestore.instance
        .collection("users")
        .doc("${widget.userProfileId}")
        .collection("notifications")
        .doc(currentOnlineUserId)
        .set({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "userName": gCurrentUser?.username,
      "timestamp": DateTime.now(),
      "userProfileImg": gCurrentUser?.url,
      "userId": currentOnlineUserId,
      "url": "",
      "postId": "",
      "commentData": "",
    });
  }

  createProfileTopView() {
    return StreamBuilder(
      stream: usersReference.doc(widget.userProfileId).snapshots(),
      builder: (context, AsyncSnapshot dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        if(userInfo!=null){
          return Padding(
            padding: EdgeInsets.all(17.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.blue,
                      backgroundImage:
                      CachedNetworkImageProvider(gCurrentUser!.url.toString()),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createColumns("posts", countPost),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Followers(
                                            gCurrentUser: gCurrentUser,
                                          )));
                                },
                                child: createColumns(
                                    "followers", countTotalFollowers),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Followers(
                                            gCurrentUser: gCurrentUser,
                                          )));
                                },
                                child: createColumns(
                                    "following", countTotalFollowings),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    /*gCurrentUser!.username.toString(),*/
                    userInfo!.username.toString(),
                    style: TextStyle(
                        fontSize: 14.0, color: Theme.of(context).hintColor),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    /*gCurrentUser!.profileName.toString(),*/
                    userInfo!.profileName.toString(),
                    style: TextStyle(
                        fontSize: 18.0, color: Theme.of(context).hintColor),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    /*gCurrentUser!.bio.toString(),*/
                    userInfo!.bio.toString(),
                    style: TextStyle(
                        fontSize: 18.0, color: Theme.of(context).hintColor),
                  ),
                ),
              ],
            ),
          );
        }
        return circularProgress();
      },
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
        title: "Edit Profile",
        performFunction: editUserProfile,
      );
    } else if (following) {
      return createButtonTitleAndFunction(
        title: "Unfollow",
        performFunction: controlUnfollowUser,
      );
    } else if (!following) {
      return createButtonTitleAndFunction(
        title: "Follow",
        performFunction: controlFollowUser,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('ownerId', isEqualTo: widget.userProfileId)
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postsList = querySnapshot.docs
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  getSearchedUserInfo() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot =
    await usersReference.doc(widget.userProfileId).get();
    setState(() {
      loading = false;
      userInfo = GUser.fromDocument(documentSnapshot);
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          splashColor: Colors.transparent,
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_view_rounded),
          color: Theme.of(context).hintColor,
          iconSize: postOrientation == "grid" ? 30 : 20,
        ),
        IconButton(
          splashColor: Colors.transparent,
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.view_list_rounded),
          color: Theme.of(context).hintColor,
          iconSize: postOrientation == "list" ? 30 : 20,
        ),
      ],
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: Theme.of(context).hintColor,
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      setState(() {
        postsList.forEach((eachPost) {
          gridTilesList.add(GridTile(
              child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.1, color: Colors.grey),
            ),
            child: PostTile(eachPost),
          )));
        });
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    }
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Container createButtonTitleAndFunction(
      {String? title, Function? performFunction}) {
    return Container(
      padding: EdgeInsets.all(3.0),
      child: TextButton(
        onPressed: () => performFunction!(),
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 26.0,
          child: Text(
            title!,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        strTitle: "Profile",
      ),
      body: ListView(
        children: [
          createProfileTopView(),
          Divider(
            color: Colors.grey,
            thickness: 0.1,
          ),
          createListAndGridPostOrientation(),
          Divider(
            color: Colors.transparent,
          ),
          displayProfilePost(),
        ],
      ),
    );
  }
}
