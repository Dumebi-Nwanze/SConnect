import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/add_username_screen.dart';
import 'package:sconnect_v1/screens/home_screen.dart';

class HomeorUsernameScreen extends StatefulWidget {
  const HomeorUsernameScreen({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  State<HomeorUsernameScreen> createState() => _HomeorUsernameScreenState();
}

class _HomeorUsernameScreenState extends State<HomeorUsernameScreen> {
  String? username;
  bool _isLoading = true;
  late UserModel _userModel;
  void checkFirestore() async {
    DocumentSnapshot snap = await usersRef.doc(widget.id).get();
    UserModel user = UserModel.fromSnap(snap);

    _userModel = user;

    if (user.username != null) {
      setState(() {
        username = user.username;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkFirestore();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: Colors.white,
        ),
      );
    } else {
      if (username == null) {
        return AddUsernameScreen(
          user: _userModel,
        );
      } else {
        return const HomeScreen();
      }
    }
  }
}
