import 'package:socialnetworkapp/pages/postScreenPage.dart';
import 'package:socialnetworkapp/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post? post;

  PostTile(this.post);

  displayFullPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PostScreenPage(postId: post!.postId, userId: post!.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => displayFullPost(context),
      child: Image.network(post!.url.toString()),
    );
  }
}
