import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/add_username_screen.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signIn(
      {required String email, required String password}) async {
    String res = "";
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot snapshot = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      UserModel userModel = UserModel.fromSnap(snapshot);
      await SharedPrefrencesMethods().saveUserToLocalStorage(userModel);
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> googleSignIn() async {
    String res = "";
    try {
      final user = await GoogleSignIn().signIn().catchError((error) {
        res = error.toString();
      });
      if (user != null) {
        final googleAuth = await user.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential _userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential)
            .catchError((error) {
          res = error.toString();
        });
        User? signedInUser = _userCredential.user;
        if (signedInUser != null) {
          if (_userCredential.additionalUserInfo!.isNewUser) {
            UserModel userModel = UserModel(
              uid: _userCredential.user!.uid,
              name: user.displayName.toString(),
              username: "",
              email: user.email.toString(),
              photoUrl: user.photoUrl.toString(),
              stdNo: "",
              bio: "",
              year: "",
            );

            await _firestore
                .collection("users")
                .doc(_userCredential.user!.uid)
                .set(userModel.toJson());
          }
        }
      }

      await SharedPrefrencesMethods().saveUserToLocalStorage(
          UserModel.fromSnap(await usersRef.doc(_auth.currentUser!.uid).get()));
      res = "success";
    } on FirebaseAuthException catch (e) {
      res = e.message!;
    }

    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await SharedPrefrencesMethods().clearSavedUser();
  }

  Future<String> signUp({
    required String username,
    required String name,
    required String email,
    required String password,
    required String level,
    required String stdNumber,
  }) async {
    String res = "";
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserModel userModel = UserModel(
        uid: cred.user!.uid,
        name: name,
        username: username,
        email: email,
        photoUrl: "",
        stdNo: stdNumber,
        bio: "",
        year: level,
      );
      await _firestore
          .collection("users")
          .doc(cred.user!.uid)
          .set(userModel.toJson());
      String docName = "";
      switch (level) {
        case "Freshman":
          {
            docName = "fresherQueries";
          }
          break;
        case "Sophomore":
          {
            docName = "sophQueries";
          }
          break;
        case "Junior/3rd Year":
          {
            docName = "juniorQueries";
          }
          break;
        case "Senior/Final Years":
          {
            docName = "seniorQueries";
          }
          break;

        default:
          {
            docName = "alumniQueries";
          }
          break;
      }
      await usersRef.doc(cred.user!.uid).collection("groups").doc(level).set({
        "querires": docName,
      });
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  getUserdata() async {
    DocumentSnapshot? userSnap =
        await _firestore.collection("users").doc(_auth.currentUser!.uid).get();
    if (userSnap.exists) {
      return UserModel.fromSnap(userSnap);
    }
  }

  Future<String> sendLink({required String email}) async {
    String res = "";
    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = "success";
    } on FirebaseAuthException catch (e) {
      res = e.code;
    }
    return res;
  }
}
