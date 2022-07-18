import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sconnect_v1/models/chat_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';
import 'package:sconnect_v1/services/firestore_service.dart';

import '../assets/colors.dart';

class ChatScreen extends StatefulWidget {
  final String profileId;
  final String uid;
  final String profileUsername;
  final String profilePhotoUrl;
  ChatScreen({
    Key? key,
    required this.profileId,
    required this.uid,
    required this.profileUsername,
    required this.profilePhotoUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _canSend = false;
  String? chatId;
  final appColor = AppColors();
  @override
  void initState() {
    super.initState();
    _chatController.addListener(() {
      setState(() {
        _canSend = _chatController.text.isNotEmpty;
      });
    });
    getChatKey();
    readMessage();
  }

  void getChatKey() async {
    await usersRef
        .doc(widget.uid)
        .collection("chats")
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        Map<String, dynamic> chatKey = doc.data()!;
        setState(() {
          chatId = chatKey[widget.profileId].toString();
        });
      }
    });
  }

  void readMessage() async {
    final _auth = FirebaseAuth.instance;
    if (_auth.currentUser!.uid != widget.profileId) {
      await usersRef
          .doc(_auth.currentUser!.uid)
          .collection("chats")
          .doc(widget.profileId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          var lastmessage = doc.data() as Map<String, dynamic>;
          if (lastmessage["lastmessage"]["isRead"] == false) {
            await usersRef
                .doc(_auth.currentUser!.uid)
                .collection("chats")
                .doc(widget.profileId)
                .update({
              "lastmessage": {
                "message": lastmessage["lastmessage"]["message"],
                "sentBy": lastmessage["lastmessage"]["sentBy"],
                "sentTo": lastmessage["lastmessage"]["sentTo"],
                "isRead": true,
                "timeSent": lastmessage["lastmessage"]["timeSent"],
              }
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: appColor.lightBlue,
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    profileId: widget.profileId,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                widget.profilePhotoUrl == ""
                    ? const CircleAvatar(
                        radius: 18.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: AssetImage(
                          'assets/default_profilepic.jpg',
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(widget.profilePhotoUrl),
                        radius: 18.0,
                        backgroundColor: Colors.grey,
                      ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.profileUsername,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: chatsRef
                      .doc(chatId)
                      .collection("userChats")
                      .orderBy("timeSent", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.black,
                        ),
                      );
                    }
                    List<ChatModel> chats = snapshot.data!.docs
                        .map((chat) => ChatModel.fromSnap(chat))
                        .toList();
                    if (chats.isEmpty) {
                      getChatKey();
                    }
                    return GroupedListView(
                      controller: _scrollController,
                      elements: chats,
                      groupBy: (ChatModel chat) {
                        return DateTime(
                          chat.timeSent.year,
                          chat.timeSent.month,
                          chat.timeSent.day,
                        );
                      },
                      reverse: true,
                      order: GroupedListOrder.DESC,
                      useStickyGroupSeparators: true,
                      floatingHeader: true,
                      groupHeaderBuilder: (ChatModel chat) => SizedBox(
                        height: 40,
                        child: Center(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: appColor.darkBlue.withOpacity(0.6),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat.yMMMd().format(
                                  chat.timeSent,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      itemBuilder: (context, ChatModel chat) {
                        bool isSentByMe = chat.sentBy == widget.uid;
                        return Align(
                          alignment: isSentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 250,
                              minWidth: 80,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: isSentByMe
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.zero,
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    )
                                  : const BorderRadius.only(
                                      topLeft: Radius.zero,
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                              color: isSentByMe
                                  ? appColor.lightBlue
                                  : appColor.offWhite,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Align(
                                    alignment: isSentByMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      chat.message,
                                      style: TextStyle(
                                        color: isSentByMe
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2.0,
                                        ),
                                        child: Text(
                                          DateFormat('h:mma').format(
                                            chat.timeSent,
                                          ),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: !isSentByMe
                                                ? Colors.black54
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
            buildTextInput(),
          ],
        ),
      ),
    );
  }

  Widget buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: appColor.grey.withOpacity(0.1),
              ),
              child: TextField(
                controller: _chatController,
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appColor.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appColor.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: "Message...",
                  hintStyle: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          ClipOval(
            child: Material(
              color: Colors.blue[300],
              child: InkWell(
                onTap: _canSend
                    ? () async {
                        await sendMessage();
                      }
                    : null,
                splashColor: Colors.white60,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.send,
                    color: appColor.black,
                    size: 18.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  sendMessage() async {
    final _auth = FirebaseAuth.instance;
    UserModel currentUser =
        UserModel.fromSnap(await usersRef.doc(_auth.currentUser!.uid).get());
    ChatModel chat = ChatModel(
      sentBy: currentUser.uid,
      username: currentUser.username,
      photoUrl: currentUser.photoUrl,
      timeSent: DateTime.now(),
      isRead: false,
      message: _chatController.text,
    );
    _chatController.clear();
    await FirestoreService().sendMessage(
      chat: chat,
      profileId: widget.profileId,
      uid: currentUser.uid,
      chatThreadid: chatId,
    );
    if (chatId == null) {
      getChatKey();
    }
  }
}
