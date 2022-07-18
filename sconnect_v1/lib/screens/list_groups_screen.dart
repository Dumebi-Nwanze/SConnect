import 'package:flutter/material.dart';
import 'package:sconnect_v1/screens/add_post_screen.dart';

class ListGroupsScreen extends StatelessWidget {
  final List groups;
  const ListGroupsScreen({
    Key? key,
    required this.groups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            "Your Groups",
            style: const TextStyle(
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: groupTiles(context, groups, "", ""),
          ),
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

List<Widget> groupTiles(
  BuildContext context,
  List groups,
  String title,
  String destination,
) {
  return groups.map((group) {
    switch (group) {
      case "fresherQueries":
        {
          title = "Freshers Wall";
          destination = "groupFreshers";
        }
        break;
      case "sophQueries":
        {
          title = "Sophomores Wall";
          destination = "groupSoph";
        }
        break;
      case "juniorQueries":
        {
          title = "Juniors Wall";
          destination = "groupJunior";
        }
        break;
      case "seniorQueries":
        {
          title = "Seniors Wall";
          destination = "groupSenior";
        }
        break;
      default:
        {
          title = "Alumni Wall";
          destination = "groupAlumni";
        }
        break;
    }
    return menuTile(
      context: context,
      title: title,
      icon: Icons.group_work_outlined,
      pageWidget: AddPostScreen(
        destination: destination,
      ),
    );
  }).toList();
}
