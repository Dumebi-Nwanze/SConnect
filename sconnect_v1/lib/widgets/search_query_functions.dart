import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/widgets/query_widget.dart';

class QueriesSearch extends SearchDelegate {
  QueriesSearch({
    required String hintText,
    required this.group,
    required this.currentUsername,
  });
  String group;
  String currentUsername;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query == "") {
            Navigator.of(context).pop();
          } else {
            query = "";
          }
        },
        icon: const Icon(
          Icons.clear,
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text("Search for queries using their topic keywords"),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: groupsRef.doc("groups").collection(group).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            );
          } else if (snapshot.data!.docs
              .where((doc) => doc['topic']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList()
              .isEmpty) {
            return Center(
              child: Text(
                "Sorry, there are no results for '${query}'",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            );
          } else {
            final _auth = FirebaseAuth.instance;
            List<QueryModel> queries = snapshot.data!.docs
                .where((doc) => doc['topic']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList()
                .map((doc) => QueryModel.fromSnap(doc))
                .toList();

            return StatefulBuilder(builder: (context, StateSetter setState) {
              return ListView.builder(
                itemCount: queries.length,
                itemBuilder: (context, index) {
                  return QueryWidget(
                    userquery: queries[index],
                    currentuid: _auth.currentUser!.uid,
                    username: currentUsername,
                  );
                },
              );
            });
          }
        });
  }
}
