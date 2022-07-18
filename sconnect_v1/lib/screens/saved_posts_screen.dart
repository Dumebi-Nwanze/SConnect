import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/providers/user_provider.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/widgets/query_widget.dart';

class SavedPostsScreen extends StatefulWidget {
  SavedPostsScreen({Key? key}) : super(key: key);

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    UserModel _currentUser = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "Saved Posts",
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
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<QuerySnapshot>(
          future: usersRef
              .doc(_auth.currentUser!.uid)
              .collection("saved")
              .orderBy("timePosted", descending: true)
              .get(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.black,
                ),
              );
            } else {
              List<QueryModel> saved = snapshot.data!.docs
                  .map((doc) => QueryModel.fromSnap(doc))
                  .toList();
              if (saved.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: SvgPicture.asset("../assets/no_posts.svg"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "No Saved Posts",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: saved.length,
                    shrinkWrap: true,
                    itemBuilder: ((context, index) {
                      return QueryWidget(
                        userquery: saved[index],
                        currentuid: _auth.currentUser!.uid,
                        username: _currentUser.username,
                      );
                    }));
              }
            }
          })),
    );
  }
}
