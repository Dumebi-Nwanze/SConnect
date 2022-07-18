import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String sentBy;
  final String username;
  final String photoUrl;
  final DateTime timeSent;
  final bool isRead;
  final String message;

  ChatModel({
    required this.sentBy,
    required this.username,
    required this.photoUrl,
    required this.timeSent,
    required this.isRead,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "sentBy": sentBy,
      "username": username,
      "photoUrl": photoUrl,
      "timeSent": timeSent,
      "isRead": isRead,
      "message": message,
    };
  }

  static ChatModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return ChatModel(
      sentBy: snap["sentBy"],
      username: snap["username"],
      photoUrl: snap["photoUrl"],
      timeSent: snap["timeSent"].toDate(),
      isRead: snap["isRead"],
      message: snap["message"],
    );
  }
}
