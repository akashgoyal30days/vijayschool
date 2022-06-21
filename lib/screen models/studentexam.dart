import 'package:eznext/api_models/exam.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/noticeboard.dart';
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

class StudenExam extends StatefulWidget {
  @override
  _StudenExamState createState() => _StudenExamState();
}

class _StudenExamState extends State<StudenExam> {
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
  var examlist = [];
  var schedulelist = [];
  var scheduleresult = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  String afterloadingscreen = 'elist';

  final myKey = new GlobalKey<_StudenExamState>();

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
    getExamlist();
  }

  var stdreslt;

  Future getExamlist() async {
    try {
      var rsp = await Stud_exam_list(stdid, token.toString(), uid);
      //debugPrint(rsp.toString());
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
        if (rsp['examSchedule'] != null) {
          setState(() {
            examlist = rsp['examSchedule'];
            initialscreen = 'screenloaded';
          });
          if (rsp['examSchedule'].isEmpty) {
            setState(() {
              initialscreen = 'no homework found';
            });
          }
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

  Future getExamSchdeule(String egrpid) async {
    setState(() {
      initialscreen = 'loader';
    });
    try {
      var rsp = await Stud_exam_schedule(egrpid, token.toString(), uid);
      //debugPrint(rsp.toString());
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
        if (rsp['exam_subjects'] != null) {
          setState(() {
            schedulelist = rsp['exam_subjects'];
            afterloadingscreen = 'eschedule';
            initialscreen = 'screenloaded';
          });
        } else {
          setState(() {
            afterloadingscreen = 'elist';
            initialscreen = 'screenloaded';
            Toast.show('No exams scheduled', context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                backgroundRadius: 5);
          });
        }
      }
    } catch (error) {
      setState(() {
        afterloadingscreen = 'elist';
        initialscreen = 'screenloaded';
        Toast.show('Unable to get scheduled exams', context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            backgroundRadius: 5);
      });
    }
  }

  Future getExamResult(String egrpid) async {
    setState(() {
      initialscreen = 'loader';
    });
    try {
      var rsp = await Stud_exam_result(egrpid, stdid, token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == 401) {
          logOut(context);
          Toast.show(unautherror, context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              backgroundRadius: 5);
        } else {
          if (rsp['exam'] != null) {
            setState(() {
              stdreslt = rsp['exam'];
              scheduleresult = stdreslt['subject_result'];
              afterloadingscreen = 'reportcard';
              initialscreen = 'screenloaded';
            });
          } else {
            setState(() {
              afterloadingscreen = 'elist';
              initialscreen = 'screenloaded';
              Toast.show('No exams scheduled', context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.BOTTOM,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  backgroundRadius: 5);
            });
          }
        }
      }
    } catch (error) {
      setState(() {
        afterloadingscreen = 'elist';
        initialscreen = 'screenloaded';
        Toast.show('Unable to get results', context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            backgroundRadius: 5);
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
      child: Scaffold(
        backgroundColor: themecolor,
        appBar: AppBar(
          leading: afterloadingscreen != 'elist'
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      afterloadingscreen = 'elist';
                      schedulelist = [];
                    });
                  },
                  child: Icon(
                    CupertinoIcons.back,
                    color: CupertinoColors.white,
                  ))
              : Container(),
          backgroundColor: appbarcolor,
          elevation: 0,
          title: afterloadingscreen == 'elist'
              ? Text(
                  'Examination',
                  style: GoogleFonts.poppins(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                )
              : afterloadingscreen == 'reportcard'
                  ? Text(
                      'Report Card',
                      style: GoogleFonts.poppins(
                          color: CupertinoColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    )
                  : afterloadingscreen == 'eschedule'
                      ? Text(
                          'Exam Schedule',
                          style: GoogleFonts.poppins(
                              color: CupertinoColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        )
                      : Text(
                          'Examination',
                          style: GoogleFonts.poppins(
                              color: CupertinoColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
          actions: [
            GestureDetector(
              onTap: () {
                _showPopupMenu();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(
                  CupertinoIcons.list_bullet,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
            )
          ],
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              initialscreen == 'loader'
                  ? Container(
                      height: MediaQuery.of(context).size.height - 161,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.8,
                        ),
                      ))
                  : initialscreen == 'screenloaded'
                      ? Container(
                          child: Expanded(
                            child: afterloadingscreen == 'elist'
                                ? ListView.builder(
                                    itemCount: examlist.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        height: 88,
                                        child: Card(
                                          elevation: 2,
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                color:
                                                    CupertinoColors.systemGrey5,
                                                child: Center(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Icon(
                                                              CupertinoIcons
                                                                  .doc_append,
                                                              size: 20,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              examlist[index]
                                                                      ['exam']
                                                                  .toUpperCase(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ))),
                                              ),
                                              Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                color: CupertinoColors.white,
                                                child: Center(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            if (examlist[index][
                                                                    'result_publish'] ==
                                                                '1')
                                                              Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Icon(
                                                                    CupertinoIcons
                                                                        .doc_append,
                                                                    size: 20,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          getExamResult(
                                                                              examlist[index]['exam_group_class_batch_exam_id'].toString());
                                                                        });
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        'Exam result',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: CupertinoColors.systemBlue),
                                                                      )),
                                                                ],
                                                              ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .doc_append,
                                                                  size: 20,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      getExamSchdeule(examlist[index]
                                                                              [
                                                                              'exam_group_class_batch_exam_id']
                                                                          .toString());
                                                                    },
                                                                    child: Text(
                                                                      'Exam schedule',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              CupertinoColors.systemBlue),
                                                                    )),
                                                              ],
                                                            )
                                                          ],
                                                        ))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                : afterloadingscreen == 'reportcard'
                                    ? Container(
                                        child: Column(
                                          children: [
                                            if (stdreslt != null)
                                              Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color:
                                                    CupertinoColors.systemGrey5,
                                                child: Row(
                                                  children: [
                                                    Center(
                                                        child: Text(
                                                      '  ' +
                                                          stdreslt['exam']
                                                              .toUpperCase(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            if (stdreslt != null)
                                              Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      child: Text(
                                                        '  ' + 'Subject',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      child: Text(
                                                        '  Passing\n   Marks',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                    ),
                                                    Container(
                                                        width: 70,
                                                        child: Text(
                                                          '  ' +
                                                              '\nMarks\nObtained',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        )),
                                                    Container(
                                                      width: 60,
                                                      child: Center(
                                                          child: Text(
                                                        'Result' + '  ',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            Divider(),
                                            Container(
                                              height: 160,
                                              child: ListView.builder(
                                                  itemCount:
                                                      scheduleresult.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          index) {
                                                    return Container(
                                                      child: Container(
                                                        height: 50,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              width: 60,
                                                              child: Text(
                                                                '  ' +
                                                                    scheduleresult[
                                                                            index]
                                                                        [
                                                                        'name'],
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 50,
                                                              child: Text(
                                                                '  ' +
                                                                    scheduleresult[index]
                                                                            [
                                                                            'min_marks']
                                                                        .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 100,
                                                              child: Text(
                                                                '  ' +
                                                                    scheduleresult[index]
                                                                            [
                                                                            'get_marks']
                                                                        .toString() +
                                                                    '/' +
                                                                    scheduleresult[index]
                                                                            [
                                                                            'max_marks']
                                                                        .toString(),
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            if (double.tryParse(
                                                                    scheduleresult[
                                                                            index]
                                                                        [
                                                                        'min_marks'])! >
                                                                double.tryParse(
                                                                    scheduleresult[
                                                                            index]
                                                                        [
                                                                        'get_marks'])!)
                                                              Container(
                                                                height: 30,
                                                                width: 60,
                                                                color: CupertinoColors
                                                                    .systemRed,
                                                                child: Center(
                                                                  child: Text(
                                                                    'Fail',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12,
                                                                        color: CupertinoColors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              )
                                                            else
                                                              Container(
                                                                height: 30,
                                                                width: 60,
                                                                color: CupertinoColors
                                                                    .activeGreen,
                                                                child: Center(
                                                                  child: Text(
                                                                    'Pass',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            12,
                                                                        color: CupertinoColors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                            Container(
                                              height: 80,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: CupertinoColors.systemBlue,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Grand Total : ',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                            Text(
                                                              stdreslt['total_get_marks']
                                                                      .toString() +
                                                                  '/' +
                                                                  stdreslt[
                                                                          'total_max_marks']
                                                                      .toString(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Percentage : ',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                            stdreslt['percentage'] !=
                                                                    ''
                                                                ? Text(
                                                                    double.tryParse(stdreslt['percentage'].toString())!
                                                                            .toStringAsFixed(2) +
                                                                        ' ' +
                                                                        '%',
                                                                    style: GoogleFonts.poppins(
                                                                        color: CupertinoColors
                                                                            .white,
                                                                        fontSize:
                                                                            12),
                                                                  )
                                                                : stdreslt['percentage'] !=
                                                                        null
                                                                    ? Text(
                                                                        '',
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                CupertinoColors.white,
                                                                            fontSize: 12),
                                                                      )
                                                                    : Text(
                                                                        '',
                                                                        style: GoogleFonts.poppins(
                                                                            color:
                                                                                CupertinoColors.white,
                                                                            fontSize: 12),
                                                                      )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Division : ',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                            Text(
                                                              stdreslt[
                                                                      'division']
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Result : ',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                            Container(
                                                              height: 30,
                                                              width: 70,
                                                              color: stdreslt[
                                                                          'exam_result_status'] ==
                                                                      'pass'
                                                                  ? CupertinoColors
                                                                      .activeGreen
                                                                  : CupertinoColors
                                                                      .systemRed,
                                                              child: Center(
                                                                child: Text(
                                                                  stdreslt[
                                                                          'exam_result_status']
                                                                      .toString()
                                                                      .toUpperCase(),
                                                                  style: GoogleFonts.poppins(
                                                                      color: CupertinoColors
                                                                          .white,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        child: ListView.builder(
                                            itemCount: schedulelist.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Container(
                                                child: Card(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        color: CupertinoColors
                                                            .systemGrey5,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Center(
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    schedulelist[index]
                                                                            [
                                                                            'subject_name'] +
                                                                        ' (' +
                                                                        schedulelist[index]
                                                                            [
                                                                            'subject_code'] +
                                                                        ')',
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ))),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 47,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(CupertinoIcons
                                                                        .calendar),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          ' Date',
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                        Text(
                                                                          formatter
                                                                              .format(DateTime.parse(schedulelist[index]['date_from'].toString()))
                                                                              .toString(),
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(CupertinoIcons
                                                                        .clock),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          ' Start time',
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                        Text(
                                                                          schedulelist[index]['time_from']
                                                                              .toString(),
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        height: 47,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    10,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(Icons
                                                                        .door_back_door_outlined),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          ' Room No.',
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                        Text(
                                                                          '  ' +
                                                                              schedulelist[index]['room_no'].toString(),
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        height: 47,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4.4,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(CupertinoIcons
                                                                        .clock),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          ' Duration',
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                        Text(
                                                                          ' ' +
                                                                              schedulelist[index]['duration'].toString().toString(),
                                                                          style:
                                                                              GoogleFonts.poppins(fontSize: 13),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4.4,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      ' Max Marks',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                    Text(
                                                                      '  ' +
                                                                          schedulelist[index]['max_marks']
                                                                              .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ],
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4.4,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      ' Min Marks',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                    Text(
                                                                      schedulelist[index]
                                                                              [
                                                                              'min_marks']
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ],
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4.4,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      ' Credit Hrs',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                    Text(
                                                                      schedulelist[index]
                                                                              [
                                                                              'credit_hours']
                                                                          .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                          ),
                        )
                      : initialscreen == 'error'
                          ? Container(
                              height: MediaQuery.of(context).size.height - 161,
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
                              height: MediaQuery.of(context).size.height - 161,
                              child: Center(
                                child: Text(
                                  'No exams',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      color: CupertinoColors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                              )),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
                            builder: (BuildContext context) => MyHome()));
                  },
                  child: Column(children: [
                    // Icon(CupertinoIcons.home,color: botoomiconunselectedcolor,),
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
                              builder: (BuildContext context) => Homework()));
                    } else {
                      showPrintedMessage(
                          'Oops!!', 'This module is disabled by admin');
                    }
                  },
                  child: Column(children: [
                    //Icon(CupertinoIcons.book,color: botoomiconunselectedcolor,),
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
                              builder: (BuildContext context) => Fees()));
                    } else {
                      showPrintedMessage(
                          'Oops!!', 'This module is disabled by admin');
                    }
                  },
                  child: Column(children: [
                    //Icon(CupertinoIcons.money_dollar_circle,color: botoomiconunselectedcolor,),
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
                    //Icon(CupertinoIcons.info,color: botoomiconunselectedcolor,),
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
                  onTap: () {},
                  child: Column(children: [
                    //Icon(CupertinoIcons.doc_append,color: botoomiconselectedcolor,),
                    Image.asset('assets/dash_icons/examination.png',
                        height: 30, width: 30),
                    Text(
                      'Exam',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: botoomiconselectedcolor,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
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
