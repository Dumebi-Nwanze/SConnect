import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> pushToStorage(String path, Uint8List? file) async {
    if (file != null) {
      String randId = Uuid().v1();
      UploadTask task = _firebaseStorage
          .ref()
          .child(path)
          .child(_auth.currentUser!.uid)
          .child(randId)
          .putData(file);

      TaskSnapshot taskSnapshot = await task;

      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    }
    return "";
  }
}
