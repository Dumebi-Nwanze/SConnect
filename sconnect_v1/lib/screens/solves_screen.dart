import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sconnect_v1/assets/colors.dart';
import 'package:sconnect_v1/helpers/helper_functions.dart';
import 'package:sconnect_v1/models/solves_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/services/firestore_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';
import 'package:sconnect_v1/widgets/solve_widget.dart';

class SolvesScreen extends StatefulWidget {
  final String queryId;
  final String? photoUrl;
  final String username;
  final String queryOwnwerId;
  SolvesScreen({
    Key? key,
    required this.queryId,
    required this.photoUrl,
    required this.username,
    required this.queryOwnwerId,
  }) : super(key: key);

  @override
  State<SolvesScreen> createState() => _SolvesScreenState();
}

class _SolvesScreenState extends State<SolvesScreen> {
  final TextEditingController _solvesController = TextEditingController();
  bool _canPost = false;
  final _auth = FirebaseAuth.instance;
  final appColor = AppColors();

  @override
  void initState() {
    super.initState();
    _solvesController.addListener(() {
      setState(() {
        _canPost = _solvesController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _solvesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
          title: const Text(
            "Solves",
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
        body: Column(
          children: [
            Expanded(
              child: buildSolvesList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _solvesController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          fillColor: appColor.grey.withOpacity(0.1),
                          contentPadding: EdgeInsets.all(8),
                          hintText: "Add a solve...",
                          hintStyle: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                          ),
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
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.edit),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: _canPost
                          ? () async {
                              String res = await handlePostSolve(
                                queryId: widget.queryId,
                                photoUrl: widget.photoUrl,
                                solve: _solvesController.text,
                                username: widget.username,
                                queryOwnwerId: widget.queryOwnwerId,
                              );
                              if (res == "success") {
                                _solvesController.clear();
                              } else {
                                snackBar(
                                    context, "Ooops, something wen't wrong");
                              }
                            }
                          : null,
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: appColor.lightBlue,
                        ),
                        child: const Center(
                          child: Text(
                            "Post",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  handlePostSolve({
    required String queryId,
    required String? photoUrl,
    required String solve,
    required String username,
    required String queryOwnwerId,
  }) async {
    String _currentuid = FirebaseAuth.instance.currentUser!.uid;
    return await FirestoreService().postSolve(
      queryId: queryId,
      userId: _currentuid,
      solve: solve,
      username: username,
      queryOwnwerId: queryOwnwerId,
    );
  }

  Widget buildSolvesList() {
    return StreamBuilder<QuerySnapshot>(
        stream: solvesRef
            .doc(widget.queryId)
            .collection("solves")
            .orderBy("timestamp", descending: false)
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
          List<SolvesModel> sortedSolves = sortSolves(snapshot.data!.docs
              .map((solve) => SolvesModel.fromSnap(solve))
              .toList());
          if (sortedSolves.isEmpty) {
            return const Center(
              child: Text(
                "There are no solves to this query",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: sortedSolves.length,
            itemBuilder: (context, index) {
              return SolvesWidget(
                solve: sortedSolves[index],
                currentuid: _auth.currentUser!.uid,
              );
            },
          );
        });
  }
}
