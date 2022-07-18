import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sconnect_v1/providers/user_provider.dart';
import 'package:sconnect_v1/screens/group_screen.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';
import 'package:sconnect_v1/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/screens/saved_posts_screen.dart';

import '../assets/colors.dart';
import '../references/references.dart';

class AppDrawer extends StatefulWidget {
  final List groups;
  const AppDrawer({
    Key? key,
    required this.groups,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int following = 0;
  int followers = 0;

  @override
  void initState() {
    super.initState();
    getFollowersCount();
    getFollowingCount();
  }

  void getFollowersCount() async {
    String _currentuid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snap =
        await followersRef.doc(_currentuid).collection('userFollowers').get();
    setState(() {
      followers = snap.docs.length;
    });
  }

  void getFollowingCount() async {
    String _currentuid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snap =
        await followingRef.doc(_currentuid).collection('usersFollowing').get();
    setState(() {
      following = snap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _currentuser = Provider.of<UserProvider>(context).getUser;
    return Drawer(
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(1.0),
                          child: _currentuser.photoUrl == ""
                              ? const CircleAvatar(
                                  radius: 42.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: AssetImage(
                                    'assets/default_profilepic.jpg',
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 42,
                                  backgroundImage:
                                      NetworkImage(_currentuser.photoUrl),
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _currentuser.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                _currentuser.stdNo,
                                style: TextStyle(
                                  color: AppColors().darkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${following.toString()} following",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${followers.toString()}  followers",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  menuTile(
                    title: "Profile",
                    icon: Icons.person_outlined,
                    context: context,
                    pageWidget: UserProfileScreen(
                      profileId: _currentuser.uid,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  expansionTile(
                    title: "Groups",
                    icon: Icons.group_outlined,
                    context: context,
                    currentuser: _currentuser,
                    groups: widget.groups,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  menuTile(
                    title: "Saved Topics",
                    icon: Icons.bookmark_outline,
                    context: context,
                    pageWidget: SavedPostsScreen(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await AuthService().signOut();
                        },
                        icon: const Icon(Icons.logout_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget menuTile({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Widget pageWidget,
}) {
  return ListTile(
    leading: Icon(icon),
    iconColor: Colors.black,
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => pageWidget,
        ),
      );
    },
  );
}

List<Widget> groupTiles(BuildContext context, List groups, String title) {
  return groups.map((group) {
    switch (group) {
      case "userQuery":

      case "fresherQueries":
        {
          title = "Freshman Wall";
        }
        break;
      case "sophQueries":
        {
          title = "Sophomore Wall";
        }
        break;
      case "juniorQueries":
        {
          title = "Junior/3rd Year Wall";
        }
        break;
      case "seniorQueries":
        {
          title = "Senior/Final Years Wall";
        }
        break;
      default:
        {
          title = "Alumni Wall";
        }
        break;
    }
    return menuTile(
      context: context,
      title: title,
      icon: Icons.group_work_outlined,
      pageWidget: GroupScreen(
        title: title,
        collectionName: group,
      ),
    );
  }).toList();
}

Widget expansionTile(
    {required BuildContext context,
    required String title,
    required IconData icon,
    required UserModel currentuser,
    required List groups}) {
  return Builder(builder: (context) {
    return ExpansionTile(
        title: Text(title),
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        children: groupTiles(context, groups, ""));
  });
}
