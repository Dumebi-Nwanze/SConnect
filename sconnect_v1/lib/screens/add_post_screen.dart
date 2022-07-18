import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/providers/user_provider.dart';
import 'package:sconnect_v1/services/firestore_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';
import '../assets/colors.dart';
import '../helpers/helper_functions.dart';

class AddPostScreen extends StatefulWidget {
  final String destination;
  AddPostScreen({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _postTopicController = TextEditingController();

  final _postDescriptionController = TextEditingController();

  bool _canPost = false;
  bool _enableDescription = false;
  Uint8List? _imagefile;
  bool _isLoading = false;
  bool _isCompressing = false;
  final appColor = AppColors();

  @override
  void initState() {
    super.initState();
    _imagefile = null;
    _postTopicController.addListener(() {
      setState(() {
        _enableDescription = _postTopicController.text.isNotEmpty;
      });
    });
    _postDescriptionController.addListener(() {
      setState(() {
        _canPost = _postDescriptionController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _postTopicController.dispose();
    _postDescriptionController.dispose();
  }

  void clear() {
    _postDescriptionController.clear();
    _postTopicController.clear();
    _imagefile = null;
  }

  @override
  Widget build(BuildContext context) {
    final UserModel _currentuser = Provider.of<UserProvider>(context).getUser;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: ElevatedButton(
                onPressed: _canPost && _isLoading == false
                    ? () async {
                        setState(() {
                          _isLoading = true;
                        });
                        String res = "";

                        res = await FirestoreService().post(
                          uid: _currentuser.uid,
                          username: _currentuser.username,
                          topic: _postTopicController.text,
                          description: _postDescriptionController.text,
                          file: _imagefile,
                          destination: widget.destination,
                        );
                        if (res == "success") {
                          Navigator.of(context).pop();
                          snackBar(context, "Posted!");
                          setState(() {
                            _isLoading = false;
                          });
                          clear();
                        } else {
                          snackBar(context, "Oops something wen't wrong");
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  onSurface: appColor.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  primary: appColor.lightBlue,
                ),
                child: Text(
                  "Post",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: appColor.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            child: Container(
              height: 1,
              color: Colors.grey,
            ),
            preferredSize: const Size.fromHeight(4),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
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
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(_currentuser.photoUrl),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            maxLength: 60,
                            controller: _postTopicController,
                            autocorrect: true,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: "What's on your mind..?",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            maxLength: 300,
                            controller: _postDescriptionController,
                            autocorrect: true,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 10,
                            enabled: _enableDescription,
                            decoration: const InputDecoration(
                              hintText: "Description...",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _isCompressing
                            ? const CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.black,
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                        _imagefile != null
                            ? Stack(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image(
                                        image: MemoryImage(_imagefile!),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.75,
                                    right: 0.75,
                                    child: SizedBox.fromSize(
                                      size: const Size(40, 40),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.red,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _imagefile = null;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
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
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: appColor.lightBlue,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        color: appColor.black,
                                      ),
                                      const Text(
                                        "Gallery",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
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
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: appColor.lightBlue,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: appColor.black,
                                      ),
                                      const Text(
                                        "Camera",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
