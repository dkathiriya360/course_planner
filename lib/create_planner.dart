import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';

// Class to add new course
class CreatePlanner extends StatefulWidget {
  //const CreatePlanner({Key? key}) : super(key: key);
  var plannerDetails;
  CreatePlanner(this.plannerDetails); // constructor

  @override
  _CreatePlannerState createState() => _CreatePlannerState();
}

class _CreatePlannerState extends State<CreatePlanner> {
  var courseNumberController = TextEditingController();
  var courseNameController = TextEditingController();
  var courseUnitsController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final userid = FirebaseAuth.instance.currentUser!.uid; // current user's id
  var entryID = Uuid(); // unique id for course entry
  var plannerList = []; // list of the planner
  String _error = '';

  // Constructor to check any changes to the planner database
  @override
  void initState() {
    super.initState();
    refreshCourseList();
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner/term-${widget.plannerDetails['entry_key'].toString()}')
        .onChildChanged.listen((event) {
      refreshCourseList();
    });
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner/term-${widget.plannerDetails['entry_key'].toString()}')
        .onChildAdded.listen((event) {
      refreshCourseList();
    });
  }

  // method to refresh the content and save the modified course list
  void refreshCourseList() {
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner/term-${widget.plannerDetails['entry_key'].toString()}/courses')
        .once().then((ds) {
      var tempPlannerList = [];
      ds.value.forEach((k, v) {
        tempPlannerList.add(v);
      });
      plannerList = tempPlannerList;
      //print(plannerList);
      setState(() {});
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        //reverse: true,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // back arrow
                  Container(
                    margin: EdgeInsets.only(left: 10, top: 30),
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back,
                            color: Color(0xff297C13), size: 35)),
                  ),
                  // title of the page
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 20),
                    child: Text(
                      'Add Course',
                      style: TextStyle(
                          color: Color(0xff297C13),
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // take the course number from user and validate the entry
                  Container(
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 10),
                    child: TextFormField(
                      validator: (value) {
                        _error = "";
                        if (value == null || value.isEmpty) {
                          return "Course number can't be empty.";
                        } else
                          return null;
                      },
                      controller: courseNumberController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        errorStyle: TextStyle(fontSize: 15),
                        labelText: 'Course Number',
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  // take course name from user and validate the entry
                  Container(
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 10),
                    child: TextFormField(
                      validator: (value) {
                        _error = "";
                        if (value == null || value.isEmpty) {
                          return "Course name can't be empty.";
                        } else
                          return null;
                      },
                      controller: courseNameController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        errorStyle: TextStyle(fontSize: 15),
                        labelText: 'Course Name',
                        //hintText: 'Mobile App Development',
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  // take number of units from user
                  // validate the number of units
                  Container(
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 10),
                    child: TextFormField(
                      validator: (value) {
                        _error = "";
                        if (value == null || value.isEmpty) {
                          return "Number of units is required!";
                        } else if (!RegExp(r'^[1-5]$').hasMatch(value)) {
                          return "Number of units must be between 1-5";
                        } else
                          return null;
                      }, // validator
                      controller: courseUnitsController,
                      obscureText: false,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                        errorStyle: TextStyle(fontSize: 15),
                        labelText: 'Units',
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  // display error text if error occured
                  Container(
                    // for error text
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Center(
                      child: Text(_error,
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),
                  // When pressed enter, check the existence of the course.
                  // display error if course exists, else add it to the planner
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff297C13), // background
                        onPrimary: Colors.white, // foreground
                        shape: StadiumBorder(),
                      ),
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          // check for duplicate entry
                          for (var i in plannerList) {
                            if (i['courseNumber'] == courseNumberController.text &&
                                i['courseName'] == courseNameController.text &&
                                i['courseUnits'] == courseUnitsController.text) {
                              setState(() {
                                _error = 'Course already exists!';
                              });
                            }
                          }
                          // check if course already exists in the database.
                          if(_error != 'Course already exists!') {
                            // return to display_details screen and add the course to database
                            var uniqueCourseID = entryID.v1();
                            FirebaseDatabase.instance
                                .reference()
                                .child(
                                    'users/${userid.toString()}/planner/term-${widget.plannerDetails['entry_key'].toString()}/courses/${uniqueCourseID.toString()}')
                                .set({
                              'courseNumber': courseNumberController.text,
                              'courseName': courseNameController.text,
                              'courseUnits': courseUnitsController.text,
                              'courseID': uniqueCourseID.toString()
                            }).then((value) {
                              // show message on SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor:  Color(0xff48638f),
                                    content: Text(
                                        'Course successfully added to planner!',
                                    style: TextStyle(fontSize: 16))
                                ),
                              );
                              courseNumberController.clear();
                              courseNameController.clear();
                              courseUnitsController.clear();
                            }).catchError((error) {
                              print(error);
                            });
                            setState(() {});
                          }
                        }
                      },
                      child: Text('Enter', style: TextStyle(fontSize: 18)),
                    ),
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
