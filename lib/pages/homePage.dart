import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/models/user.dart';
import 'package:socialnetworkapp/pages/timeLinePage.dart';
import 'package:socialnetworkapp/pages/notificationsPage.dart';
import 'package:socialnetworkapp/pages/profilePage.dart';
import 'package:socialnetworkapp/pages/searchPage.dart';
import 'package:socialnetworkapp/pages/uploadPage.dart';


final usersReference = FirebaseFirestore.instance.collection("users");
final DateTime timestamp = DateTime.now();
GUser? gCurrentUser;
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController? pageController;
  int getPageIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    pageController = PageController();
  }

  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController?.jumpToPage(pageIndex);
  }

  getUserInfo() async {
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(auth.currentUser!.uid).get();
    gCurrentUser = GUser.fromDocument(documentSnapshot);
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: [
          TimeLinePage(),
          SearchPage(),
          UploadPage(
            gCurrentUser: gCurrentUser,
          ),
          NotificationsPage(),
          ProfilePage(userProfileId: auth.currentUser!.uid),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Theme.of(context).hintColor,
        inactiveColor: Theme.of(context).hintColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded)),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.add_circle_outline_rounded,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded)),
        ],
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    getUserInfo();
    return buildHomeScreen();
  }
}
