import 'dart:ui';

import 'package:course_planner/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  // variable set to save name, email, and password that user enters
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  String _errorMessage= ''; // error text
  bool loading = false; // loading icon
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
        child: SingleChildScrollView(
          //reverse: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: Column(
              children: [
                Expanded(
                  flex: 30,
                  child: Container(
                    margin: EdgeInsets.only(top: 20, bottom: 15),
                    // image for sign-up page
                    child: Image(
                      width: 800,
                      image: AssetImage('assets/images/new_signup_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // title of the sign-up page
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 20),
                          child: Text(
                            'Sign Up',
                            style:
                                TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // name entry
                        Container(
                          margin: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          child: TextFormField(
                            validator: validateName,
                            controller: nameController,
                            obscureText: false,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_sharp, color: Color(0xff48638f)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                              //errorStyle: TextStyle(fontSize: 15),
                              labelText: 'Full Name',
                              labelStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        // email entry
                        Container(
                          margin: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          child: TextFormField(
                            validator: validateEmail,
                            controller: emailController,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 15),
                              prefixIcon: Icon(Icons.email, color: Color(0xff48638f)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                              labelText: 'Email',
                              labelStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        // password entry
                        Container(
                          margin: EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          child: TextFormField(
                            validator: validatePassword,
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 15),
                              prefixIcon: Icon(Icons.lock, color: Color(0xff48638f)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                              labelText: 'Password',
                              labelStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        // error message
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Center(
                            child: Text(_errorMessage,
                              style: TextStyle(color: Colors.red, fontSize: 16)),
                          ),
                        ),
                        // authenticate the user
                        // check if user exists and validate the user entries
                        // Also save the user on database
                        Container(
                          margin: EdgeInsets.only(top: 25, bottom: 20),
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff48638f), // background
                              onPrimary: Colors.white, // foreground
                              shape: StadiumBorder(),
                            ),
                            onPressed: () async {
                              setState(() {
                                loading = true;
                                _errorMessage = '';
                              });
                              if (_key.currentState!.validate()) {
                                try {
                                  UserCredential userCredential = await FirebaseAuth
                                      .instance.createUserWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text
                                  );
                                  var userId = FirebaseAuth.instance.currentUser!.uid;
                                  var userInfo = {
                                    'uid' : userId.toString(),
                                    'name' : nameController.text,
                                    'email' : emailController.text,
                                  };
                                  FirebaseDatabase.instance.reference().child('users/$userId/userInfo')
                                  .set(userInfo).then((value) {}).catchError((onError) {});
                                  Navigator.pop(context); // go back to login page
                                }
                                // on exceptions (error), show error message to user
                                on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    _errorMessage =
                                    'The password provided is too weak.';
                                    print(_errorMessage);
                                  } else if (e.code == 'email-already-in-use') {
                                    _errorMessage =
                                    'The account already exists for that email.';
                                    print(_errorMessage);
                                  } else {
                                    _errorMessage = e.message.toString();
                                    print(_errorMessage);
                                    print(e.code);
                                  }
                                }
                                setState(() {
                                  loading = false;
                                });
                              } // if key validate
                              setState(() {
                                loading = false;
                              });
                            },
                            child: loading ? CircularProgressIndicator(color: Colors.white) : Text(
                              'Sign up',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        // button to return to login screen
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Container(
                                margin: EdgeInsets.only(top: 5, bottom: 15),
                                child: Text(
                                  'Return to Login',
                                  style: TextStyle(
                                      color: Color(0xff48638f), fontSize: 15),
                                )
                            )
                        ),
                      ],
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

// validate the name of a user
String? validateName(String? formName) {
  if (formName == null || formName.isEmpty)
    return 'Name is required!';
  RegExp regExpression = RegExp(r'^[a-z A-Z]+$');
  if (!regExpression.hasMatch(formName))
    return "Enter valid name.";
  return null;
}

// validate the user email
String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'Email is required!';
  String emailPattern = r'\w+@\w+\.\w+';
  RegExp regExp = RegExp(emailPattern);
  if (!regExp.hasMatch(formEmail))
    return 'Incorrect format for email.';
  return null;
}

// validate the password
String? validatePassword(String? formPass) {
  if (formPass == null || formPass.isEmpty)
    return 'Password is required!';
  return null;
}
