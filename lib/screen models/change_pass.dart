// Home Tab
import 'package:eznext/api_models/changepasword_api.dart';
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/loader.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class ChangePass extends StatefulWidget {
  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  //--------defining & initialising parameters------------//
  String token = '';
  String stdid = '';
  String student_name = '';
  String class_name = '';
  String School_name = '';
  String section_name = '';
  String student_image = '';
  String roll_number = '';
  String siteurl = '';
  String uid = '';
  String username = '';

  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  FocusNode textSecondFocusNode = new FocusNode();
  //--------html tags remover---------//

  final myKey = new GlobalKey<_ChangePassState>();

  //--------navigation menu bar---------------------//
  void _showPopupMenu() async {
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(600, 80, 0, 100),
        items: [
/*          if(initScreen=='screenloaded')
            PopupMenuItem(
              value: 1,
              child: Center(
                child: Text('Timeline',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),),
              ),
            ),
          if(initScreen=='screenloaded')
            PopupMenuItem(
              value: 2,
              child: Center(
                child: Text('My Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),),
              ),
            ),
          if(initScreen=='screenloaded')
            PopupMenuItem(
              value: 3,
              child: Center(
                child: Text('Teachers',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),),
              ),
            ),*/
          PopupMenuItem(
            value: 4,
            child: Center(
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ]).then((value) {
// NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null

      if (value == 1) {
        setState(() {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => TimeLine()));
        });
      }
      if (value == 2) {
        setState(() {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => MyDocuments()));
        });
      }
      if (value == 3) {
        setState(() {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => TeacherList()));
        });
      }
      if (value == 4) {
        LogOutPopup.shoLogOutPopup(context, myKey);
      }
    });
  }

  @override
  void initState() {
    gettingSavedData();
    super.initState();
  }

  void gettingSavedData() async {
    //-------initialising sharedpreference-----------//
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    SharedPreferences studentdetails = await SharedPreferences.getInstance();

    //-------setting values-----------------------//
    setState(() {
      token = studentdetails.getString('token');
      student_name = studentdetails.getString('username');
      class_name = studentdetails.getString('class');
      section_name = studentdetails.getString('section');
      School_name = studentdetails.getString('sch_name');
      student_image = studentdetails.getString('image');
      siteurl = initialschoolcode.getString('site_url');
      stdid = studentdetails.getString('student_id');
      uid = studentdetails.getString('id');
      username = studentdetails.getString('username');
    });
  }

  Future cpass() async {
    Dialogs.showLoadingDialog(context, myKey, 'Changing password');
    try {
      var rsp = await Stud_change_pass(
          uid,
          oldpasswordController.text,
          newpasswordController.text,
          username,
          confpasswordController.text,
          token.toString(),
          uid);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == 200) {
          logOut(context);
          Toast.show(rsp['message'], context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              backgroundRadius: 5);
        }
        if (rsp['status'] == 401) {
          Navigator.of(context).pop();
          Toast.show(rsp['message'], context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              backgroundRadius: 5);
        }
      }
    } catch (error) {
      //debugPrint(error.toString());
      Navigator.of(context).pop();
      Toast.show(error.toString(), context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          backgroundRadius: 5);
    }
  }

  dynamic unameController = TextEditingController();
  dynamic oldpasswordController = TextEditingController();
  dynamic newpasswordController = TextEditingController();
  dynamic confpasswordController = TextEditingController();
  
  showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.info,
        color: Colors.blue,
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (BuildContext context) => MyHome()));
        return false;
      },
      child: CupertinoPageScaffold(
          backgroundColor: themecolor,
          navigationBar: CupertinoNavigationBar(
              backgroundColor: appbarcolor,
              middle: Text(
                'Change Password',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
              leading: Container(),
              trailing: GestureDetector(
                onTap: () {
                  _showPopupMenu();
                },
                child: Icon(
                  CupertinoIcons.list_bullet,
                  size: 25,
                  color: Colors.white,
                ),
              )),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: Expanded(
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  height: 50,
                                  child: CupertinoTextField(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          new BorderRadius.circular(10.0),
                                    ),
                                    enabled: true,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    controller: oldpasswordController,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    suffix: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        CupertinoIcons.padlock,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    placeholder: "Old Password",
                                    placeholderStyle: GoogleFonts.poppins(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  height: 50,
                                  child: CupertinoTextField(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          new BorderRadius.circular(10.0),
                                    ),
                                    enabled: true,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    controller: newpasswordController,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    suffix: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        CupertinoIcons.padlock,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    placeholder: "New Password",
                                    placeholderStyle: GoogleFonts.poppins(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  height: 50,
                                  child: CupertinoTextField(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          new BorderRadius.circular(10.0),
                                    ),
                                    enabled: true,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    controller: confpasswordController,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    suffix: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        CupertinoIcons.padlock,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    placeholder: "Confirm Password",
                                    placeholderStyle: GoogleFonts.poppins(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ),
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  color: CupertinoColors.systemBlue,
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    onPressed: () {
                      if (oldpasswordController.text.isNotEmpty &&
                          newpasswordController.text.isNotEmpty &&
                          confpasswordController.text.isNotEmpty) {
                        if (oldpasswordController.text ==
                            newpasswordController.text) {
                          showPrintedMessage('error',
                              'Old password should not be equal to new password');
                        }
                        if (oldpasswordController.text ==
                            confpasswordController.text) {
                          showPrintedMessage('error',
                              'Old password should not be equal to confirm password');
                        }
                        if (newpasswordController.text !=
                            confpasswordController.text) {
                          showPrintedMessage('error',
                              'new password and confirm password does not matched');
                        }
                        if (confpasswordController.text ==
                                oldpasswordController.text ||
                            newpasswordController.text ==
                                oldpasswordController.text) {
                          showPrintedMessage('error',
                              'new password , confirm password and old password should not be same');
                        } else {
                          cpass();
                        }
                      } else {
                        showPrintedMessage('error', 'Please fill every field');
                      }
                    },
                    child: Text(
                      'SUBMIT',
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: CupertinoColors.white),
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  color: bottombar,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    builder: (BuildContext context) =>
                                        MyHome()));
                          },
                          child: Column(children: [
                            //Icon(CupertinoIcons.home,color: botoomiconselectedcolor,),
                            Image.asset(
                              'assets/home.png',
                              height: 30,
                              width: 30,
                            ),
                            Text(
                              'Home',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: botoomiconunselectedcolor,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (modulelist[2]['is_active'] == '1') {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) =>
                                          Homework()));
                            } else {
                              showPrintedMessage(
                                  'Oops!!', 'This module is disabled by admin');
                            }
                          },
                          child: Column(children: [
                            // Icon(CupertinoIcons.book,color: botoomiconunselectedcolor,),
                            Image.asset(
                              'assets/dash_icons/homework.png',
                              height: 30,
                              width: 30,
                            ),
                            Text(
                              'Homework',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: botoomiconunselectedcolor,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (modulelist[0]['is_active'] == '1') {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) =>
                                          Fees()));
                            } else {
                              showPrintedMessage(
                                  'Oops!!', 'This module is disabled by admin');
                            }
                          },
                          child: Column(children: [
                            //Icon(CupertinoIcons.money_dollar_circle,color: botoomiconunselectedcolor,),
                            //Image.asset('assets/fee.png', height: 40,width: 40,),
                            Container(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                heroTag: null,
                                elevation: 0,
                                onPressed: null,
                                child: Text(
                                  '₹',
                                  style: GoogleFonts.play(
                                      fontSize: 28,
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Text(
                              'Fees',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: botoomiconunselectedcolor,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (modulelist[6]['is_active'] == '1') {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) =>
                                          NoticeBoard()));
                            } else {
                              showPrintedMessage(
                                  'Oops!!', 'This module is disabled by admin');
                            }
                          },
                          child: Column(children: [
                            //  Icon(CupertinoIcons.info,color: botoomiconunselectedcolor,),
                            Image.asset('assets/dash_icons/notice.png',
                                height: 30, width: 30),
                            Text(
                              'Notice',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: botoomiconunselectedcolor,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (modulelist[5]['is_active'] == '1') {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) =>
                                          StudenExam()));
                            } else {
                              showPrintedMessage(
                                  'Oops!!', 'This module is disabled by admin');
                            }
                          },
                          child: Column(children: [
                            // Icon(CupertinoIcons.doc_append,color: botoomiconunselectedcolor,),
                            Image.asset('assets/dash_icons/examination.png',
                                height: 30, width: 30),
                            Text(
                              'Exam',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: botoomiconunselectedcolor,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
