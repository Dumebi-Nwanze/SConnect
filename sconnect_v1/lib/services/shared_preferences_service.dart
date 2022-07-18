import 'package:sconnect_v1/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrencesMethods {
  static const String uidKey = "UIDKEY";
  static const String nameKey = "NAMEKEY";
  static const String usernameKey = "USERNAMEKEY";
  static const String emailKey = "EMAILKEY";
  static const String photoUrlKey = "PHOTOURLKEY";
  static const String bioKey = "BIOKEY";
  static const String stdNoKey = "STDNOKEY";
  static const String yearKey = "YEARKEY";

  Future<bool> saveUserToLocalStorage(UserModel currentuser) async {
    bool savedUser = false;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(uidKey, currentuser.uid);
    preferences.setString(nameKey, currentuser.name);
    preferences.setString(usernameKey, currentuser.username);
    preferences.setString(emailKey, currentuser.email);
    preferences.setString(bioKey, currentuser.bio);
    preferences.setString(photoUrlKey, currentuser.photoUrl);
    preferences.setString(stdNoKey, currentuser.stdNo);
    preferences.setString(yearKey, currentuser.year);
    savedUser = true;
    return savedUser;
  }

  savePhotoUrlToLocalStorage(String photoUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(photoUrlKey, photoUrl);
    preferences.reload();
  }

  Future<UserModel> getUserFromLocalStorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    UserModel savedUser = UserModel(
      uid: preferences.getString(uidKey) ?? "",
      name: preferences.getString(nameKey) ?? "",
      username: preferences.getString(usernameKey) ?? "",
      email: preferences.getString(emailKey) ?? "",
      photoUrl: preferences.getString(photoUrlKey) ?? "",
      stdNo: preferences.getString(stdNoKey) ?? "",
      bio: preferences.getString(bioKey) ?? "",
      year: preferences.getString(yearKey) ?? "",
    );

    return savedUser;
  }

  Future<String> getSavedUid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(uidKey) ?? "";
  }

  Future<String> getSavedName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(nameKey) ?? "";
  }

  Future<String> getSavedUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(usernameKey) ?? "";
  }

  Future<String> getSavedEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(emailKey) ?? "";
  }

  Future<String> getSavedBio() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(bioKey) ?? "";
  }

  Future<String> getSavedPhotoUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(photoUrlKey) ?? "";
  }

  Future<String> getSavedStdNo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(stdNoKey) ?? "";
  }

  Future<String> getSavedYear() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    return preferences.getString(yearKey) ?? "";
  }

  clearSavedUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    preferences.reload();
  }
}
