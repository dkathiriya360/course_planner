import 'package:flutter/material.dart';

class CreatePlanner extends StatefulWidget {
  const CreatePlanner({Key? key}) : super(key: key);

  @override
  _CreatePlannerState createState() => _CreatePlannerState();
}

class _CreatePlannerState extends State<CreatePlanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40, bottom: 20),
            child: Text('Add Class',
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
                labelText: 'Course Name',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left:30, right: 30, top: 10, bottom: 10),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Number',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left:30, right: 30, top: 10, bottom: 10),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Unit',
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xff297C13), // background
                onPrimary: Colors.white, // foreground
                shape: StadiumBorder(),
              ),
              onPressed: () {
              },
              child: Text('Enter'),
            ),
          ),
        ],
      ),
    );
  }
}
