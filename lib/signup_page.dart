import 'package:course_planner/login_page.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Column(
        children: [
          Expanded(
            flex: 40,
            child: Container(
              margin: EdgeInsets.only(top: 20, bottom: 15),
              child: Image(
                image: AssetImage('assets/images/signup_logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 60,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: Text('Sign Up',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:30, right: 30, top: 10, bottom: 10),
                  child: TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:30, right: 30, top: 10, bottom: 10),
                  child: TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:30, right: 30, top: 10, bottom: 10),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 25, bottom: 25),
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff48638f), // background
                        onPrimary: Colors.white, // foreground
                        shape: StadiumBorder(),
                      ),
                      onPressed: () { },
                      child: Text('Sign up',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Container(
                        margin: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text('Return to Login',
                          style: TextStyle(
                              color: Color(0xff48638f),
                              fontSize: 15),
                        )
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

