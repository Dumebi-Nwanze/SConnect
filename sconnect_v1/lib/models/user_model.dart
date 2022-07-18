import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  String username;
  final String email;
  final String photoUrl;
  final String bio;
  String stdNo;
  String year;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.stdNo,
    required this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "username": username,
      "email": email,
      "photoUrl": photoUrl,
      "bio": bio,
      "stdNo": stdNo,
      "year": year,
    };
  }

  static UserModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: snap["uid"],
      name: snap["name"],
      username: snap["username"],
      email: snap["email"],
      photoUrl: snap["photoUrl"],
      bio: snap["bio"],
      stdNo: snap['stdNo'],
      year: snap["year"],
    );
  }
}
