import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sconnect_v1/screens/forgot_password_screen.dart';
import 'package:sconnect_v1/screens/signup_screen.dart';
import 'package:sconnect_v1/services/auth_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';

import '../assets/colors.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGLoading = false;
  bool _isNotVisible = true;
  final _formKey = GlobalKey<FormState>();
  final appColor = AppColors();

  void clearText() {
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back",
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
                    "Connect with other students on campus",
                    style: TextStyle(
                      color: appColor.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: fullWidth * 0.75,
                    child: Row(
                      children: [
                        Text(
                          "Login to your account",
                          style: TextStyle(
                            color: appColor.black,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                              prefixIcon: Icon(
                                Icons.person_outlined,
                                color: Colors.black,
                              ),
                              hintText: "Email",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                              focusColor: appColor.black,
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
                              prefixIcon: Icon(
                                Icons.lock_open_outlined,
                                color: Colors.black,
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
                              prefixIconColor: appColor.black,
                              hintText: "Password",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: _isNotVisible,
                          ),
                        ),
                        SizedBox(
                          height: fullHeight * 0.015,
                        ),
                        SizedBox(
                          width: fullWidth * 0.75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: appColor.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: fullHeight * 0.030,
                        ),
                        GestureDetector(
                          onTap: () async {
                            String res = "";
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              res = await AuthService().signIn(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              if (res == "success") {
                                clearText();
                              } else {
                                snackBar(context, "Oops something wen't wrong");
                                setState(() {
                                  _isLoading = false;
                                });
                              }
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
                                      "Sign In",
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
                          height: fullHeight * 0.030,
                        ),
                        GestureDetector(
                          onTap: () async {
                            String res = "";
                            setState(() {
                              _isGLoading = true;
                            });
                            res = await AuthService().googleSignIn();

                            if (res != "success") {
                              setState(() {
                                _isGLoading = false;
                              });
                              snackBar(context, "Oops something wen't wrong");
                            }
                          },
                          child: Container(
                            height: 50,
                            width: fullWidth * 0.75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: appColor.white,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4.0,
                                  color: appColor.grey,
                                ),
                                BoxShadow(
                                  offset: Offset(-2, -2),
                                  blurRadius: 4.0,
                                  color: appColor.grey,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isGLoading
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
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const FaIcon(
                                          FontAwesomeIcons.google,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(
                                          width: 24.0,
                                        ),
                                        Text(
                                          "Sign In with Google",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: appColor.black,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: fullHeight * 0.080,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign up.",
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
          ),
        ),
      ),
    );
  }
}
