import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/screens/home_screen.dart';
import 'package:sconnect_v1/services/auth_service.dart';
import 'package:sconnect_v1/services/firestore_service.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';

import '../assets/colors.dart';

class AddUsernameScreen extends StatefulWidget {
  final UserModel user;

  AddUsernameScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AddUsernameScreen> createState() => _AddUsernameScreenState();
}

class _AddUsernameScreenState extends State<AddUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _stdNoController = TextEditingController();
  final appColor = AppColors();
  String dropdownvalue = "Please choose your current level...";
  var levels = [
    "Please choose your current level...",
    'Freshman',
    'Sophomore',
    'Junior/3rd Year',
    'Senior/Final Years',
    'Alumni',
  ];

  void clearText() {
    _usernameController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appColor.white,
          foregroundColor: appColor.black,
          leading: IconButton(
            onPressed: () async {
              await AuthService().signOut();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: appColor.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Almost there...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appColor.black,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: fullHeight * 0.1,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      onSaved: (value) {
                        _usernameController.text = value!;
                      },
                      controller: _usernameController,
                      validator: (value) {
                        RegExp regex = RegExp(r"^[A-Za-z][A-Za-z0-9._]{7,29}$");
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
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onSaved: (value) {
                        _stdNoController.text = value!;
                      },
                      controller: _stdNoController,
                      validator: (value) {
                        RegExp regex = RegExp(r"^[0-9]{6,8}$");
                        if (value!.isEmpty) {
                          return "This field is required";
                        }
                        if (!regex.hasMatch(value)) {
                          return "This student number is not valid";
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
                        hintText: "Student Number",
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: appColor.grey.withOpacity(0.2),
                ),
                height: 50,
                width: fullWidth * 0.75,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    focusColor: Colors.transparent,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(20),
                    value: dropdownvalue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: levels.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: fullHeight * 0.035,
              ),
              GestureDetector(
                onTap: () async {
                  String res = "";
                  if (_formKey.currentState!.validate() &&
                      dropdownvalue != "Please choose your current level...") {
                    setState(() {
                      _isLoading = true;
                    });
                    res = await FirestoreService().completeRegistration(
                      username: _usernameController.text,
                      year: dropdownvalue,
                    );
                    UserModel toBeSaved = widget.user;
                    toBeSaved.username = _usernameController.text;
                    toBeSaved.year = dropdownvalue;
                    await SharedPrefrencesMethods()
                        .saveUserToLocalStorage(toBeSaved);
                    if (res == "success") {
                      snackBar(context, "Welcome :)");
                      clearText();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    } else {
                      snackBar(context, "Oops something wen't wrong");
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Container(
                  height: 50,
                  width: fullWidth * 0.75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: appColor.lightBlue,
                  ),
                  child: Center(
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: CircularProgressIndicator(
                                  color: appColor.black,
                                  strokeWidth: 2.0,
                                ),
                              ),
                              const SizedBox(
                                width: 24.0,
                              ),
                              Text(
                                "Please wait...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: appColor.black,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "Continue",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appColor.black,
                              fontSize: 12.0,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
