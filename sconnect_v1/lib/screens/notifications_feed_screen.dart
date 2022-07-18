import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sconnect_v1/models/notification_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/widgets/notification_widget.dart';

import '../assets/colors.dart';

class NotificationsFeedScreen extends StatefulWidget {
  NotificationsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsFeedScreen> createState() =>
      _NotificationsFeedScreenState();
}

class _NotificationsFeedScreenState extends State<NotificationsFeedScreen> {
  final String _currentuid = FirebaseAuth.instance.currentUser!.uid;
  final appColor = AppColors();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Notifications",
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
        backgroundColor: appColor.white,
        body: StreamBuilder<QuerySnapshot>(
          stream: notificationsRef
              .doc(_currentuid)
              .collection("notificationItem")
              .orderBy(
                "timeNotified",
                descending: true,
              )
              .limit(10)
              .snapshots(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.black,
                ),
              );
            }
            List<NotificationModel> notifications = snapshot.data!.docs
                .map((doc) => NotificationModel.fromSnap(doc))
                .toList();
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: SvgPicture.asset("../assets/no_notifications.svg"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "You have no new notifications",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    )
                  ],
                ),
              );
            }
            return ListView.builder(
                itemCount: notifications.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return NotificationWidget(
                      notificationModel: notifications[index]);
                });
          }),
        ),
      ),
    );
  }
}
