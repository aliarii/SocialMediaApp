import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialnetworkapp/pages/ProfilePage.dart';
import 'package:socialnetworkapp/pages/homePage.dart';
import 'package:socialnetworkapp/widgets/HeaderWidget.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;

//final activityFeedReference = FirebaseFirestore.instance.collection("users").doc(auth.currentUser?.uid);
FirebaseAuth auth = FirebaseAuth.instance;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        strTitle: "Notifications",
      ),
      body: Container(
        child: FutureBuilder(
          future: retrieveNotifications(),
          builder: (context, AsyncSnapshot dataSnapshot) {
            if (!dataSnapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: dataSnapshot.data,
            );
          },
        ),
      ),
    );
  }

  retrieveNotifications() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(gCurrentUser!.id)
        .collection("notifications")
        .orderBy("timestamp", descending: true)
        .limit(60)
        .get();

    List<NotificationsItem> notificationsItems = [];
    querySnapshot.docs.forEach((document) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    });
    return notificationsItems;
  }
}

String? notificationItemText;
Widget? mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String? username;
  final String? type;
  final String? commentData;
  final String? postId;
  final String? userId;
  final String? userProfileImg;
  final String? url;
  final Timestamp? timestamp;

  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postId,
      this.userId,
      this.userProfileImg,
      this.url,
      this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot["userName"],
      type: documentSnapshot["type"],
      commentData: documentSnapshot["commentData"],
      postId: documentSnapshot["postId"],
      userId: documentSnapshot["userId"],
      userProfileImg: documentSnapshot["userProfileImg"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Theme.of(context).accentColor,
        child: ListTile(
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14.0, color: Theme.of(context).hintColor),
                children: [
                  TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " $notificationItemText"),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg!),
          ),
          subtitle: Text(
            tAgo.format(timestamp!.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () => displayOwnProfile(context, userProfileId: gCurrentUser!.id),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: CachedNetworkImageProvider(url!)),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      notificationItemText = "liked your post.";
    } else if (type == "comment") {
      notificationItemText = "replied: $commentData";
    } else if (type == "follow") {
      notificationItemText = "started following you.";
    } else {
      notificationItemText = "Error, Unknown type = $type";
    }
  }

  displayOwnProfile(BuildContext context, {String? userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: gCurrentUser!.id)));
  }

  displayUserProfile(BuildContext context, {String? userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(userProfileId: userProfileId)));
  }
}
