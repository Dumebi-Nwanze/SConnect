import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/chat_screen.dart';
import 'package:sconnect_v1/screens/edit_profile_screen.dart';
import 'package:sconnect_v1/services/firestore_service.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:sconnect_v1/widgets/query_widget.dart';

import '../assets/colors.dart';
import '../providers/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key? key, required this.profileId}) : super(key: key);
  final String profileId;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;
  List<QueryModel> userQueries = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int following = 0;
  int followers = 0;
  bool isFollowing = false;
  UserModel? currentUser;
  String currentUsername = "";
  final appColor = AppColors();
  @override
  void initState() {
    super.initState();
    getUsername();
    getUser();
    getUserPosts();
    getFollowersCount();
    getFollowingCount();
    getFollowState();
  }

  void getUser() async {
    UserModel user = await SharedPrefrencesMethods().getUserFromLocalStorage();
    setState(() {
      currentUser = user;
    });
  }

  getUsername() async {
    if (widget.profileId == _auth.currentUser!.uid) {
      String username = await SharedPrefrencesMethods().getSavedUsername();
      setState(() {
        currentUsername = username;
      });
    } else {
      UserModel _fetchedUser =
          UserModel.fromSnap(await usersRef.doc(widget.profileId).get());
      setState(() {
        currentUsername = _fetchedUser.username;
      });
    }
  }

  void getFollowersCount() async {
    QuerySnapshot snap = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followers = snap.docs.length;
    });
  }

  void getFollowingCount() async {
    QuerySnapshot snap = await followingRef
        .doc(widget.profileId)
        .collection('usersFollowing')
        .get();
    setState(() {
      following = snap.docs.length;
    });
  }

  getFollowState() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(_auth.currentUser!.uid)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  void followUser() async {
    setState(() {
      isFollowing = true;
    });
    await FirestoreService().followUser(
      profileId: widget.profileId,
      userId: _auth.currentUser!.uid,
    );
    setState(() {
      followers++;
    });
  }

  void unfollowUser() async {
    setState(() {
      isFollowing = false;
    });
    await FirestoreService().unfollowUser(
      profileId: widget.profileId,
      userId: _auth.currentUser!.uid,
    );
    setState(() {
      followers--;
    });
  }

  void getUserPosts() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot snapshot = await queriesRef
        .doc(widget.profileId)
        .collection("userQueries")
        .orderBy("timePosted", descending: true)
        .get();
    setState(() {
      userQueries = snapshot.docs.map((e) => QueryModel.fromSnap(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;

    bool _isCurrentUserProfile = widget.profileId == _auth.currentUser!.uid;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverAppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
              title: currentUsername == ""
                  ? Text(
                      "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appColor.white,
                      ),
                    )
                  : Text(
                      "@$currentUsername",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: appColor.white,
                      ),
                    ),
              backgroundColor: appColor.lightBlue,
              foregroundColor: appColor.black,
              elevation: 0,
              expandedHeight: fullHeight * 0.49,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _isCurrentUserProfile
                    ? buildProfileHead()
                    : buildOtherUserProfileHead(),
              ),
            ),
            SliverToBoxAdapter(
              child: buildPostCount(),
            ),
            buildProfileBody(context),
          ],
        ),
      ),
    );
  }

  Widget buildProfileBody(BuildContext context) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      );
    } else {
      if (userQueries.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: SvgPicture.asset("../assets/no_posts.svg"),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "No Posts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                )
              ],
            ),
          ),
        );
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return QueryWidget(
              userquery: userQueries[index],
              currentuid: _auth.currentUser!.uid,
              username: currentUsername,
            );
          },
          childCount: userQueries.length,
        ),
      );
    }
  }

  Widget buildOtherUserProfileHead() {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.black,
              ),
            );
          } else {
            UserModel fetcheduser =
                UserModel.fromSnap(snapshot.data as dynamic);
            return Container(
              color: appColor.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 32.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: fullWidth * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              fetcheduser.photoUrl == ""
                                  ? const CircleAvatar(
                                      radius: 40.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: AssetImage(
                                        'assets/default_profilepic.jpg',
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 40.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          NetworkImage(fetcheduser.photoUrl),
                                    ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                fetcheduser.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              fetcheduser.bio == ""
                                  ? const SizedBox(
                                      height: 0,
                                    )
                                  : Text(
                                      fetcheduser.bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: fullWidth * 0.50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: fullHeight * 0.08,
                                        child: Column(
                                          children: [
                                            Text(
                                              following.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "following",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: fullHeight * 0.08,
                                        child: Column(
                                          children: [
                                            Text(
                                              followers.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "followers",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              widget.profileId == _auth.currentUser!.uid
                                  ? buildEditButton(context, currentUser!)
                                  : buildFollowButton(),
                              SizedBox(
                                height:
                                    widget.profileId == _auth.currentUser!.uid
                                        ? 0
                                        : 20,
                              ),
                              widget.profileId == _auth.currentUser!.uid
                                  ? const SizedBox(
                                      height: 0,
                                    )
                                  : buildChatButton(
                                      context,
                                      widget.profileId,
                                      _auth.currentUser!.uid,
                                      currentUser!.username,
                                      currentUser!.photoUrl,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget buildProfileHead() {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return currentUser == null
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: appColor.black,
            ),
          )
        : Container(
            color: appColor.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 32.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: fullWidth * 0.4,
                        child: Consumer<UserProvider>(
                            builder: (context, usermodel, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              usermodel.getUser.photoUrl == ""
                                  ? const CircleAvatar(
                                      radius: 40.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: AssetImage(
                                        'assets/default_profilepic.jpg',
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 40.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                          usermodel.getUser.photoUrl),
                                    ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                usermodel.getUser.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              usermodel.getUser.bio == ""
                                  ? const SizedBox(
                                      height: 0,
                                    )
                                  : Text(
                                      usermodel.getUser.bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                            ],
                          );
                        }),
                      ),
                      SizedBox(
                        width: fullWidth * 0.50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: fullHeight * 0.08,
                                      child: Column(
                                        children: [
                                          Text(
                                            following.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "following",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: fullHeight * 0.08,
                                      child: Column(
                                        children: [
                                          Text(
                                            followers.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "followers",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            widget.profileId == _auth.currentUser!.uid
                                ? buildEditButton(context, currentUser!)
                                : buildFollowButton(),
                            SizedBox(
                              height: widget.profileId == _auth.currentUser!.uid
                                  ? 0
                                  : 20,
                            ),
                            widget.profileId == _auth.currentUser!.uid
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : buildChatButton(
                                    context,
                                    widget.profileId,
                                    _auth.currentUser!.uid,
                                    currentUser!.username,
                                    currentUser!.photoUrl,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildChatButton(
    BuildContext context,
    String profileId,
    String uid,
    String username,
    String photoUrl,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              profileId: profileId,
              uid: uid,
              profileUsername: username,
              profilePhotoUrl: photoUrl,
            ),
          ),
        );
      },
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: appColor.lightBlue,
          ),
          child: Center(
            child: Text(
              "Chat",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appColor.black,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditButton(BuildContext context, UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(
                uid: user.uid,
                name: user.name,
                username: user.username,
                bio: user.bio,
                photoUrl: user.photoUrl),
          ),
        )
            .whenComplete(() {
          setState(() {});
        });
      },
      child: FractionallySizedBox(
        widthFactor: 0.75,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: appColor.white,
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
          ),
          child: Center(
            child: Text(
              "Edit Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appColor.black,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPostCount() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Container(
          width: 80,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: appColor.lightBlue,
          ),
          child: Center(
            child: Text(
              "${userQueries.length.toString()} posts",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFollowButton() {
    return GestureDetector(
      onTap: isFollowing ? unfollowUser : followUser,
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Container(
          height: 50,
          decoration: !isFollowing
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: appColor.darkBlue,
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: appColor.white,
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
                ),
          child: Center(
            child: isFollowing
                ? Text(
                    "Unfollow",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: appColor.black,
                    ),
                  )
                : Text(
                    "Follow",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: appColor.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
