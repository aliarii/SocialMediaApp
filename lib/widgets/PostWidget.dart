import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/ProfilePage.dart';
import 'package:socialnetworkapp/pages/commentsPage.dart';
import 'package:socialnetworkapp/pages/homePage.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {

  final String? postId;
  final String? ownerId;
  final dynamic likes;
  final String? username;
  final String? description;
  final String? location;
  final String? url;

  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["userName"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    likes: this.likes,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    likeCount: getTotalNumberOfLikes(this.likes),
  );
}

class _PostState extends State<Post> {
  final String? postId;
  final String? ownerId;
  Map? likes;
  final String? username;
  final String? description;
  final String? location;
  final String? url;
  int? likeCount;
  bool? isLiked;
  bool showHeart = false;
  final String? currentOnlineUserId = gCurrentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes![currentOnlineUserId] == true);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter()
        ],
      ),
    );
  }

  createPostHead() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").doc(ownerId).snapshots(),
      builder: (context, AsyncSnapshot dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        GUser user = GUser.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.url.toString()),
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: user.id),
            child: Text(
              user.username.toString(),
              style:
              TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            location!,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          trailing: isPostOwner
              ? IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.blue,
            ),
            onPressed: () => controlPostDelete(context),
          )
              : Text(""),
        );
      },
    );
  }

  controlPostDelete(BuildContext mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "What do you want?",
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Delete",
                  style: TextStyle(
                      color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  removeUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  removeUserPost() async {

    FirebaseFirestore.instance.collection("posts")
        .doc(postId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    FirebaseStorage.instance.ref().child("Posts Pictures").child("post_$postId.jpg").delete();
    QuerySnapshot newQuerySnapshot = await FirebaseFirestore.instance.collection("users")
        .doc("${auth.currentUser!.uid}")
        .collection("followers").get();
    newQuerySnapshot.docs.forEach((newDocument) async {
      var a = newDocument;
      QuerySnapshot newNewQuerySnapshot = await FirebaseFirestore.instance.collection("users").doc("${a.id}").collection("timeline")
          .where("postId", isEqualTo: postId)
          .get();
      newNewQuerySnapshot.docs.forEach((newNewDocument) {
        if (newNewDocument.exists) {
          newNewDocument.reference.delete();
        }
      });
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").doc("${auth.currentUser!.uid}").collection("timeline")
        .where("postId", isEqualTo: postId)
        .get();

    querySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    QuerySnapshot commentsQuerySnapshot =
    await FirebaseFirestore.instance.collection("comments").doc(postId).collection("comments").get();

    commentsQuerySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  displayUserProfile(BuildContext context, {String? userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection("users").doc("$ownerId").collection("notifications")
          .doc(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      FirebaseFirestore.instance.collection("users").doc("$ownerId").collection("notifications")
          .doc(postId)
          .set({

        "type": "like",
        "userName": gCurrentUser?.username,
        "userId": gCurrentUser?.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": gCurrentUser?.url,
        "commentData":"",
        "ownerId":"",
      });
    }
  }

  controlUserLikePost() {
    bool _liked = likes![currentOnlineUserId] == true;

    if (_liked) {
      FirebaseFirestore.instance.collection("users").doc("${auth.currentUser!.uid}").collection("followers")
          .get().then((value) => value.docs.forEach((element) {
        FirebaseFirestore.instance.collection("posts").doc(postId)
            .update({"likes.$currentOnlineUserId": false});
      })
      );

      removeLike();

      setState(() {
        likeCount = likeCount! - 1;
        isLiked = false;
        likes![currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      FirebaseFirestore.instance.collection("users").doc("${auth.currentUser!.uid}").collection("followers")
          .get().then((value) => value.docs.forEach((element) {
        FirebaseFirestore.instance.collection("posts").doc(postId)
                .update({"likes.$currentOnlineUserId": true});
          })
      );

      addLike();

      setState(() {
        likeCount = likeCount! + 1;
        isLiked = true;
        likes![currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url!),
          showHeart
              ? Icon(
            Icons.favorite,
            size: 140.0,
            color: Colors.pink,
          )
              : Text(""),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => controlUserLikePost(),
              child: Icon(
                isLiked! ? Icons.favorite : Icons.favorite_border,
                size: 30.0,
                color: isLiked! ? Colors.pink:Theme.of(context).hintColor,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => displayComments(context,
                  postId: postId, ownerId: ownerId, url: url),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 30.0,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username  ",
                style:
                TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                description!,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

displayComments(BuildContext context,
      {String? postId, String? ownerId, String? url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
          postId: postId, postOwnerId: ownerId, postImageUrl: url);
    }));
  }
}
