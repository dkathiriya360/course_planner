import 'package:course_planner/home_page.dart';
import 'package:course_planner/signup_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Column(
        children: [
          Expanded(
            flex: 35,
            child: Image(
              image: AssetImage('assets/images/app_logo.png'),
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            flex: 65,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text('Login',
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
                TextButton(
                    onPressed: () {},
                    child: Container(
                        margin: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text('Forgot password?',
                                    style: TextStyle(color: Color(0xff297C13)),
                        )
                    )
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff297C13), // background
                        onPrimary: Colors.white, // foreground
                        shape: StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Text('Login'),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  width: 190,
                  child: ElevatedButton.icon(onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      height: 27, width: 27,
                    ),
                    label: Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xffC5C7CB), // background
                      onPrimary: Colors.black, // foreground
                      shape: StadiumBorder(),
                    ),
                  ),
                ),
                Divider(
                  height: 20,
                  thickness: 3,
                  indent: 30,
                  endIndent: 30,
                  color: Color(0xff84878E ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 12),
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff384D81), // background
                      onPrimary: Colors.white, // foreground
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}