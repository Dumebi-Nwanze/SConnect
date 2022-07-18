import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/notification_model.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationWidget extends StatelessWidget {
  final NotificationModel notificationModel;

  NotificationWidget({
    Key? key,
    required this.notificationModel,
  }) : super(key: key);
  String supplementaryText = "";
  loadSupplementaryText() {
    supplementaryText = "started following you";
    if (notificationModel.type == "solve") {
      supplementaryText = "replied your query: ${notificationModel.content}";
    }
    if (notificationModel.type == "like") {
      supplementaryText = "liked your post.";
    }
  }

  @override
  Widget build(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    loadSupplementaryText();
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            color: Colors.grey,
          )
        ],
        color: Colors.white,
      ),
      constraints: const BoxConstraints(
        maxHeight: 200,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: fullWidth * 0.68,
                    child: Row(
                      children: [
                        notificationModel.photoUrl == ""
                            ? const CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: AssetImage(
                                  'assets/default_profilepic.jpg',
                                ),
                              )
                            : CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                  notificationModel.photoUrl,
                                ),
                              ),
                        SizedBox(
                          width: fullWidth * 0.04,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(
                                    profileId: notificationModel.uid),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: fullWidth * 0.5,
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: notificationModel.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " $supplementaryText",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeago.format(notificationModel.timeNotified),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
