import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/screens/home_screen.dart';
import 'package:sconnect_v1/services/firestore_service.dart';
import 'package:sconnect_v1/services/shared_preferences_service.dart';

import '../assets/colors.dart';
import '../services/auth_service.dart';
import '../widgets/snackbar.dart';

class AddLevelScreen extends StatefulWidget {
  final UserModel userModel;
  final String password;
  AddLevelScreen({
    Key? key,
    required this.userModel,
    required this.password,
  }) : super(key: key);

  @override
  State<AddLevelScreen> createState() => _AddLevelScreenState();
}

class _AddLevelScreenState extends State<AddLevelScreen> {
  bool _isLoading = false;
  final appColor = AppColors();
  final _formKey = GlobalKey<FormState>();
  final _stdNoController = TextEditingController();
  String dropdownvalue = "Please choose your current level...";
  var levels = [
    "Please choose your current level...",
    'Freshman',
    'Sophomore',
    'Junior/3rd Year',
    'Senior/Final Years',
    'Alumni',
  ];
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: appColor.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: fullWidth * 0.75,
                  child: Text(
                    "Almost there",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: appColor.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: fullWidth * 0.75,
                    child: TextFormField(
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
                    if (dropdownvalue !=
                            "Please choose your current level..." &&
                        _formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      res = await AuthService().signUp(
                        username: widget.userModel.username,
                        name: widget.userModel.name,
                        email: widget.userModel.email,
                        password: widget.password,
                        stdNumber: _stdNoController.text,
                        level: dropdownvalue,
                      );
                      if (res == "success") {
                        snackBar(context, "Account Created");

                        await AuthService().signIn(
                          email: widget.userModel.email,
                          password: widget.password,
                        );
                      } else {
                        snackBar(context, "Oops something wen't wrong");
                      }

                      Navigator.of(context).pop();
                    } else {
                      snackBar(
                          context, "Please enter you student number and level");
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
                              "Sign Up",
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
      ),
    );
  }
}
