import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:like_button/like_button.dart';
import 'package:sconnect_v1/models/notification_model.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/open_image_screen.dart';
import 'package:sconnect_v1/screens/solves_screen.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../assets/colors.dart';
import '../providers/user_provider.dart';
import '../services/shared_preferences_service.dart';

class QueryWidget extends StatefulWidget {
  final QueryModel userquery;
  final String currentuid;
  final String username;
  final String collectionName;
  QueryWidget({
    Key? key,
    required this.userquery,
    required this.currentuid,
    required this.username,
    this.collectionName = "userQueries",
  }) : super(key: key);

  @override
  State<QueryWidget> createState() => _QueryWidgetState();
}

class _QueryWidgetState extends State<QueryWidget> {
  int solvesCount = 0;
  String photoUrl = "";
  final appColor = AppColors();
  @override
  void initState() {
    super.initState();
    getSolvesCount();
    getProfilePic();
  }

  getProfilePic() async {
    String res =
        UserModel.fromSnap(await usersRef.doc(widget.userquery.uid).get())
            .photoUrl;
    setState(() {
      photoUrl = res;
    });
  }

  getSolvesCount() async {
    QuerySnapshot snap = await solvesRef
        .doc(widget.userquery.queryId)
        .collection("solves")
        .get();
    setState(() {
      solvesCount = snap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _currentuser = Provider.of<UserProvider>(context).getUser;
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.all(8.0),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        : CachedNetworkImage(
                            imageUrl: photoUrl,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade400,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                ),
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                    profileId: widget.userquery.uid,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              widget.userquery.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            timeago.format(widget.userquery.timePosted),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userquery.topic,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.userquery.description,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                widget.userquery.photoUrl == ""
                    ? const SizedBox(
                        height: 0,
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) => OpenImageScreen(
                                  photoUrl: widget.userquery.photoUrl,
                                )),
                          ));
                        },
                        child: CachedNetworkImage(
                          imageUrl: widget.userquery.photoUrl,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade400,
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        LikeButton(
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: appColor.red,
                            dotSecondaryColor: appColor.lightBlue,
                            dotThirdColor: appColor.redAccent,
                            dotLastColor: appColor.darkBlue,
                          ),
                          circleColor: CircleColor(
                            start: appColor.red,
                            end: appColor.redAccent,
                          ),
                          onTap: (isLikedState) async {
                            String res = await handleUserLikes();
                            return res == "success"
                                ? !isLikedState
                                : isLikedState;
                          },
                          isLiked: widget.userquery.likes
                              .contains(widget.currentuid),
                          likeCount: widget.userquery.likes.length,
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => SolvesScreen(
                                        queryId: widget.userquery.queryId,
                                        photoUrl: _currentuser.photoUrl,
                                        username: _currentuser.username,
                                        queryOwnwerId: widget.userquery.uid,
                                      ),
                                    ),
                                  )
                                  .then((value) => getSolvesCount());
                            },
                            icon: Icon(
                              Icons.comment_sharp,
                            )),
                        const SizedBox(
                          width: 1,
                        ),
                        Text(
                          solvesCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Consumer<UserProvider>(builder: (context, model, child) {
                      return LikeButton(
                        bubblesColor: BubblesColor(
                          dotPrimaryColor: appColor.red,
                          dotSecondaryColor: appColor.lightBlue,
                          dotThirdColor: appColor.redAccent,
                          dotLastColor: appColor.darkBlue,
                        ),
                        circleColor: CircleColor(
                          start: appColor.red,
                          end: appColor.redAccent,
                        ),
                        onTap: (isLikedState) async {
                          final _auth = FirebaseAuth.instance;
                          String res = "";

                          bool isSaved = model.getSavedList
                              .contains(widget.userquery.queryId);
                          try {
                            if (!isSaved) {
                              await usersRef
                                  .doc(_auth.currentUser!.uid)
                                  .collection("saved")
                                  .doc(widget.userquery.queryId)
                                  .set(widget.userquery.toJson());
                              model.addToSaved(
                                  queryId: widget.userquery.queryId);
                            } else {
                              await usersRef
                                  .doc(_auth.currentUser!.uid)
                                  .collection("saved")
                                  .doc(widget.userquery.queryId)
                                  .get()
                                  .then((doc) {
                                if (doc.exists) {
                                  doc.reference.delete();
                                }
                              });
                              model.removeFromSaved(
                                  queryId: widget.userquery.queryId);
                            }
                            res = "success";
                          } catch (e) {
                            res = e.toString();
                          }

                          return res == "success"
                              ? !isLikedState
                              : isLikedState;
                        },
                        isLiked: model.getSavedList
                            .contains(widget.userquery.queryId),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.bookmark : Icons.bookmark_outline,
                            color: isLiked ? appColor.darkBlue : appColor.black,
                          );
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> handleUserLikes() async {
    bool _isLiked = widget.userquery.likes.contains(widget.currentuid);
    bool _isNotQueryOwnwer = widget.currentuid != widget.userquery.uid;
    String res = "";

    try {
      if (!_isLiked) {
        widget.collectionName != "userQueries"
            ? await groupsRef
                .doc("groups")
                .collection(widget.collectionName)
                .doc(widget.userquery.queryId)
                .update(
                {
                  'likes': FieldValue.arrayUnion([widget.currentuid]),
                },
              )
            : await queriesRef
                .doc(widget.userquery.uid)
                .collection(widget.collectionName)
                .doc(widget.userquery.queryId)
                .update(
                {
                  'likes': FieldValue.arrayUnion([widget.currentuid]),
                },
              );

        if (_isNotQueryOwnwer) {
          final String photoUrl =
              await SharedPrefrencesMethods().getSavedPhotoUrl();
          final String username =
              await SharedPrefrencesMethods().getSavedUsername();
          NotificationModel notificationModel = NotificationModel(
            type: "like",
            uid: widget.currentuid,
            profileId: widget.userquery.uid,
            username: username,
            photoUrl: photoUrl,
            content: widget.userquery.topic,
            mediaUrl: widget.userquery.photoUrl,
            timeNotified: DateTime.now(),
          );
          await notificationsRef
              .doc(widget.userquery.uid)
              .collection("notificationItem")
              .doc(widget.userquery.queryId)
              .set(notificationModel.toJson());
        }
        widget.userquery.likes.add(widget.currentuid);
      } else {
        widget.collectionName != "userQueries"
            ? await groupsRef
                .doc("groups")
                .collection(widget.collectionName)
                .doc(widget.userquery.queryId)
                .update(
                {
                  'likes': FieldValue.arrayRemove([widget.currentuid]),
                },
              )
            : await queriesRef
                .doc(widget.userquery.uid)
                .collection(widget.collectionName)
                .doc(widget.userquery.queryId)
                .update(
                {
                  'likes': FieldValue.arrayRemove([widget.currentuid]),
                },
              );
        await notificationsRef
            .doc(widget.userquery.uid)
            .collection("notificationItem")
            .doc(widget.userquery.queryId)
            .get()
            .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });

        widget.userquery.likes.remove(widget.currentuid);
      }
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
