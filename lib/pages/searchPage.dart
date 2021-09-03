import 'package:flutter/material.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/ProfilePage.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;

  emptyTheTextFormField() {
    futureSearchResults = null;
    searchTextEditingController.clear();
  }

  controlSearching(String? str) {
    Future<QuerySnapshot> allUsers = FirebaseFirestore.instance
        .collection("users")
        .where("userName", isGreaterThanOrEqualTo: str)
        .get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  AppBar searchPageHeader() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).backgroundColor,
      title: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            borderRadius: BorderRadius.circular(10.0)),
        child: TextFormField(
          cursorColor: Theme.of(context).accentColor,
          style: TextStyle(fontSize: 20, color: Theme.of(context).accentColor),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search",
            hintStyle: TextStyle(color: Theme.of(context).accentColor),
            contentPadding: EdgeInsets.fromLTRB(15, 12, 0, 0),
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.blue,
              size: 25,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.blue,
                size: 25,
              ),
              onPressed: () => emptyTheTextFormField(),
            ),
          ),
          onFieldSubmitted: controlSearching,
        ),
      ),
    );
  }

  Container displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group_rounded,
              color: Theme.of(context).hintColor,
              size: 200,
            ),
            Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 50),
            ),
          ],
        ),
      ),
    );
  }

  displayUsersFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, AsyncSnapshot dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];
        dataSnapshot.data?.docs.forEach((document) {
          GUser eachUser = GUser.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUserResult.add(userResult);
        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: searchPageHeader(),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUsersFoundScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final GUser? eachUser;

  UserResult(this.eachUser);

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
