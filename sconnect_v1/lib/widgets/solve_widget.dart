import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/solves_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../assets/colors.dart';
import '../references/references.dart';
import '../screens/user_profile_screen.dart';

class SolvesWidget extends StatefulWidget {
  final SolvesModel solve;
  final String currentuid;

  const SolvesWidget({
    Key? key,
    required this.solve,
    required this.currentuid,
  }) : super(key: key);

  @override
  State<SolvesWidget> createState() => _SolvesWidgetState();
}

class _SolvesWidgetState extends State<SolvesWidget> {
  String photoUrl = "";
  final appColor = AppColors();
  @override
  void initState() {
    super.initState();
    getProfilePicture();
  }

  getProfilePicture() async {
    await usersRef.doc(widget.solve.userId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          photoUrl = UserModel.fromSnap(doc).photoUrl;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: Offset(1, 1),
            blurRadius: 4.0,
            color: appColor.grey,
          ),
          BoxShadow(
            offset: Offset(-1, -1),
            blurRadius: 4.0,
            color: appColor.grey,
          ),
        ],
        color: appColor.offWhite,
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      photoUrl == ""
                          ? const CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: AssetImage(
                                'assets/default_profilepic.jpg',
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(photoUrl),
                              radius: 24,
                              backgroundColor: Colors.grey,
                            ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(
                                profileId: widget.solve.userId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          widget.solve.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    timeago.format(widget.solve.timestamp),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.solve.solve,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(1, 1, 8, 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.green[200],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await handleUpvotes(
                              solve: widget.solve,
                              uid: widget.currentuid,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 10,
                          ),
                        ),
                        Text(
                          widget.solve.upvotes.length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(1, 1, 8, 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red[200],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await handleDownvotes(
                              solve: widget.solve,
                              uid: widget.currentuid,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                            size: 10,
                          ),
                        ),
                        Text(
                          widget.solve.downvotes.length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> handleUpvotes({
    required SolvesModel solve,
    required String uid,
  }) async {
    bool _isUpvoted = solve.upvotes.contains(uid);
    bool _isDownvoted = solve.downvotes.contains(uid);
    String res = "";
    try {
      if (!_isUpvoted) {
        await solvesRef
            .doc(solve.queryId)
            .collection("solves")
            .doc(solve.solveId)
            .update(
          {
            'upvotes': FieldValue.arrayUnion([uid]),
          },
        );
        widget.solve.upvotes.add(uid);
        if (_isDownvoted) {
          await solvesRef
              .doc(solve.queryId)
              .collection("solves")
              .doc(solve.solveId)
              .update(
            {
              'downvotes': FieldValue.arrayRemove([uid]),
            },
          );
          widget.solve.downvotes.remove(uid);
        }
      } else {
        await solvesRef
            .doc(solve.queryId)
            .collection("solves")
            .doc(solve.solveId)
            .update(
          {
            'upvotes': FieldValue.arrayRemove([uid]),
          },
        );
        widget.solve.upvotes.remove(uid);
      }
      res = "success";
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> handleDownvotes({
    required SolvesModel solve,
    required String uid,
  }) async {
    bool _isDownvoted = solve.downvotes.contains(uid);
    bool _isUpvoted = solve.upvotes.contains(uid);
    String res = "";
    try {
      if (!_isDownvoted) {
        await solvesRef
            .doc(solve.queryId)
            .collection("solves")
            .doc(solve.solveId)
            .update(
          {
            'downvotes': FieldValue.arrayUnion([uid]),
          },
        );
        widget.solve.downvotes.add(uid);
        if (_isUpvoted) {
          await solvesRef
              .doc(solve.queryId)
              .collection("solves")
              .doc(solve.solveId)
              .update(
            {
              'upvotes': FieldValue.arrayRemove([uid]),
            },
          );
          widget.solve.upvotes.remove(uid);
        }
      } else {
        await solvesRef
            .doc(solve.queryId)
            .collection("solves")
            .doc(solve.solveId)
            .update(
          {
            'downvotes': FieldValue.arrayRemove([uid]),
          },
        );
        widget.solve.downvotes.remove(uid);
      }
      res = "success";
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}
