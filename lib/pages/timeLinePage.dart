import 'package:flutter/material.dart';
import 'package:socialnetworkapp/pages/storyView.dart';
import 'package:socialnetworkapp/pages/uploadStory.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialnetworkapp/widgets/PostWidget.dart';

class TimeLinePage extends StatefulWidget {
  final GUser? gCurrentUser;

  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts = [];
  List<DocumentSnapshot>? newDocTry;
  List<String> followingsList = [];
  String? newUrl;
  GUser? gUser;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeLine() async {
    posts = [];
    createUserStories();
    FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("timeline")
        .get()
        .then((value) => value.docs.forEach((element) async {
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection("posts")
                  .where("postId", isEqualTo: element.id)
                  .get();
              List<Post>? allPosts = querySnapshot.docs
                  .map((document) => Post.fromDocument(document))
                  .toList();

              setState(() {
                posts.addAll(allPosts);
              });
            }));
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("following")
        .get();

    setState(() {
      followingsList =
          querySnapshot.docs.map((document) => document.id).toList();
    });
  }

  createUserTimeLine() {
    if (posts == []) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 100,
                  horizontal: MediaQuery.of(context).size.width / 4),
              child: Icon(
                Icons.photo_library,
                color: Theme.of(context).hintColor,
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 4),
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
    } else {
      return Column(
        children: posts,
      );
    }
  }

  getUserInfo() async {
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(auth.currentUser!.uid).get();

    if (!mounted) {
      return;
    }
    setState(() {
      this.gUser = GUser.fromDocument(documentSnapshot);
    });
  }


  createUserStories() {
    getUserInfo();
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(auth.currentUser!.uid)
            .collection("stories")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            if (gUser != null) {
              var list = snapshot.data!.docs;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 100.0,
                      child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    Theme.of(context).hintColor,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                  gUser!.url.toString(),
                                                ))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Container(
                                                height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    /*border: Border.all(
                                                        width: 3,
                                                        color: Colors.black)*/),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UploadStory(
                                                            gCurrentUser: gUser,
                                                          ),
                                                        ));
                                                  },
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        gUser!.username.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).hintColor),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoryViewPage(
                                                            ownerId:
                                                                list[index - 1]
                                                                    .id),
                                                  ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                    list[index - 1]["url"]
                                                        .toString(),
                                                  ))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: Container(
                                                  height: 70,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          width: 3,
                                                          color: Colors.blue)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        list[index - 1]["userName"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).hintColor),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                    ),
                  ],
                ),
              );
            } else {
              return circularProgress();
            }
          } else {
            return circularProgress();
          }
        });
  }

  @override
  void initState() {
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
  }

  @override
  Widget build(context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: timelinePageHeader(),
        body: RefreshIndicator(
          backgroundColor: Theme.of(context).backgroundColor,
          color: Colors.lightBlueAccent,
          onRefresh: () => retrieveTimeLine(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                createUserStories(),
                Divider(
                  color: Colors.grey,
                  thickness: 0.1,
                ),
                createUserTimeLine(),
              ],
            ),
          ),
        ));
  }

  AppBar timelinePageHeader() {
    return AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).accentColor,
        shadowColor: Theme.of(context).accentColor,
        foregroundColor: Theme.of(context).accentColor,
        title: Padding(
          padding: EdgeInsets.all(0.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Social App",
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ));
                        },
                        child: Icon(
                          Icons.near_me_outlined,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ));
  }
}
