import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sconnect_v1/models/chat_model.dart';
import 'package:sconnect_v1/models/notification_model.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/models/solves_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:sconnect_v1/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> post({
    required String uid,
    required String username,
    required String topic,
    required String description,
    required Uint8List? file,
    required String destination,
  }) async {
    String res = "";
    String collectionName = "";
    String subCollectionName = "";
    switch (destination) {
      case "userQuery":
        {
          collectionName = "queries";
          subCollectionName = "userQueries";
        }
        break;
      case "groupFreshers":
        {
          collectionName = "groups";
          subCollectionName = "fresherQueries";
        }
        break;
      case "groupSoph":
        {
          collectionName = "groups";
          subCollectionName = "sophQueries";
        }
        break;
      case "groupJunior":
        {
          collectionName = "groups";
          subCollectionName = "juniorQueries";
        }
        break;
      case "groupSenior":
        {
          collectionName = "groups";
          subCollectionName = "seniorQueries";
        }
        break;
      default:
        {
          collectionName = "groups";
          subCollectionName = "alumniQueries";
        }
        break;
    }
    try {
      String photoUrl = await StorageService().pushToStorage("posts", file);
      String queryId = const Uuid().v1();
      QueryModel _queryModel = QueryModel(
        uid: uid,
        queryId: queryId,
        username: username,
        topic: topic,
        description: description,
        photoUrl: photoUrl,
        timePosted: DateTime.now(),
        likes: [],
      );

      if (destination == "userQuery") {
        _firestore
            .collection(collectionName)
            .doc(_auth.currentUser!.uid)
            .collection(subCollectionName)
            .doc(queryId)
            .set(_queryModel.toJson());
      } else {
        _firestore
            .collection(collectionName)
            .doc("groups")
            .collection(subCollectionName)
            .doc(queryId)
            .set(_queryModel.toJson());
      }
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> completeRegistration({
    required String username,
    required String year,
  }) async {
    String res = "";
    try {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "username": username,
        "year": year,
      });
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> updateUserProfile({
    required String name,
    required String username,
    required String bio,
  }) async {
    String res = "";
    final DocumentSnapshot snapshot =
        await usersRef.doc(_auth.currentUser!.uid).get();
    if (snapshot.exists) {
      try {
        await usersRef.doc(_auth.currentUser!.uid).update(
          {
            "name": name,
            "username": username,
            "bio": bio,
          },
        );
        res = "success";
      } catch (e) {
        res = e.toString();
      }
    }
    return res;
  }

  followUser({required String profileId, required userId}) async {
    await followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(userId)
        .set({});
    await followingRef
        .doc(userId)
        .collection('usersFollowing')
        .doc(profileId)
        .set({});
    final String username = await SharedPrefrencesMethods().getSavedUsername();
    final String photoUrl = await SharedPrefrencesMethods().getSavedPhotoUrl();
    NotificationModel notificationModel = NotificationModel(
      type: "follow",
      uid: userId,
      profileId: profileId,
      username: username,
      photoUrl: photoUrl,
      timeNotified: DateTime.now(),
    );

    await notificationsRef
        .doc(profileId)
        .collection("notificationItem")
        .doc(userId)
        .set(notificationModel.toJson());
  }

  unfollowUser({required String profileId, required userId}) async {
    await _firestore
        .collection('followers')
        .doc(profileId)
        .collection('userFollowers')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await _firestore
        .collection('following')
        .doc(userId)
        .collection('usersFollowing')
        .doc(profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    await notificationsRef
        .doc(profileId)
        .collection("notificationItem")
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<String> postSolve({
    required String queryId,
    required String userId,
    required String solve,
    required String username,
    required String queryOwnwerId,
  }) async {
    String res = "";

    UserModel userModel =
        await SharedPrefrencesMethods().getUserFromLocalStorage();
    bool _isNotQueryOwnwer = userModel.uid != queryOwnwerId;
    try {
      String solveId = const Uuid().v1();
      SolvesModel _solvesModel = SolvesModel(
        queryId: queryId,
        queryOwnwerId: queryOwnwerId,
        solveId: solveId,
        userId: userId,
        username: username,
        solve: solve,
        timestamp: DateTime.now(),
        upvotes: [],
        downvotes: [],
      );
      await solvesRef.doc(queryId).collection("solves").doc(solveId).set(
            _solvesModel.toJson(),
          );
      if (_isNotQueryOwnwer) {
        NotificationModel notificationModel = NotificationModel(
          type: "solve",
          uid: userModel.uid,
          profileId: queryOwnwerId,
          username: userModel.username,
          photoUrl: userModel.photoUrl,
          content: solve,
          timeNotified: DateTime.now(),
        );

        await notificationsRef
            .doc(queryOwnwerId)
            .collection("notificationItem")
            .doc(solveId)
            .set(notificationModel.toJson());
      }
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  sendMessage({
    required ChatModel chat,
    required String profileId,
    required String uid,
    required String? chatThreadid,
  }) async {
    final String messageId = const Uuid().v1();
    String? chatThreadId = chatThreadid;

    if (chatThreadId != null) {
      await chatsRef
          .doc(chatThreadId)
          .collection("userChats")
          .doc(messageId)
          .set(
            chat.toJson(),
          );
    } else {
      chatThreadId = const Uuid().v1();
      await chatsRef
          .doc(chatThreadId)
          .collection("userChats")
          .doc(messageId)
          .set(
            chat.toJson(),
          );

      await usersRef
          .doc(uid)
          .collection("chats")
          .doc(profileId)
          .get()
          .then((doc) {
        if (!doc.exists) {
          doc.reference.set({
            profileId: chatThreadId,
          });
        }
      }).then((value) async {
        await usersRef
            .doc(profileId)
            .collection("chats")
            .doc(uid)
            .get()
            .then((doc) {
          if (!doc.exists) {
            doc.reference.set({
              uid: chatThreadId,
            });
          }
        });
      });
    }
    await usersRef.doc(uid).collection("chats").doc(profileId).update({
      "lastmessage": {
        "message": chat.message,
        "sentBy": chat.sentBy,
        "sentTo": chat.sentBy == uid ? profileId : uid,
        "isRead": false,
        "timeSent": chat.timeSent,
      },
    }).then((value) async {
      await usersRef.doc(profileId).collection("chats").doc(uid).update(
        {
          "lastmessage": {
            "message": chat.message,
            "sentBy": chat.sentBy,
            "sentTo": chat.sentBy == uid ? profileId : uid,
            "isRead": false,
            "timeSent": chat.timeSent,
          },
        },
      );
    });
  }
}
