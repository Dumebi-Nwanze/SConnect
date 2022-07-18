import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:sconnect_v1/models/query_model.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/services/auth_service.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../references/references.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _userModel;
  static List<String> _savedQueries = [];
  UserModel get getUser => _userModel!;
  List<String> get getSavedList => _savedQueries;

  Future<void> getUserDetails() async {
    UserModel _user = await AuthService().getUserdata();
    _userModel = _user;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await SharedPrefrencesMethods().saveUserToLocalStorage(_user);

    preferences.reload();
    notifyListeners();
  }

  Future<void> getSaved() async {
    final _auth = FirebaseAuth.instance;
    QuerySnapshot snapshot =
        await usersRef.doc(_auth.currentUser!.uid).collection("saved").get();

    List<String> queryIds = snapshot.docs.map((doc) {
      var queryId = QueryModel.fromSnap(doc).queryId;
      return queryId;
    }).toList();

    _savedQueries.addAll(queryIds);
    notifyListeners();
  }

  addToSaved({required String queryId}) {
    _savedQueries.add(queryId);
    notifyListeners();
  }

  removeFromSaved({required String queryId}) {
    _savedQueries.remove(queryId);
    notifyListeners();
  }
}
