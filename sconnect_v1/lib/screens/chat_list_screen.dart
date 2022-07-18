import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> userIds = [];
  List<UserModel> users = [];
  List<UserModel> chattingWith = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  onLoad() async {
    await fetchUidList();
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Chats",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: PreferredSize(
            child: Container(
              height: 1,
              color: Colors.grey,
            ),
            preferredSize: const Size.fromHeight(4),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.0,
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: usersRef
                    .doc(_auth.currentUser!.uid)
                    .collection("chats")
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.0,
                      ),
                    );
                  } else {
                    List<QueryDocumentSnapshot<Object?>> usersKeysLastmessages =
                        snapshot.data!.docs.toList();
                    List<Map<String, dynamic>> lastmessages =
                        usersKeysLastmessages
                            .map(
                                (e) => e['lastmessage'] as Map<String, dynamic>)
                            .toList();
                    if (lastmessages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: 200,
                              child: SvgPicture.asset("../assets/no_chats.svg"),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "There are no chats to display",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    for (int index = 0; index < lastmessages.length; index++) {
                      chattingWith.add(users.singleWhere((user) =>
                          user.uid ==
                          (_auth.currentUser!.uid ==
                                  lastmessages[index]['sentTo']
                              ? lastmessages[index]['sentBy']
                              : lastmessages[index]['sentTo'])));
                    }

                    return ListView.builder(
                        itemCount: userIds.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      profileId: chattingWith[index].uid,
                                      uid: _auth.currentUser!.uid,
                                      profileUsername:
                                          chattingWith[index].username,
                                      profilePhotoUrl:
                                          chattingWith[index].photoUrl),
                                ),
                              );
                            },
                            leading: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return Dialog(
                                        child: SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: chattingWith[index].photoUrl ==
                                                  ""
                                              ? Image.asset(
                                                  'assets/default_profilepic.jpg',
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  chattingWith[index].photoUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      );
                                    });
                              },
                              child: chattingWith[index].photoUrl == ""
                                  ? const CircleAvatar(
                                      radius: 30.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: AssetImage(
                                        'assets/default_profilepic.jpg',
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          chattingWith[index].photoUrl),
                                    ),
                            ),
                            title: Text(
                              chattingWith[index].name,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: fullWidth * 0.45,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: fullWidth * 0.40,
                                            child: Text(
                                              lastmessages[index]['message'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: (lastmessages[index]
                                                                ['sentBy'] !=
                                                            _auth.currentUser!
                                                                .uid &&
                                                        lastmessages[index]
                                                                ['isRead'] ==
                                                            false)
                                                    ? Colors.black54
                                                    : Colors.grey,
                                                fontWeight: (lastmessages[index]
                                                                ['sentBy'] !=
                                                            _auth.currentUser!
                                                                .uid &&
                                                        lastmessages[index]
                                                                ['isRead'] ==
                                                            false)
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          (lastmessages[index]['sentBy'] !=
                                                      _auth.currentUser!.uid &&
                                                  lastmessages[index]
                                                          ['isRead'] ==
                                                      false)
                                              ? Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      DateFormat('E h:mma').format(
                                        lastmessages[index]['timeSent']
                                            .toDate(),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ]),
                            ),
                          );
                        });
                  }
                })),
      ),
    );
  }

  fetchUidList() async {
    QuerySnapshot snapshot =
        await usersRef.doc(_auth.currentUser!.uid).collection("chats").get();
    List<QueryDocumentSnapshot<Object?>> contents = snapshot.docs.toList();
    List<Map<String, dynamic>> keys =
        contents.map((e) => e.data() as Map<String, dynamic>).toList();
    for (var k in keys) {
      for (var k in k.keys) {
        if (k != 'lastmessage') {
          setState(() {
            userIds.add(k);
          });
        }
      }
    }
  }

  fetchUserInfo() async {
    QuerySnapshot snapshot =
        await usersRef.doc(_auth.currentUser!.uid).collection("chats").get();
    List<QueryDocumentSnapshot<Object?>> contents = snapshot.docs.toList();

    List<Map<String, dynamic>> keys =
        contents.map((e) => e.data() as Map<String, dynamic>).toList();

    List<String> ids = [];
    for (var k in keys) {
      for (var k in k.keys) {
        if (k != 'lastmessage') {
          ids.add(k);
        }
      }
    }

    for (var id in ids) {
      DocumentSnapshot snap =
          await usersRef.doc(id.replaceAll('(', '').replaceAll(')', '')).get();
      setState(() {
        users.add(UserModel.fromSnap(snap));
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}
