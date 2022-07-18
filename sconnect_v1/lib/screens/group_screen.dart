import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:sconnect_v1/widgets/query_widget.dart';
import 'package:sconnect_v1/widgets/search_query_functions.dart';

class GroupScreen extends StatefulWidget {
  final String title;
  final String collectionName;
  GroupScreen({
    Key? key,
    required this.title,
    required this.collectionName,
  }) : super(key: key);

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final String _currentuid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
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
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: QueriesSearch(
                      hintText: "Search group queries",
                      group: widget.collectionName,
                      currentUsername: SharedPrefrencesMethods.usernameKey,
                    ),
                  );
                },
                icon: Icon(Icons.search)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<QuerySnapshot>(
              future: groupsRef
                  .doc("groups")
                  .collection(widget.collectionName)
                  .orderBy("timePosted", descending: true)
                  .get(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.black,
                    ),
                  );
                } else {
                  List<QueryModel> groupQueries =
                      snapshot.data!.docs.map((doc) {
                    return QueryModel.fromSnap(doc);
                  }).toList();
                  if (groupQueries.isEmpty) {
                    return const Center(
                      child: Text(
                        "There are no posts on this group wall",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: groupQueries.length,
                    itemBuilder: (context, index) {
                      return QueryWidget(
                        userquery: groupQueries[index],
                        currentuid: _currentuid,
                        username: groupQueries[index].username,
                        collectionName: widget.collectionName,
                      );
                    },
                  );
                }
              })),
        ),
      ),
    );
  }
}
