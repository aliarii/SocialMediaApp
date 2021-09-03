import 'package:socialnetworkapp/widgets/HeaderWidget.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'homePage.dart';

class CommentsPage extends StatefulWidget {
  final String? postId;
  final String? postOwnerId;
  final String? postImageUrl;

  CommentsPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  CommentsPageState createState() => CommentsPageState(
      postId: postId, postOwnerId: postOwnerId, postImageUrl: postImageUrl);
}

class CommentsPageState extends State<CommentsPage> {
  final String? postId;
  final String? postOwnerId;
  final String? postImageUrl;
  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({this.postId, this.postOwnerId, this.postImageUrl});

  retrieveComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("comments")
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshots.data!.docs.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  saveComment() {
    FirebaseFirestore.instance
        .collection("comments")
        .doc(postId)
        .collection("comments")
        .add({
      "userName": gCurrentUser!.username,
      "comment": commentTextEditingController.text,
      "timestamp": DateTime.now(),
      "url": gCurrentUser!.url,
      "userId": gCurrentUser!.id,
    });

    bool isNotPostOwner = postOwnerId != gCurrentUser!.id;
    if (isNotPostOwner) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(postOwnerId)
          .collection("notifications")
          .add({
        "type": "comment",
        "commentData": commentTextEditingController.text,
        "postId": postId,
        "userId": gCurrentUser!.id,
        "userName": gCurrentUser!.username,
        "userProfileImg": gCurrentUser!.url,
        "url": postImageUrl,
        "timestamp": DateTime.now(),
      });
    }
    commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: retrieveComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              cursorColor: Theme.of(context).hintColor,
              controller: commentTextEditingController,
              decoration: InputDecoration(
                labelText: "Write a comment here...",
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).hintColor)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).hintColor)),
              ),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            trailing: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: saveComment,
              child: Text(
                "Publish",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String? username;
  final String? userId;
  final String? url;
  final String? comment;
  final Timestamp? timestamp;

  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot["userName"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Theme.of(context).accentColor,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                username! + ":  " + comment!,
                style: TextStyle(
                    fontSize: 18.0, color: Theme.of(context).hintColor),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url!),
              ),
              subtitle: Text(
                tAgo.format(timestamp!.toDate()),
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
