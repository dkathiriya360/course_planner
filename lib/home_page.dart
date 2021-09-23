import 'package:course_planner/create_planner.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xff229954),
        leading: Icon(Icons.home),
      ),

      body: Column(
        children: [
          Container(
              margin: EdgeInsets.only(left: 30, top: 65, bottom: 30),
              width: 200,
              child: ElevatedButton.icon(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePlanner()),
                );
              },
                  icon: Icon(Icons.add_box),
                  label: Text('Create a new planner'),
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xff31508C), // background
                      onPrimary: Colors.white, // foreground
                  ),
              ),
          ),

          Container(
              margin: EdgeInsets.only(left: 30, top: 10, bottom: 30),
              padding: EdgeInsets.only(left:0),
              width: 200,
              child: ElevatedButton.icon(onPressed: () {},
                icon: Icon(Icons.history),
                label: Text('Course History'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff31508C), // background
                  onPrimary: Colors.white, // foreground
                ),
              ),
          ),

          Container(
              margin: EdgeInsets.only(left: 30, top: 10, bottom: 30),
              width: 200,
              child: ElevatedButton.icon(onPressed: () {},
                icon: Icon(Icons.edit),
                label: Text('Edit a planner'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff31508C), // background
                  onPrimary: Colors.white, // foreground
                ),
              ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'User Info',
              backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'User Info',

              backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'User Info',
              backgroundColor: Colors.green
          ),
        ],
      ),
    );
  }
}
