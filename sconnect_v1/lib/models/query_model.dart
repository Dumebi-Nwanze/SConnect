import 'package:cloud_firestore/cloud_firestore.dart';

class QueryModel {
  final String uid;
  final String queryId;
  final String username;
  final String topic;
  final String description;
  final String photoUrl;
  final DateTime timePosted;
  final List likes;

  QueryModel({
    required this.uid,
    required this.queryId,
    required this.username,
    required this.topic,
    required this.description,
    required this.photoUrl,
    required this.timePosted,
    required this.likes,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "queryId": queryId,
      "username": username,
      "topic": topic,
      "description": description,
      "photoUrl": photoUrl,
      "timePosted": timePosted,
      "likes": likes,
    };
  }

  static QueryModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return QueryModel(
      uid: snap["uid"],
      queryId: snap["queryId"],
      username: snap["username"],
      topic: snap["topic"],
      description: snap["description"],
      photoUrl: snap["photoUrl"],
      timePosted: snap["timePosted"].toDate(),
      likes: snap["likes"],
    );
  }
}
