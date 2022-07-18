import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String type;
  final String uid;
  final String profileId;
  final String username;
  final String photoUrl;
  final String content;
  final String mediaUrl;
  final DateTime timeNotified;

  NotificationModel({
    required this.type,
    required this.uid,
    required this.profileId,
    required this.username,
    required this.photoUrl,
    this.content = "",
    this.mediaUrl = "",
    required this.timeNotified,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "uid": uid,
      "profileId": profileId,
      "username": username,
      "photoUrl": photoUrl,
      "content": content,
      "mediaUrl": mediaUrl,
      "timeNotified": timeNotified,
    };
  }

  static NotificationModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return NotificationModel(
      type: snap["type"],
      uid: snap["uid"],
      profileId: snap["profileId"],
      username: snap["username"],
      photoUrl: snap["photoUrl"],
      content: snap["content"],
      mediaUrl: snap["mediaUrl"],
      timeNotified: snap["timeNotified"].toDate(),
    );
  }
}
