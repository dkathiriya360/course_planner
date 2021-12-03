import 'package:course_planner/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Reset page
class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  var emailController = TextEditingController(); // for user email
  String _error= ''; // to show error
  bool isLoading = false; // loading icon
  GlobalKey<FormState> _keyVal = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _keyVal,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, top: 30, bottom: 10),
                alignment: Alignment.centerLeft,
                child: IconButton(onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.amber[600], size: 35)
                ),
              ),

              // Title of the reset password page
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  'Reset Password',
                  style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),

              // Ask user to enter the email
              Container(
                  margin: EdgeInsets.only(top: 15, bottom: 5, left: 5, right: 5),
                  child: Text('Enter registered email address to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 17)
                  )
              ),

              // TextField to get user email
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 10),
                child: TextFormField(
                  validator: validateEmailAddress,
                  controller: emailController,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.amber[600]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    errorStyle: TextStyle(fontSize: 15),
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              // for error text
              Container(
                padding: EdgeInsets.only(top:5, bottom: 5),
                child: Center(
                  child: Text(_error,
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ),

              // when user pressed the reset button, validate the email
              // send the reset password link to user
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber[600], // background
                    onPrimary: Colors.white, // foreground
                    shape: StadiumBorder(),
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                      _error = '';
                    });
                    if (_keyVal.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text);
                        Navigator.push(context, MaterialPageRoute(
                              builder: (context) => LoginPage())).then((value) {
                          emailController.clear();
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          _error = 'No user found for that email.';
                          print(_error);
                        }
                        else {
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
                  child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text(
                    'Enter', style: TextStyle(fontSize: 15),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// validate the user email
String? validateEmailAddress(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'Email is required!';
  String emailPattern = r'\w+@\w+\.\w+';
  RegExp regExp = RegExp(emailPattern);
  if (!regExp.hasMatch(formEmail))
    return 'Incorrect format for email.';
  return null;
}