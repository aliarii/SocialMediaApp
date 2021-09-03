import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/homePage.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Stories extends StatefulWidget {

  final String? postId;
  final String? ownerId;
  final String? username;

  Stories({
    this.postId,
    this.ownerId,
    this.username,
  });

  factory Stories.fromDocument(DocumentSnapshot documentSnapshot) {
    return Stories(
      postId: documentSnapshot["storyId"],
      ownerId: documentSnapshot["ownerId"],
      username: documentSnapshot["userName"],
    );
  }

  @override
  _StoriesState createState() => _StoriesState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
  );
}

class _StoriesState extends State<Stories> {
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? currentOnlineUserId = gCurrentUser?.id;

  _StoriesState({
    this.postId,
    this.ownerId,
    this.username,
  });

  @override
  Widget build(BuildContext context) {

    return createUserStories();
  }

  createUserStories(){
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(currentOnlineUserId)
          .get(),
      builder: (context, AsyncSnapshot dataSnapshot){
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        GUser gUser = GUser.fromDocument(dataSnapshot.data);
        return Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            width: 80,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                          image: DecorationImage(
                              image: NetworkImage(
                                  gUser.url.toString()
                              )
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2, color: Colors.white)),
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
                              shape: BoxShape.circle, color: Colors.blue),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${gUser.username}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12,color: Colors.white),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
