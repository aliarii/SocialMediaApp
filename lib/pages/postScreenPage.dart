import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialnetworkapp/widgets/HeaderWidget.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/widgets/PostWidget.dart';

class PostScreenPage extends StatelessWidget {
  final String? postId;
  final String? userId;

  PostScreenPage({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection("posts").doc(postId).get(),
      builder: (context, AsyncSnapshot dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }

        Post? post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description.toString()),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
