import 'package:cloud_firestore/cloud_firestore.dart';

class GUser {
  final String? id;
  final String? profileName;
  final String? username;
  final String? url;
  final String? email;
  final String? bio;

  GUser({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
  });

  factory GUser.fromDocument(DocumentSnapshot doc) {
    return GUser(
      id: doc.id,
      email: doc['userEmail'],
      username: doc['userName'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'],
    );
  }
}