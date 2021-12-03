import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Class to edit the course planner
class EditPlanner extends StatefulWidget {
  //const EditPlanner({Key? key}) : super(key: key);
  var plannerDetails;
  var courseItem;
  EditPlanner(this.plannerDetails, this.courseItem); // constructor

  @override
  _EditPlannerState createState() => _EditPlannerState();
}

class _EditPlannerState extends State<EditPlanner> {
  var courseNumberController = TextEditingController();
  var courseNameController = TextEditingController();
  var courseUnitsController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final userid = FirebaseAuth.instance.currentUser!.uid; // current user's id
  //var entryID = Uuid(); // unique id for course entry
  var plannerList = []; // list of the planner
  String _error = '';

  // constructor to check if the planner if changed or modified
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
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner/term-${widget.plannerDetails['entry_key'].toString()}')
        .onChildRemoved.listen((event) {
      refreshCourseList();
    });
  }
  // method to refresh the content
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

  // method to check the existence of the course
  bool checkDuplicateCourse() {
    bool courseExists = false;
    bool checkError = false;
    FirebaseDatabase.instance
        .reference()
        .child(
        'users/${userid.toString()}/planner/term-${widget
            .plannerDetails['entry_key'].toString()}/courses')
        .once()
        .then((ds) {
      var tempPlannerList = [];
      ds.value.forEach((k, v) {
        tempPlannerList.add(v);
      });
      plannerList = tempPlannerList;
      setState(() {});
    }).catchError((error) {
      print(error);
      checkError = true;
    });
    // check if the course already exists in database
    if (checkError == false) {
      for (var i in plannerList) {
        if (i['courseNumber'] == courseNumberController.text &&
            i['courseName'] == courseNameController.text &&
            i['courseUnits'] == courseUnitsController.text) {
          courseExists = true;
          setState(() {
            _error = 'Course already exists!';
          });

        }
      }
    }
    return courseExists;
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
                      'Edit Course',
                      style: TextStyle(
                          color: Color(0xff297C13),
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // get updated course number from the user
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
                  // get course name from user
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
                  // get number of units required
                  Container(
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 10),
                    child: TextFormField(
                      validator: (value) {
                        _error = "";
                        if (value == null || value.isEmpty) {
                          return "Number of units is required!";
                        } else if (!RegExp(r'^[1-9]$').hasMatch(value)) {
                          return "Number of units must be between 1-8";
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
                  Container(
                    // for error text
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Center(
                      child: Text(_error,
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),
                  // check the existence of the course.
                  // If course exists, show the error message
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
                          for (var i in plannerList) {
                            if (i['courseNumber'] == courseNumberController.text &&
                                i['courseName'] == courseNameController.text &&
                                i['courseUnits'] == courseUnitsController.text) {
                              setState(() {
                                _error = 'Course already exists!';
                              });
                            }
                          }
                          // show error message if the course exists
                          if(_error != 'Course already exists!') {
                            // update the course and return to display_details screen
                            FirebaseDatabase.instance
                                .reference()
                                .child(
                                'users/${userid.toString()}/planner/term-${widget.
                                plannerDetails['entry_key'].toString()}/courses/${widget.courseItem}')
                                .update({
                              'courseNumber': courseNumberController.text,
                              'courseName': courseNameController.text,
                              'courseUnits': courseUnitsController.text,
                            }).then((value) {
                              Navigator.pop(context); // return to planner_details page
                              // show message on SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xff48638f),
                                    content: Text(
                                        'Course successfully updated!', style: TextStyle(fontSize: 16),)),
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
