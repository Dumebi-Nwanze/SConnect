import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';

class SearchApi {
  static Future<List<UserModel>> getUsers(String query) async {
    QuerySnapshot<Map<String, dynamic>> users = await usersRef.get();
    List<UserModel> userModels =
        users.docs.map((user) => UserModel.fromSnap(user)).toList();
    return userModels.where((userModel) {
      final username = userModel.username.toString().toLowerCase();
      return username.startsWith(query.toLowerCase());
    }).toList();
  }
}
