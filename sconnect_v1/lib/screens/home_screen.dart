import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/providers/user_provider.dart';
import 'package:sconnect_v1/screens/add_post_screen.dart';
import 'package:sconnect_v1/screens/feed_screen.dart';
import 'package:sconnect_v1/screens/list_groups_screen.dart';
import 'package:sconnect_v1/screens/notifications_feed_screen.dart';
import 'package:sconnect_v1/screens/search_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sconnect_v1/screens/chat_list_screen.dart';

import '../assets/colors.dart';
import '../references/references.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  final appColor = AppColors();
  bool _isLoading = true;
  List usergroups = [];
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).getUserDetails();
    getGroupsList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: appColor.black,
              ),
            )
          : Scaffold(
              body: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                children: [
                  FeedPage(
                    groups: usergroups,
                  ),
                  SearchPage(),
                  NotificationsFeedScreen(),
                  ChatListScreen(),
                ],
              ),
              floatingActionButton: SpeedDial(
                icon: Icons.add_rounded,
                activeIcon: Icons.close_rounded,
                foregroundColor: appColor.black,
                backgroundColor: appColor.lightBlue,
                overlayColor: appColor.white,
                overlayOpacity: 0.6,
                spaceBetweenChildren: 12.0,
                spacing: 12.0,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.edit),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => AddPostScreen(
                                destination: "userQuery",
                              )),
                    ),
                    label: "Add Post",
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.group),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ListGroupsScreen(
                                groups: usergroups,
                              )),
                    ),
                    label: "Add Post to group",
                  ),
                ],
              ),
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: appColor.darkBlue.withOpacity(0.3),
                  indicatorColor: appColor.lightBlue,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  labelTextStyle: MaterialStateProperty.all(
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
                child: NavigationBar(
                  height: 60,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      curve: Curves.linear,
                    );
                  },
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      label: "Home",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search),
                      label: "Search",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_outlined),
                      label: "Notifications",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline_rounded),
                      label: "Chats",
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  getGroupsList() async {
    final _auth = FirebaseAuth.instance;
    QuerySnapshot snapshot =
        await usersRef.doc(_auth.currentUser!.uid).collection("groups").get();
    List<Map<String, dynamic>> groups = snapshot.docs.map((e) {
      return e.data() as Map<String, dynamic>;
    }).toList();
    List<dynamic> values = [];
    for (var i in groups) {
      values.add(i.values.toString().replaceAll('(', '').replaceAll(')', ''));
    }
    setState(() {
      usergroups = values;
      _isLoading = false;
    });
  }
}
