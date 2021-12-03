import 'package:course_planner/home_page.dart';
import 'package:course_planner/reset_page.dart';
import 'package:course_planner/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // to get email and password from user
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  String _error = ''; // display error
  bool isLoading = false; // loading icon
  GlobalKey<FormState> _keyVal = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _keyVal,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: Column(
              children: [
                Expanded(
                  flex: 30,
                  // add image icon for login page
                  child: Image(
                    image: AssetImage('assets/images/app_logo2.png'),
                    fit: BoxFit.fill,
                  ),
                ),

                Expanded(
                  flex: 70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // title of login page
                        Container(
                          margin: EdgeInsets.only(top: 20, bottom: 20),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // take user email
                        Container(
                          margin: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          child: TextFormField(
                            validator: validateEmailAddress,
                            controller: emailController,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xff297C13),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              errorStyle: TextStyle(fontSize: 15),
                              labelText: 'Email',
                              labelStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        // take user password
                        Container(
                          margin: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 5),
                          child: TextFormField(
                            validator: validatePass,
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color(0xff297C13),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                                errorStyle: TextStyle(fontSize: 15),
                                labelText: 'Password',
                                labelStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),

                        // container for forgot password
                        Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(bottom: 5, right: 20),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResetPage()),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                    color: Color(0xff297C13),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        // to display error text
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Center(
                            child: Text(_error,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 16)),
                          ),
                        ),

                        // Login button -  check if user exists in database and check email and password are valid
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          width: 220,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff297C13), // background
                              onPrimary: Colors.white, // foreground
                              shape: StadiumBorder(),
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                                _error = '';
                              });
                              // authenticate users before going to new state
                              if (_keyVal.currentState!.validate()) {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                  ).then((value) {
                                    passwordController.clear();
                                  }); // go to home screen if login successful
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    _error = 'No user found for that email.';
                                    print(_error);
                                  } else if (e.code == 'wrong-password') {
                                    _error = 'Incorrect password.';
                                    print(_error);
                                  } else {
                                    _error = e.message.toString();
                                    print(_error);
                                  }
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Login', style: TextStyle(fontSize: 18)),
                          ),
                        ),

                        Divider(
                          height: 20,
                          thickness: 3,
                          indent: 30,
                          endIndent: 30,
                          color: Color(0xff84878E),
                        ),

                        // For sign-up page
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ",
                                    style: TextStyle(fontSize: 16)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignUpPage()),
                                      );
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          color: Color(0xff297C13),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            )),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// method to validate the email address
String? validateEmailAddress(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty) return 'Email is required!';
  String emailPattern = r'\w+@\w+\.\w+';
  RegExp regExp = RegExp(emailPattern);
  if (!regExp.hasMatch(formEmail)) return 'Incorrect format for email.';
  return null;
}

// method to validate the password
String? validatePass(String? formPass) {
  if (formPass == null || formPass.isEmpty) return 'Password is required!';
  return null;
}
