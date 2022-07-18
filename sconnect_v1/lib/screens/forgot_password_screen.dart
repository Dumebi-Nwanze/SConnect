import 'package:flutter/material.dart';
import 'package:sconnect_v1/assets/colors.dart';
import 'package:sconnect_v1/screens/login_screen.dart';
import 'package:sconnect_v1/services/auth_service.dart';
import 'package:sconnect_v1/widgets/snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  Form(
                    key: _formKey,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: TextFormField(
                        onSaved: (value) {
                          _emailController.text = value!;
                        },
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "This field is required";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9_.]+.[a-z]")
                              .hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors().grey.withOpacity(0.2),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors().lightBlue,
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
                              color: AppColors().lightBlue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          hintText: "Email",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  GestureDetector(
                    onTap: () async {
                      String res = "";
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        res = await AuthService().sendLink(
                          email: _emailController.text,
                        );
                        if (res == "success") {
                          _emailController.clear();
                          snackBar(context,
                              "A Link has been sent to your registered email");
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
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
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: AppColors().lightBlue,
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
                                      color: AppColors().black,
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
                                      color: AppColors().black,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "Send Link",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors().black,
                                  fontSize: 12.0,
                                ),
                              ),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
