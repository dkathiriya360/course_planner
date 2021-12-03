import 'package:course_planner/edit_planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'create_planner.dart';

// Planner Details - Page to display List of courses
class PlannerDetails extends StatefulWidget {
  var plannerDetails; // to store list of curses
  PlannerDetails(this.plannerDetails); // constructor

  @override
  _PlannerDetailsState createState() => _PlannerDetailsState();
}

class _PlannerDetailsState extends State<PlannerDetails> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>(); // for adding entry
  var courseList = []; // store all courses
  final userid = FirebaseAuth.instance.currentUser!.uid; // user id

  // constructor to check any changes occur for list of courses in database
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
      courseList = tempPlannerList;
      // print(courseList);
      setState(() {
      });
    }).catchError((error) {
      print(error);
    });
  }

  // method to calculate total units of specific semester
  String? sumUnits() {
    int totalUnits = 0;
    int countVal = 0;
    for(var indX in courseList) {
      totalUnits = totalUnits + int.parse(courseList[countVal]['courseUnits']);
      countVal++;
    }
    return totalUnits.toString();
  }

  // delete the course entry
  void deleteEntry(entry) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this course?'),
            actions: [
              // The "Yes" button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xff297C13), // background
                      onPrimary: Colors.white,
                      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                  ),
                  onPressed: () {
                    // close alert box and delete the entry in database
                    Navigator.pop(context);
                    FirebaseDatabase.instance.reference()
                        .child('users/${userid.toString()}/planner/term-${widget.plannerDetails['entry_key'].toString()}/courses/${entry['courseID']}')
                        .remove().then((value) {
                          // show deletion message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor:  Color(0xff48638f),
                                content: Text('The course is deleted!', style: TextStyle(fontSize: 16),)
                            ),
                          );
                    }).catchError((error){
                      print(error);
                    });
                    setState(() {
                      if(courseList.length==1)
                        courseList.clear();
                    });
                  },
                  child: Text('Yes')),
              // The "Cancel" button
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 13, color: Color(0xff297C13), fontWeight: FontWeight.bold)
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // app bar to display current semester and year
        appBar: AppBar(
          toolbarHeight: 70,
          centerTitle: true,
          title: Text(
                  '${widget.plannerDetails['semester']} ${widget.plannerDetails['year']}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xff297C13),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, size: 30)),
        ),
        body: Column(
          children: [
            // show the message to add new course if no course found for the term
            if (courseList.isEmpty) ...[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 15),
                child: Text(
                  'No course to display',
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
            // display the courses for the specified term (semester)
            else ...[
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 15),
                child: Text(
                  'Courses',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xff297C13),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              // display total number of units
              Text('Total units: ${sumUnits()}',
                style: TextStyle(
                  fontSize: 18.2,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Listview to display courses
              Flexible(
                child: Scrollbar(
                  thickness: 8,
                  isAlwaysShown: true,
                  child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: courseList.length,
                      itemBuilder: (BuildContext context, int index) {
                        // implement slide functionality to edit and delete specified entry
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: Card(
                            elevation: 7,
                            margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Container(
                              decoration: BoxDecoration(color: Color(0xff297C13)),
                              child: ListTile(
                                // onTap: () {},
                                leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: new BoxDecoration(
                                      border: new Border(
                                          right: new BorderSide(width: 1.0, color: Colors.green))),
                                  child: Icon(Icons.book, color: Colors.green),
                                ),

                                title: Row(
                                  children: [
                                    Text('${courseList[index]['courseNumber']}',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                                    //Spacer(flex: 1),
                                    Text('  (${courseList[index]['courseUnits']})',
                                        style: TextStyle(color: Colors.white, fontSize: 18)),
                                    //Spacer(flex: 2,)
                                  ]
                                ),
                                subtitle: Text('${courseList[index]['courseName']}',
                                    style: TextStyle(color: Colors.white, fontSize: 16),),
                                trailing: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30.0),
                                ),
                              ),
                          ),

                          // swipe left to edit and delete the course entry
                          secondaryActions: [
                            // edit the course item
                            Card(
                              elevation: 7,
                              margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: IconSlideAction(
                                caption: 'edit',
                                color: Color(0xff676D65),
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                // on tap, open the edit_planner page
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => EditPlanner(widget.plannerDetails, courseList[index]['courseID'])),
                                  );
                                },
                              ),

                            ),
                            // delete the course item
                            Card(
                              elevation: 7,
                              margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                // on tap, call delete function
                                onTap: () {
                                  deleteEntry(courseList[index]);
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                ),

              ),
            ],
          ],
        ),

        // Button to navigate to the create_planner page
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add, size: 30,),
          label: Text('Add course'),
          backgroundColor: Color(0xff297C13).withOpacity(0.77),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreatePlanner(widget.plannerDetails)),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat, // position of add button
    );
  }
}
