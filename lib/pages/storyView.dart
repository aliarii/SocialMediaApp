import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialnetworkapp/widgets/ProgressWidget.dart';
import "package:story_view/story_view.dart";
import 'package:flutter/material.dart';
class StoryViewPage extends StatefulWidget{

  final String? ownerId;

  StoryViewPage({
    this.ownerId,
  });

  @override
  _StoryViewPage createState() => _StoryViewPage();


}
class _StoryViewPage extends State<StoryViewPage>{
  final controller=StoryController();

  List<String> images=[];
  List<StoryItem> stories=[];
  getUserStories(){
    FirebaseFirestore.instance.collection("stories").where("ownerId",isEqualTo: widget.ownerId).get().then((value) =>
        value.docs.forEach((element) {
          setState(() {
            images=List.from(element.get("url"));
          });
        })
    );


  }

  void initState() {
    super.initState();
    getUserStories();
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i <images.length; i++) {
      setState(() {
        stories.add(
          StoryItem.pageImage(url: images.elementAt(i),controller: controller),

        );
      });
    }
    if(images.isEmpty || stories.isEmpty){
      return circularProgress();
    }
    else{
      return StoryView(
        onComplete: () {
          print("Completed a cycle");
          Navigator.pop(context);
        },
        storyItems: stories,
        controller: controller,
        inline: false,
        repeat: false,
      );
    }
  }
}