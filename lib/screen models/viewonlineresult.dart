// Home Tab
import 'dart:ui';

import 'package:eznext/api_models/onlineexamresult.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/online_class.dart';
import 'package:eznext/screen%20models/online_exam.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class OnlineResult extends StatefulWidget {
  final String oesid;
  final String eid;
  const OnlineResult({required this.oesid, required this.eid});
  @override
  _OnlineResultState createState() => _OnlineResultState();
}

class _OnlineResultState extends State<OnlineResult> {
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
  String initialscreen = 'loader';
  var timetablelist;
  var monday = [];
  var tuesday = [];
  var wednesday = [];
  var thursday = [];
  var friday = [];
  var saturday = [];
  var sunday = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';

  final myKey = new GlobalKey<_OnlineResultState>();
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
    });
    getResult();
  }

  List questresult = [];
  var exam;

  Future getResult() async {
    try {
      var rsp = await Stud_onlineexam_result(
          widget.oesid, widget.eid, token.toString(), uid);
      // //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == 401) {
          logOut(context);
          Toast.show(unautherror, context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              backgroundRadius: 5);
        }
      } else {
        if (rsp['result'] != null || rsp['result'] != '') {
          setState(() {
            exam = rsp['result']['exam'];
            questresult = rsp['result']['question_result'];
            initialscreen = 'screenloaded';
          });
          //debugPrint(exam.toString());
        } else {
          setState(() {
            initialscreen = 'no homework found';
          });
        }
      }
    } catch (error) {
      setState(() {
        initialscreen = 'error';
      });
    }
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
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(
                'Online Exam Result',
                style: GoogleFonts.poppins(color: CupertinoColors.white),
              ),
              backgroundColor: appbarcolor,
              leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => OnlineExam(
                                state: false,
                              )));
                },
                icon: Icon(
                  CupertinoIcons.back,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  initialscreen == 'loader'
                      ? Container(
                          height: MediaQuery.of(context).size.height - 155,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.8,
                            ),
                          ))
                      : initialscreen == 'screenloaded'
                          ? Container(
                              height: MediaQuery.of(context).size.height - 161,
                              child: Column(
                                children: [
                                  Container(
                                    height: 170,
                                    width: MediaQuery.of(context).size.width,
                                    child: Card(
                                      color: CupertinoColors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  ' ' + 'Exam :',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  ' ' + exam['exam'],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Exam From :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          formatter.format(
                                                              DateTime.parse(exam[
                                                                      'exam_from']
                                                                  .toString())),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Exam To :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          formatter.format(
                                                              DateTime.parse(exam[
                                                                      'exam_to']
                                                                  .toString())) +
                                                          ' ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Total Attempt :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' + exam['attempt'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Duration :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' + exam['duration'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Passing (%) :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          exam[
                                                              'passing_percentage'] +
                                                          ' ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Total Questions :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          exam['total_question']
                                                              .toString(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Correct :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          exam['correct_ans']
                                                              .toString(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Wrong :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          exam['wrong_ans']
                                                              .toString() +
                                                          ' ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Not Attempted :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          exam['not_attempted']
                                                              .toString(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' ' + 'Score (%) :',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    Text(
                                                      ' ' +
                                                          exam['score']
                                                              .toString() +
                                                          ' ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: questresult.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Card(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Html(
                                                    data: questresult[index]
                                                        ['question'],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          questresult[index]
                                                              ['subject_name'],
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        RaisedButton(
                                                          onPressed: null,
                                                          disabledColor: questresult[
                                                                          index][
                                                                      'select_option'] ==
                                                                  null
                                                              ? CupertinoColors
                                                                  .activeOrange
                                                              : questresult[index]['select_option'] !=
                                                                          '' &&
                                                                      questresult[index]['select_option'] !=
                                                                          questresult[index][
                                                                              'correct']
                                                                  ? CupertinoColors
                                                                      .systemRed
                                                                  : questresult[index]['select_option'] != '' &&
                                                                          questresult[index]['select_option'] ==
                                                                              questresult[index][
                                                                                  'correct']
                                                                      ? CupertinoColors
                                                                          .activeGreen
                                                                      : CupertinoColors
                                                                          .white,
                                                          child: questresult[
                                                                          index]
                                                                      [
                                                                      'select_option'] ==
                                                                  null
                                                              ? Text(
                                                                  'Not Attempted',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      color: CupertinoColors
                                                                          .white),
                                                                )
                                                              : questresult[index]['select_option'] !=
                                                                          '' &&
                                                                      questresult[index]['select_option'] !=
                                                                          questresult[index]
                                                                              [
                                                                              'correct']
                                                                  ? Text(
                                                                      'Wrong',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              CupertinoColors.white),
                                                                    )
                                                                  : questresult[index]['select_option'] !=
                                                                              '' &&
                                                                          questresult[index]['select_option'] ==
                                                                              questresult[index]['correct']
                                                                      ? Text(
                                                                          'Correct',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: CupertinoColors.white),
                                                                        )
                                                                      : Text(
                                                                          '',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 13,
                                                                              color: CupertinoColors.white),
                                                                        ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            )
                          : initialscreen == 'error'
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height - 155,
                                  child: Center(
                                    child: Text(
                                      'Nothing to show',
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                          color: CupertinoColors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ))
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height - 155,
                                  child: Center(
                                    child: Text(
                                      'No timetable available',
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                          color: CupertinoColors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  )),
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
                                showPrintedMessage('Oops!!',
                                    'This module is disabled by admin');
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
                                showPrintedMessage('Oops!!',
                                    'This module is disabled by admin');
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
                                showPrintedMessage('Oops!!',
                                    'This module is disabled by admin');
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
                                showPrintedMessage('Oops!!',
                                    'This module is disabled by admin');
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
            ),
          )),
    );
  }

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
}
