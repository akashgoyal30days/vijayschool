// Home Tab
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:eznext/api_models/online_exam_questions.dart';
import 'package:eznext/api_models/onlineexam.dart';
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/app_constants/pops.dart';
import 'package:eznext/app_constants/popup.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:eznext/screen%20models/viewonlineresult.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:volume_control/volume_control.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../logoutmodel.dart';
import '../main.dart';
import 'examscreen.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class OnlineExam extends StatefulWidget {
  final bool state;

  const OnlineExam({required this.state});

  @override
  _OnlineExamState createState() => _OnlineExamState();
}

class _OnlineExamState extends State<OnlineExam> {
  //--------defining & initialising parameters------------//
  bool State = false;
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
  var oexamlist = [];
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  String finaltodaydate = '';
  var startdatetimelist = [];
  var endexamdatetimelist = [];
  String? currentTime;
  DateTime? parseddate;

  //--------getting date and time---------//
  _watchAllRawEvents() {
    FlutterPhoneState.rawPhoneEvents.forEach((RawPhoneEvent event) {
      final phoneCall = event.isNewCall;
      if (event.type.toString() == 'RawEventType.disconnected') {
        //debugPrint('hi');
      }
      //debugPrint("Got an event $event");
    });
    //debugPrint("That loop ^^ won't end");
  }

  void gdatetime() {
    setState(() {
      currentTime = formatter1.format(DateTime.now());
    });
    //debugPrint(currentTime);
    parseddate = DateTime.parse(currentTime.toString());
    //debugPrint(parseddate.toString());
  }
/*  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    //debugPrint(Duration(hours: hours, minutes: minutes, microseconds: micros).inSeconds.toString());
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }*/

  final _player = ja.AudioPlayer(
    // Handle audio_session events ourselves for the purpose of this demo.
    handleInterruptions: true,
    androidApplyAudioAttributes: true,
    handleAudioSessionActivation: true,
  );

  //--------check currenttime and exam time at time of entering exam------//
  void gdatetime2(
      DateTime start, DateTime end, String eid, String ename, String durate) {
    setState(() {
      currentTime = formatter1.format(DateTime.now());
    });
    // //debugPrint(currentTime);
    parseddate = DateTime.parse(currentTime.toString());
    //debugPrint(parseddate.toString());
    if ((parseddate!.difference(start).inSeconds > 0 ||
            parseddate!.difference(start).inSeconds == 0) &&
        (parseddate!.difference(end).inSeconds < 0 ||
            parseddate!.difference(end).inSeconds == 0)) {
      //parseDuration(durate);
      String ss = durate.replaceAll(':', '');
      List<String> result = ss.split('');
      setState(() {
        //debugPrint(result.toString());
        int durateinsec =
            int.parse(result[0].toString() + result[1].toString()) * 3600 +
                int.parse(result[2].toString() + result[3].toString()) * 60 +
                int.parse(result[4].toString() + result[5].toString());
        //debugPrint(DateFormat('HH:mm:ss').parse(durate).toString());
        //debugPrint('ac'+durateinsec.toString());
        if (end.difference(parseddate!).inSeconds > durateinsec) {
          //debugPrint(end.difference(parseddate!).inSeconds.toString());
          examquest(eid, ename, durateinsec);
        }
        if (end.difference(parseddate!).inSeconds < durateinsec) {
          //debugPrint('hh');
          //debugPrint('dd'+end.difference(parseddate!).inSeconds.toString());
          examquest(eid, ename, end.difference(parseddate!).inSeconds);
          //Toast.show('You are late in exam', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        }
        if (end.difference(parseddate!).inSeconds == durateinsec) {
          //debugPrint('hhs');
          examquest(eid, ename, durateinsec);
        }
      });
      //
    } else {
      Toast.show('Exam time over', context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          backgroundRadius: 5);
      getOnlineExam();
    }
  }

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

  final myKey = new GlobalKey<_OnlineExamState>();
  bool sliding = false;
  double sliderVal = 0;
  double volume = 0;

  @override
  void initState() {
    initVolumeState();

    setState(() {
      State = widget.state;
    });
    gettingSavedData();
    super.initState();
  }

  String examstdid = '';
  double _val = 0.5;

  Future<void> initVolumeState() async {
    if (!mounted) return;

    //read the current volume
    _val = await VolumeControl.setVolume(0.0);
    setState(() {});
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
    getOnlineExam();
  }

  Future getOnlineExam() async {
    try {
      var rsp = await Stud_online_exam(stdid, token.toString(), uid);
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
        if (rsp['onlineexam'] != '' || rsp['onlineexam'] != []) {
          setState(() {
            initialscreen = 'screenloaded';
            oexamlist = rsp['onlineexam'];
            for (var i = 0; i < oexamlist.length; i++) {
              setState(() {
                startdatetimelist.add(DateTime.parse(oexamlist[i]['exam_from'] +
                    ' ' +
                    oexamlist[i]['time_from'] +
                    '.000'));
                endexamdatetimelist.add(DateTime.parse(oexamlist[i]['exam_to'] +
                    ' ' +
                    oexamlist[i]['time_to'] +
                    '.000'));
              });
            }
            //debugPrint(startdatetimelist.toString());
            //debugPrint(endexamdatetimelist.toString());
            gdatetime();
            //debugPrint(parseddate!.difference(startdatetimelist[0]).inMinutes.toString());
          });
        } else {
          setState(() {
            initialscreen = 'no homework found';
          });
        }
      }
      //debugPrint(initialscreen);
    } catch (error) {
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  var questlist = [];

  Future examquest(String examid, String ename, int sec) async {
    try {
      var rsp = await Stud_exam_quest(stdid, examid, token.toString(), uid);
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
        if (rsp['exam'] != null || rsp['exam'] != '') {
          setState(() {
            examstdid = rsp['exam']['onlineexam_student_id'].toString();
            questlist = rsp['exam']['questions'];
            if (questlist.isNotEmpty) {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (BuildContext context) => ExamScreen(
                            ename: ename,
                            quest: questlist,
                            second: sec,
                            esid: examstdid,
                          )));
            }
          });
        }
      }
    } catch (error) {
      //debugPrint(error.toString());
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
          navigationBar: CupertinoNavigationBar(
              leading: Container(),
              middle: Text(
                'Online Exam',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
              backgroundColor: appbarcolor,
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
          child: State == false
              ? Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      initialscreen == 'loader'
                          ? Container(
                              height: MediaQuery.of(context).size.height - 144,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.8,
                                ),
                              ))
                          : initialscreen == 'screenloaded'
                              ? Container(
                                  child: Expanded(
                                    child: ListView.builder(
                                        itemCount: oexamlist.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            child: Card(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors
                                                        .systemGrey5,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Center(
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      oexamlist[
                                                                              index]
                                                                          [
                                                                          'exam'],
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ))),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              ' Date From : ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              formatter
                                                                  .format(DateTime.parse(
                                                                      oexamlist[index]
                                                                              [
                                                                              'exam_from']
                                                                          .toString()))
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      1),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Date To : ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              formatter
                                                                      .format(DateTime.parse(oexamlist[index]
                                                                              [
                                                                              'exam_to']
                                                                          .toString()))
                                                                      .toString() +
                                                                  ' ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      1),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              ' Total Attempts : ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              oexamlist[index][
                                                                      'attempt']
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      1),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              ' Attempted : ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              oexamlist[index][
                                                                          'attempts']
                                                                      .toString() +
                                                                  ' ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      1),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              ' Duration : ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            Text(
                                                              oexamlist[index][
                                                                      'duration']
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      1),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              ' Status : ',
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            if (oexamlist[index]
                                                                    [
                                                                    'is_active'] ==
                                                                '1')
                                                              Text(
                                                                'Available' +
                                                                    ' ',
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    letterSpacing:
                                                                        1),
                                                              )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  if (oexamlist[index]
                                                          ['publish_result'] ==
                                                      '1')
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator
                                                            .pushReplacement(
                                                                context,
                                                                CupertinoPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        OnlineResult(
                                                                          eid: oexamlist[index]
                                                                              [
                                                                              'id'],
                                                                          oesid:
                                                                              oexamlist[index]['onlineexam_student_id'],
                                                                        )));
                                                      },
                                                      child: Text(
                                                        'View' + ' ',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .systemBlue),
                                                      ),
                                                    ),
                                                  if (oexamlist[index]
                                                              ['attempt'] !=
                                                          '0' &&
                                                      int.parse(oexamlist[index]['attempts']) <
                                                          int.parse(oexamlist[index]
                                                              ['attempt']) &&
                                                      oexamlist[index]['publish_result'] !=
                                                          '1' &&
                                                      oexamlist[index]['is_submitted'] !=
                                                          '1' &&
                                                      (parseddate!.difference(startdatetimelist[index]).inSeconds > 0 ||
                                                          parseddate!
                                                                  .difference(
                                                                      startdatetimelist[
                                                                          index])
                                                                  .inSeconds ==
                                                              0) &&
                                                      (parseddate!.difference(endexamdatetimelist[index]).inSeconds < 0 ||
                                                          parseddate!
                                                                  .difference(
                                                                      endexamdatetimelist[index])
                                                                  .inSeconds ==
                                                              0))
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (isinterupted ==
                                                            true) {
                                                          PopUps.showPopDialoguge(
                                                              context,
                                                              myKey,
                                                              "Can't start exam while on call, please decline the call and start the exam",
                                                              'Alert!!');
                                                        } else {
                                                          gdatetime2(
                                                              startdatetimelist[
                                                                  index],
                                                              endexamdatetimelist[
                                                                  index],
                                                              oexamlist[index]
                                                                  ['id'],
                                                              oexamlist[index]
                                                                  ['exam'],
                                                              oexamlist[index]
                                                                  ['duration']);
                                                        }
                                                      },
                                                      child: Text(
                                                        'Start Exam' + ' ',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .systemBlue),
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              : initialscreen == 'error'
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              144,
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
                                          MediaQuery.of(context).size.height -
                                              144,
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
                                  Image.asset(
                                      'assets/dash_icons/examination.png',
                                      height: 30,
                                      width: 30),
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
                )
              : Container(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You were idle during exam',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: CupertinoColors.systemGrey,
                              decoration: TextDecoration.none),
                        ),
                        Text(
                          'so your exam was automatically submitted',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: CupertinoColors.systemGrey,
                              decoration: TextDecoration.none),
                        ),
                        TextButton(
                          child: Text(
                            'OK',
                            style: GoogleFonts.poppins(fontSize: 30),
                          ),
                          onPressed: () {
                            setState(() {
                              State = false;
                            });
                          },
                        )
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
