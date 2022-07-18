import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/assets/colors.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/group_screen.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:sconnect_v1/widgets/query_widget.dart';
import '../models/query_model.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';

class FeedPage extends StatefulWidget {
  final List groups;
  FeedPage({
    Key? key,
    required this.groups,
  }) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String? _photoUrl;
  String username = "";
  bool _isLoading = true;
  bool _isProfilePicLoading = true;
  List<String> usersfollowing = [];
  List<QueryModel> timeline = [];
  List<UserModel> followSuggestions = [];
  final _auth = FirebaseAuth.instance;
  String useryear = "";

  @override
  void initState() {
    super.initState();
    getUser();

    getTimeline();
  }

  void getUser() async {
    _photoUrl = await SharedPrefrencesMethods().getSavedPhotoUrl();
    String _username = await SharedPrefrencesMethods().getSavedUsername();
    setState(() {
      username = _username;
      _isProfilePicLoading = false;
    });
  }

  Future<List<String>> getFollowingList() async {
    List<String> following = [];
    QuerySnapshot snapshot = await followingRef
        .doc(_auth.currentUser!.uid)
        .collection('usersFollowing')
        .get();
    setState(() {
      following = snapshot.docs.map((doc) => doc.id).toList();
      usersfollowing = snapshot.docs.map((doc) => doc.id).toList();
    });
    return following;
  }

  getFollowSuggetions() async {
    List<UserModel> suggestions = [];
    String group = widget.groups[0];
    String year;
    switch (group) {
      case "fresherQueries":
        {
          year = "Freshman";
        }
        break;
      case "sophQueries":
        {
          year = "Sophomore";
        }
        break;
      case "juniorQueries":
        {
          year = "Junior/3rd Year";
        }
        break;
      case "seniorQueries":
        {
          year = "Senior/Final Years";
        }
        break;
      default:
        {
          year = "Alumni";
        }
        break;
    }
    QuerySnapshot snapshot =
        await usersRef.where("year", isEqualTo: year).limit(10).get();
    suggestions += snapshot.docs.map((doc) {
      return UserModel.fromSnap(doc);
    }).toList();
    setState(() {
      useryear = year;
      followSuggestions = suggestions;
    });
  }

  getTimeline() async {
    List<String> following = await getFollowingList();
    List<QueryModel> queries = [];
    for (int i = 0; i < following.length; i++) {
      QuerySnapshot snapshot = await queriesRef
          .doc(following[i])
          .collection("userQueries")
          .orderBy('timePosted', descending: true)
          .get();

      queries += snapshot.docs.map((doc) {
        return QueryModel.fromSnap(doc);
      }).toList();
    }
    if (queries.isEmpty) {
      await getFollowSuggetions();
    }
    setState(() {
      timeline += queries;
      timeline.sort((a, b) => b.timePosted.compareTo(a.timePosted));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading: Consumer<UserProvider>(
              builder: (context, usermodel, child) {
                return InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: _isProfilePicLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(10.0),
                          child: usermodel.getUser.photoUrl == ""
                              ? const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: AssetImage(
                                    'assets/default_profilepic.jpg',
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      NetworkImage(usermodel.getUser.photoUrl),
                                ),
                        ),
                );
              },
            ),
            title: const Text(
              "SConnect",
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
              preferredSize: const Size.fromHeight(4),
            )),
        backgroundColor: Colors.white,
        drawer: const AppDrawer(
          groups: [
            'fresherQueries',
            'sophQueries',
            'juniorQueries',
            'seniorQueries',
            'alumniQueries'
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.black,
                ),
              )
            : timeline.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Look at posts from other students in your year",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GroupScreen(
                                  title: "$useryear Wall",
                                  collectionName: widget.groups[0],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors().darkBlue,
                            ),
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Center(
                              child: Text(
                                "Group Posts",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        Text(
                          "Follow students in your year",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: followSuggestions.length,
                            shrinkWrap: true,
                            itemBuilder: ((context, index) {
                              if (followSuggestions.isEmpty)
                                return Text("No suggestions");
                              if (followSuggestions[index].uid !=
                                  _auth.currentUser!.uid) {
                                return followCard(followSuggestions[index]);
                              } else {
                                return Text("");
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: timeline.length,
                    itemBuilder: ((context, index) {
                      return QueryWidget(
                          userquery: timeline[index],
                          currentuid: _auth.currentUser!.uid,
                          username: username);
                    }),
                  ),
      ),
    );
  }

  Widget followCard(UserModel user) {
    bool isFollowing = usersfollowing.contains(user.uid);
    void followUser() async {
      setState(() {
        isFollowing = true;
      });
      await FirestoreService().followUser(
        profileId: user.uid,
        userId: _auth.currentUser!.uid,
      );
      setState(() {
        usersfollowing.add(user.uid);
      });
    }

    void unfollowUser() async {
      setState(() {
        isFollowing = false;
      });
      await FirestoreService().unfollowUser(
        profileId: user.uid,
        userId: _auth.currentUser!.uid,
      );
      setState(() {
        usersfollowing.remove(user.uid);
      });
    }

    return Container(
      margin: const EdgeInsets.only(
        right: 16,
      ),
      height: 150,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors().offWhite,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              user.photoUrl == ""
                  ? const CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage(
                        'assets/default_profilepic.jpg',
                      ),
                      radius: 30,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(user.photoUrl),
                      radius: 30,
                    ),
              const SizedBox(
                height: 10,
              ),
              Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: isFollowing ? unfollowUser : followUser,
                child: Container(
                  decoration: !isFollowing
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors().lightBlue,
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors().white,
                          border: Border(),
                        ),
                  height: 25,
                  width: 50,
                  child: Center(
                    child: !isFollowing
                        ? const Text(
                            "Follow",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          )
                        : const Text(
                            "Unfollow",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
