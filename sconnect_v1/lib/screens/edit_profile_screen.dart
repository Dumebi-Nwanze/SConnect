import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/helpers/helper_functions.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/providers/user_provider.dart';
import 'package:sconnect_v1/references/references.dart';
import 'package:sconnect_v1/screens/user_profile_screen.dart';
import 'package:sconnect_v1/services/firestore_service.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:sconnect_v1/services/storage_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';

import '../assets/colors.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String username;
  final String bio;
  final String photoUrl;

  EditProfileScreen({
    Key? key,
    required this.uid,
    required this.name,
    required this.username,
    required this.bio,
    required this.photoUrl,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _canSave = false;
  Uint8List? _imagefile;
  bool _isCompressing = false;
  final appColor = AppColors();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _nameController.text = widget.name;
      _usernameController.text = widget.username;
      _bioController.text = widget.bio;
    });
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
            "Edit Profile",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading || _canSave == false
                  ? null
                  : () async {
                      String res = "";
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                          _canSave = false;
                        });
                        try {
                          res = await FirestoreService().updateUserProfile(
                            name: _nameController.text.trim(),
                            username: _usernameController.text.trim(),
                            bio: _bioController.text,
                          );
                          res = "success";
                          Provider.of<UserProvider>(context, listen: false)
                              .getUserDetails();
                        } catch (e) {
                          res = e.toString();
                        }
                        if (res == "success") {
                          snackBar(context, "Profile Updated");
                          Navigator.of(context).pop();
                        } else {
                          snackBar(context, "Oops something wen't wrong");
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              _isLoading
                  ? LinearProgressIndicator(
                      color: appColor.lightBlue,
                    )
                  : const SizedBox(
                      height: 0,
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StreamBuilder(
                              stream: usersRef.doc(widget.uid).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: SizedBox(
                                      height: 20.0,
                                      width: 20.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  );
                                }
                                UserModel user = UserModel.fromSnap(
                                    snapshot.data as dynamic);
                                return user.photoUrl == ""
                                    ? const Expanded(
                                        child: CircleAvatar(
                                          radius: 60.0,
                                          backgroundColor: Colors.grey,
                                          backgroundImage: AssetImage(
                                            'assets/default_profilepic.jpg',
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: CircleAvatar(
                                          radius: 60.0,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                              NetworkImage(user.photoUrl),
                                        ),
                                      );
                              }),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextButton(
                            onPressed: () {
                              openBottomSheet(context);
                            },
                            child: const Text(
                              "Change profile picture",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                onSaved: (value) {
                                  _nameController.text = value!;
                                },
                                onChanged: (value) => setState(() {
                                  _canSave = true;
                                }),
                                controller: _nameController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: appColor.grey.withOpacity(0.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: appColor.lightBlue,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: appColor.lightBlue,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  hintText: "Full Name",
                                ),
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                onSaved: (value) {
                                  _usernameController.text = value!;
                                },
                                onChanged: (value) => setState(() {
                                  _canSave = true;
                                }),
                                controller: _usernameController,
                                validator: (value) {
                                  RegExp regex =
                                      RegExp(r"^[A-Za-z][A-Za-z0-9._]{7,29}$");
                                  if (value!.isEmpty) {
                                    return "This field is required";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return "Must be 8-30 characters. Special Characters(._)";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: appColor.grey.withOpacity(0.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: appColor.lightBlue,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: appColor.lightBlue,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  hintText: "Username",
                                ),
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                onSaved: (value) {
                                  _bioController.text = value!;
                                },
                                onChanged: (value) => setState(() {
                                  _canSave = true;
                                }),
                                controller: _bioController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: appColor.grey.withOpacity(0.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: appColor.lightBlue,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: appColor.lightBlue,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  hintText: "Bio",
                                ),
                                keyboardType: TextInputType.text,
                                maxLength: 70,
                                maxLines: 3,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  openBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          "Change profile picture",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6.0,
                      ),
                      ListTile(
                        leading: const Icon(Icons.add_photo_alternate_outlined),
                        title: const Text(
                          "Select from Gallery",
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        onTap: () async {
                          String res = "";
                          Uint8List imagefile =
                              await pickImage(ImageSource.gallery);
                          setState(() {
                            _isCompressing = true;
                          });
                          imagefile = await compressImage(imagefile);
                          setState(() {
                            _imagefile = imagefile;
                            _isCompressing = false;
                          });
                          try {
                            if (widget.photoUrl != "") {
                              Reference storageRef = FirebaseStorage.instance
                                  .refFromURL(widget.photoUrl);
                              await storageRef.delete();
                            }
                            String photoUrl = await StorageService()
                                .pushToStorage("profilePics", _imagefile);
                            await usersRef.doc(widget.uid).update({
                              "photoUrl": photoUrl,
                            });
                            await SharedPrefrencesMethods()
                                .savePhotoUrlToLocalStorage(photoUrl);
                            Provider.of<UserProvider>(context, listen: false)
                                .getUserDetails();
                            res = "success";
                          } catch (e) {
                            res = e.toString();
                          }
                          if (res == "success") {
                            snackBar(context, "Profile picture updated");
                            Navigator.of(context).pop();
                          } else {
                            snackBar(context, "Oops something wen't wrong");
                          }
                        },
                      ),
                      const SizedBox(
                        height: 2.0,
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt_outlined),
                        title: const Text(
                          "Take a picture",
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        onTap: () async {
                          String res = "";
                          Uint8List imagefile =
                              await pickImage(ImageSource.camera);
                          setState(() {
                            _isCompressing = true;
                          });
                          imagefile = await compressImage(imagefile);
                          setState(() {
                            _imagefile = imagefile;
                            _isCompressing = false;
                          });
                          try {
                            if (widget.photoUrl != "") {
                              Reference storageRef = FirebaseStorage.instance
                                  .refFromURL(widget.photoUrl);
                              await storageRef.delete();
                            }
                            String photoUrl = await StorageService()
                                .pushToStorage("profilePics", _imagefile);
                            await usersRef.doc(widget.uid).update({
                              "photoUrl": photoUrl,
                            });
                            Provider.of<UserProvider>(context, listen: false)
                                .getUserDetails();
                            res = "success";
                          } catch (e) {
                            res = e.toString();
                          }
                          if (res == "success") {
                            snackBar(context, "Profile picture updated");
                            Navigator.of(context).pop();
                          } else {
                            snackBar(context, "Oops something wen't wrong");
                          }
                        },
                      ),
                      const SizedBox(
                        height: 2.0,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        title: const Text(
                          "Remove profile picture",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.red,
                          ),
                        ),
                        onTap: () async {
                          String res = "";
                          try {
                            if (widget.photoUrl != "") {
                              Reference storageRef = FirebaseStorage.instance
                                  .refFromURL(widget.photoUrl);
                              await usersRef.doc(widget.uid).update({
                                "photoUrl": "",
                              });
                              await storageRef.delete();
                              res = "success";
                            } else if (widget.uid == "") {
                              Navigator.of(context).pop();
                              return snackBar(
                                  context, "No profile picture to delete");
                            }
                          } catch (e) {
                            res = e.toString();
                          }
                          if (res == "success") {
                            Provider.of<UserProvider>(context, listen: false)
                                .getUserDetails();
                            snackBar(context, "Profile picture deleted");
                            Navigator.of(context).pop();
                          } else {
                            snackBar(context, "Oops something wen't wrong");
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
