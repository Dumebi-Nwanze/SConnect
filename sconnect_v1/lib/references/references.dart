import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sconnect_v1/models/user_model.dart';

final queriesRef = FirebaseFirestore.instance.collection("queries");
final usersRef = FirebaseFirestore.instance.collection("users");
final followersRef = FirebaseFirestore.instance.collection("followers");
final followingRef = FirebaseFirestore.instance.collection("following");
final solvesRef = FirebaseFirestore.instance.collection("solves");
final chatsRef = FirebaseFirestore.instance.collection("chats");
final groupsRef = FirebaseFirestore.instance.collection("groups");
final notificationsRef = FirebaseFirestore.instance.collection("notifications");

String? userPhotoUrlRef = FirebaseAuth.instance.currentUser!.photoURL;

Future<UserModel> getCurrentUser() async {
  String _currentuid = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot snap = await usersRef.doc(_currentuid).get();
  return UserModel.fromSnap(snap);
}
