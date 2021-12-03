import 'package:course_planner/planner_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'login_page.dart';

// Home Page
class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? semesterVal; // semester controller
  var yearController = TextEditingController(); // year controller
  String _errorMessage= ''; // for error message
  final GlobalKey<FormState> _key = GlobalKey<FormState>(); // for adding entry
  final GlobalKey<FormState> _newkey = GlobalKey<FormState>(); // for updating entry
  final userid = FirebaseAuth.instance.currentUser!.uid; // current user's id
  var userName ='';
  //var entryID = Uuid();// unique id for the entry
  var plannerList = [];

  // constructor - refreshes the content based on the changes in Firebase database
  _HomePageState() {
    refreshPlannerList();
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner').onChildChanged.listen((event) {
      refreshPlannerList();
    });
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner').onChildAdded.listen((event) {
      refreshPlannerList();
    });
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner').onChildRemoved.listen((event) {
      refreshPlannerList();
    });
   }

  // method to refresh the content on Home Screen
  void refreshPlannerList() {

    // load data from firebase
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/planner').once()
        .then((ds) {
      var tempPlannerList = [];
      ds.value.forEach((k,v){
        tempPlannerList.add(v);
      });
      plannerList = tempPlannerList;
      setState(() {

      });
    }).catchError((error){
      print(error);
    });
  }

  // method to get the name of a user
  String fetchName (){
    FirebaseDatabase.instance.reference().child('users/${userid.toString()}/userInfo/name').
    once().then((DataSnapshot datasnap) {
      setState(() {
        userName = datasnap.value;
      });
    });
    return userName;
  }

  // method to validate the year
  String? validateYear(String? formYear) {
    if (formYear == null || formYear.isEmpty) {
      return 'Year is required!';
    }
    else if (!RegExp(r'^(20)\d{2}$').hasMatch(formYear)) {
      return 'Invalid year format!';
    }
    else if (formYear.length == 4) {
      for (var map in plannerList) {
        if(map['semester'] == semesterVal && map['year'] == yearController.text){
          return 'The term already exists!';
        }
      }
    }
    else {
      return null;
    }
  }

  // method to delete the listview entry
  void deleteEntry(entry) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this term?'),
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
                        .child("users/${userid.toString()}/planner/term-${entry['entry_key']}").remove().
                    then((value) {
                      // show deletion message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor:  Color(0xff48638f),
                            content: Text('The term is deleted!', style: TextStyle(fontSize: 16),)),
                      );
                    }).catchError((error){
                      print(error);
                    });
                    setState(() {
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

  // method to edit selected term
  void editEntry(entry) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Edit Term'),
            content: Padding(
                padding: EdgeInsets.all(8),
                child: Form(
                    key: _newkey,
                   // autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.library_books),
                              errorStyle: TextStyle(fontSize: 15.5)
                          ),
                          hint: Text('Semester'),
                          items: <String>['Fall', 'Spring', 'Summer'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              semesterVal = newValue!;
                            });
                          },
                          validator: (value) => value == null ? 'Please select semester.' : null,
                        ),
                        TextFormField(
                          validator: validateYear,
                          controller: yearController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                              labelText: 'Year',
                              prefixIcon: Icon(Icons.date_range),
                              errorStyle: TextStyle(fontSize: 15.5)
                          ),
                          onChanged: (String? newValue) {
                          },
                        ),
                      ],
                    ))),
            actions: [

              ElevatedButton(
                onPressed: () {
                  if (_newkey.currentState!.validate()) {

                    // close alert box and update the entry
                    Navigator.pop(context);
                    FirebaseDatabase.instance.reference()
                        .child("users/${userid.toString()}/planner/term-${entry['entry_key']}").update(
                        {
                          'semester' : semesterVal,
                          'year' : yearController.text,
                          'entry_key' : entry['entry_key']
                    }).then((value) {
                      // show message on SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor:  Color(0xff48638f),
                            content: Text('Term updated successfully!', style: TextStyle(fontSize: 16),)),
                      );
                      yearController.clear();
                    }).catchError((error){
                      print(error);
                    });
                    setState(() {
                    }
                    );
                  }
                },
                child: Text('Enter'),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xff297C13), // background
                    onPrimary: Colors.white,
                    textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${fetchName()}',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xff297C13),
        elevation: 5.0,
        leading: Icon(
          Icons.home,
          size: 30,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
            onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Log Out'),
                    content: Text('Do you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
               });

            },
          )
        ],
      ),
      body:
           Scrollbar(
             thickness: 8,
             isAlwaysShown: true,
             child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: plannerList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Card(
                      elevation: 7,
                      margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(color: Color(0xff297C13)),
                        child: ListTile(
                          onTap: () {
                            //print(plannerList[index]);
                            Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => PlannerDetails(plannerList[index])),
                            );
                          },
                          leading: Container(
                            padding: EdgeInsets.only(right: 12.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(width: 1.0, color: Colors.green))),
                            child: Icon(MdiIcons.calendarText, color: Colors.green),
                          ),
                          title: Text('${plannerList[index]['semester']} - ${plannerList[index]['year']}',
                                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                          trailing: Icon(MdiIcons.chevronLeft, color: Colors.white, size: 28,),
                        ),
                      ),
                    ),
                    secondaryActions: [
                      Card(
                        elevation: 7,
                        margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: IconSlideAction(
                          caption: 'edit',
                          color: Color(0xff676D65),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          onTap: () { editEntry(plannerList[index]);
                          },
                        ),

                      ),
                      Card(
                        elevation: 7,
                        margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          onTap: () {
                            deleteEntry(plannerList[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }),
           ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Add new term'),
                  content: Padding(
                      padding: EdgeInsets.all(8),
                      child: Form(
                          key: _key,
                         // autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                            DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                prefixIcon: Icon(MdiIcons.clipboardEditOutline, color: Color(0xff297C13),),
                                errorStyle: TextStyle(fontSize: 15.5)
                            ),
                            hint: Text('Semester'),
                            items: <String>['Fall', 'Spring', 'Summer'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                semesterVal = newValue!;
                              });
                            },
                              validator: (value) => value == null ? 'Please select semester.' : null,
                          ),
                          TextFormField(
                            validator: validateYear,
                            controller: yearController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              labelText: 'Year',
                              prefixIcon: Icon(Icons.date_range, color: Color(0xff297C13),),
                              errorStyle: TextStyle(fontSize: 15.5)
                            ),
                            onChanged: (String? newValue) {
                            },
                          ),
                        ],
                      ))),
                  actions: [

                    // validate the user entry. Check if entry already exists in the databse
                    ElevatedButton(
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          // close alert box and save the input in database
                          Navigator.pop(context);
                          var uniqueEntryID = DateTime.now().millisecondsSinceEpoch;
                          FirebaseDatabase.instance.reference()
                              .child('users/${userid.toString()}/planner/term-${uniqueEntryID.toString()}').set(
                              {
                                'semester' : semesterVal,
                                'year' : yearController.text,
                                'entry_key' : uniqueEntryID
                              }).then((value) {
                            // show message on SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor:  Color(0xff48638f),
                                  content: Text('Entry added successfully!', style: TextStyle(fontSize: 16),)),
                            );
                            yearController.clear();
                          }).catchError((error){
                            print(error);
                          });
                          setState(() {
                          });
                        }
                        },
                      child: Text('Enter'),
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff297C13), // background
                          onPrimary: Colors.white,
                          textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                );
              });
        },
        // background color of the button
        backgroundColor: Colors.green.withOpacity(0.85),
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,

    );
  }
}



