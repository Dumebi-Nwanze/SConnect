import 'package:cloud_firestore/cloud_firestore.dart';

class SolvesModel {
  final String queryId;
  final String queryOwnwerId;
  final String solveId;
  final String userId;
  final String username;
  final String solve;
  final DateTime timestamp;
  final List upvotes;
  final List downvotes;

  SolvesModel({
    required this.queryId,
    required this.queryOwnwerId,
    required this.solveId,
    required this.userId,
    required this.username,
    required this.solve,
    required this.timestamp,
    required this.upvotes,
    required this.downvotes,
  });

  Map<String, dynamic> toJson() {
    return {
      "queryId": queryId,
      "queryOwnwerId": queryOwnwerId,
      "solveId": solveId,
      "userId": userId,
      "username": username,
      "solve": solve,
      "timestamp": timestamp,
      "upvotes": upvotes,
      "downvotes": downvotes,
    };
  }

  static SolvesModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return SolvesModel(
      queryId: snap['queryId'],
      queryOwnwerId: snap['queryOwnwerId'],
      solveId: snap['solveId'],
      userId: snap['userId'],
      username: snap['username'],
      solve: snap['solve'],
      timestamp: snap['timestamp'].toDate(),
      upvotes: snap['upvotes'],
      downvotes: snap['downvotes'],
    );
  }
}
