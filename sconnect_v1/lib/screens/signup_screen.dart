import 'package:flutter/material.dart';
import 'package:sconnect_v1/models/user_model.dart';
import 'package:sconnect_v1/screens/add_level_screen.dart';
import 'package:sconnect_v1/services/auth_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';

import '../assets/colors.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isNotVisible = true;
  final _formKey = GlobalKey<FormState>();
  final appColor = AppColors();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void clearText() {
    _nameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Create a new account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColor.black,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please fill the form to get started",
                        style: TextStyle(
                          color: appColor.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: fullHeight * 0.070,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              width: fullWidth * 0.75,
                              child: TextFormField(
                                onSaved: (value) {
                                  _nameController.text = value!;
                                },
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
                            ),
                            SizedBox(
                              height: fullHeight * 0.015,
                            ),
                            SizedBox(
                              width: fullWidth * 0.75,
                              child: TextFormField(
                                onSaved: (value) {
                                  _usernameController.text = value!;
                                },
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
                            ),
                            SizedBox(
                              height: fullHeight * 0.015,
                            ),
                            SizedBox(
                              width: fullWidth * 0.75,
                              child: TextFormField(
                                onSaved: (value) {
                                  _emailController.text = value!;
                                },
                                controller: _emailController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "This field is required";
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9_.]+.[a-z]")
                                      .hasMatch(value)) {
                                    return "Please enter a valid email address";
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
                                  hintText: "Email",
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            SizedBox(
                              height: fullHeight * 0.015,
                            ),
                            SizedBox(
                              width: fullWidth * 0.75,
                              child: TextFormField(
                                onSaved: (value) {
                                  _passwordController.text = value!;
                                },
                                controller: _passwordController,
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "This field is required";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return "Enter a valid password (Min. 6 Characters)";
                                  }
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
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isNotVisible = !_isNotVisible;
                                      });
                                    },
                                    child: _isNotVisible
                                        ? Icon(
                                            Icons.visibility_outlined,
                                          )
                                        : Icon(
                                            Icons.visibility_off_outlined,
                                          ),
                                  ),
                                  suffixIconColor: appColor.black,
                                  focusColor: appColor.black,
                                  prefixIconColor: appColor.black,
                                  hintText: "Password",
                                ),
                                keyboardType: TextInputType.text,
                                obscureText: _isNotVisible,
                              ),
                            ),
                            SizedBox(
                              height: fullHeight * 0.035,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  UserModel inCompleteUser = UserModel(
                                    uid: "",
                                    name: _nameController.text,
                                    username: _usernameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    photoUrl: "",
                                    bio: "",
                                    stdNo: "",
                                    year: "",
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) => AddLevelScreen(
                                            userModel: inCompleteUser,
                                            password:
                                                _passwordController.text.trim(),
                                          ),
                                        ),
                                      )
                                      .whenComplete(
                                          () => Navigator.of(context).pop());
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                            SizedBox(
                              height: fullHeight * 0.065,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Already have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Sign In.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appColor.lightBlue,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
