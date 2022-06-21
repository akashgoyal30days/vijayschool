// Home Tab
import 'package:eznext/api_models/attendance_details.dart';
import 'package:eznext/api_models/onlineclassapi.dart';
import 'package:eznext/api_models/onlineexam.dart';
import 'package:eznext/app_constants/constants.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logoutmodel.dart';
import 'classwebview.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class OnlineClass extends StatefulWidget {
  @override
  _OnlineClassState createState() => _OnlineClassState();
}

class _OnlineClassState extends State<OnlineClass> {
  //--------defining & initialising parameters------------//
  var startindex = 0;
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
  String cid = '';
  String admn = '';
  String initialscreen = 'loader';
  var oclasslist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat formatter2 = DateFormat('yyyy-MM-dd');
  bool istimetableloaded = false;
  String hwrkdet = '';
  int initpage = 0;
  String? currentTime;
  DateTime? parseddate;
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');

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

  void gdatetime() {
    setState(() {
      currentTime = formatter1.format(DateTime.now());
    });
    //debugPrint(currentTime);
    parseddate = DateTime.parse(currentTime.toString());
    //debugPrint(parseddate.toString());
  }

  final myKey = new GlobalKey<_OnlineClassState>();

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

  Future<bool> webViewMethod() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.microphone);
    }
    WebViewMethodForCamera();
    return permission == PermissionStatus.granted;
  }

  Future<bool> WebViewMethodForCamera() async {
    var permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.camera]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.camera);
    }
    return permission == PermissionStatus.granted;
  }

  @override
  void initState() {
    setState(() {
      controller = PageController(initialPage: initpage);
    });
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
      cid = studentdetails.getString('class_id');
      admn = studentdetails.getString('admission_no');
    });
    webViewMethod();
    getOnlineClass();
    //debugPrint(admn);
  }

  Future getOnlineClass() async {
    try {
      var rsp = await Stud_online_class(stdid, token.toString(), uid);
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
        if (rsp['liveclasslist'].isNotEmpty) {
          setState(() {
            initialscreen = 'screenloaded';
            oclasslist = rsp['liveclasslist'];
            gdatetime();
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

  Future MarkAtt(String clsid) async {
    try {
      var rsp = await Stud_attendance_mark(admn, clsid,
          formatter1.format(DateTime.now()), token.toString(), uid);
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
      } else {}
    } catch (error) {
      //debugPrint(error.toString());
    }
  }

  PageController? controller;

  void changescreen(int scr) {
    setState(() {
      controller = PageController(initialPage: scr);
    });
  }

  Future<void> _launchURL(command) async {
    //debugPrint(command.toString());
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      //debugPrint(' could not launch $command');
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
              backgroundColor: appbarcolor,
              middle: Text(
                'Online Class',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
              leading: Container(),
              trailing: GestureDetector(
                onTap: () {
                  _showPopupMenu();
                },
                child: Icon(
                  CupertinoIcons.list_bullet,
                  color: Colors.white,
                  size: 25,
                ),
              )),
          child: Scaffold(
            backgroundColor: themecolor,
            body: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  initialscreen == 'loader'
                      ? Container(
                          height: MediaQuery.of(context).size.height - 205,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.8,
                            ),
                          ))
                      : initialscreen == 'screenloaded'
                          ? Container(
                              child: Expanded(
                                child: PageView.builder(
                                    allowImplicitScrolling: true,
                                    itemCount: 2,
                                    scrollDirection: Axis.horizontal,
                                    controller: controller,
                                    onPageChanged: (v) {
                                      setState(() {
                                        startindex = v;
                                        gdatetime();
                                      });
                                    },
                                    itemBuilder: (context, position) {
                                      return startindex == 0
                                          ? ListView.builder(
                                              itemCount: oclasslist.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: parseddate!
                                                                  .difference(DateTime.parse(
                                                                      oclasslist[
                                                                              index]
                                                                          [
                                                                          'start_date']))
                                                                  .inSeconds >
                                                              0 ||
                                                          parseddate!
                                                                  .difference(DateTime.parse(
                                                                      oclasslist[
                                                                              index]
                                                                          [
                                                                          'start_date']))
                                                                  .inSeconds ==
                                                              0
                                                      ? Card(
                                                          child: Column(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color: CupertinoColors
                                                                  .systemGrey5,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    ' ' +
                                                                        oclasslist[index]
                                                                            [
                                                                            'subject_name'],
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  (parseddate!.difference(DateTime.parse(oclasslist[index]['start_date'])).inSeconds > 0 ||
                                                                              parseddate!.difference(DateTime.parse(oclasslist[index]['start_date'])).inSeconds ==
                                                                                  0) &&
                                                                          (parseddate!.difference(DateTime.parse(oclasslist[index]['end_date'])).inSeconds < 0 ||
                                                                              parseddate!.difference(DateTime.parse(oclasslist[index]['end_date'])).inSeconds == 0)
                                                                      ? Container(
                                                                          width:
                                                                              50,
                                                                          child: TextButton(
                                                                              onPressed: () {
                                                                                //  _launchURL(oclasslist[index]['join_url']);
                                                                                if (oclasslist[index]['platform'] == 'Zoom') {
                                                                                  MarkAtt(oclasslist[index]['class_id']);
                                                                                  _launchURL(oclasslist[index]['start_url']);
                                                                                }
                                                                                if (oclasslist[index]['platform'] == 'GoogleMeet') {
                                                                                  MarkAtt(oclasslist[index]['class_id']);
                                                                                  _launchURL('https://' + oclasslist[index]['join_url'].toString().replaceAll('https://', ''));
                                                                                }
                                                                                if (oclasslist[index]['platform'] == 'Jitsi') {
                                                                                  MarkAtt(oclasslist[index]['class_id']);
                                                                                  if (schoolcode == '') {
                                                                                    Navigator.pushReplacement(
                                                                                        context,
                                                                                        CupertinoPageRoute(
                                                                                            builder: (BuildContext context) => Class_Web(
                                                                                                  urii: siteurl + 'mclass/joinclass/' + oclasslist[index]['id'] + '/' + stdid,
                                                                                                )));
                                                                                  } else {
                                                                                    Navigator.pushReplacement(
                                                                                        context,
                                                                                        CupertinoPageRoute(
                                                                                            builder: (BuildContext context) => Class_Web(
                                                                                                  urii: 'https://' + schoolcode + '.eznext.in/' + 'mclass/joinclass/' + oclasslist[index]['id'] + '/' + stdid,
                                                                                                )));
                                                                                  }
                                                                                }
                                                                              },
                                                                              child: Icon(
                                                                                CupertinoIcons.videocam_circle_fill,
                                                                                size: 30,
                                                                                color: CupertinoColors.activeGreen,
                                                                              )),
                                                                        )
                                                                      : Container(),
                                                                  Container(
                                                                    child:
                                                                        Flexible(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  ' ' + 'Start Date : ',
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  ' ' + formatter.format(DateTime.parse(oclasslist[index]['start_date'].toString())).toString(),
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  ' ' + 'End Date : ',
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  ' ' + formatter.format(DateTime.parse(oclasslist[index]['end_date'].toString())).toString(),
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  ' ' + 'Start Time : ',
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  oclasslist[index]['start_date'].toString().replaceAll(formatter2.format(DateTime.parse(oclasslist[index]['start_date'].toString())), ''),
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  ' ' + 'End Time : ',
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  oclasslist[index]['end_date'].toString().replaceAll(formatter2.format(DateTime.parse(oclasslist[index]['end_date'].toString())), ''),
                                                                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 50,
                                                                      bottom:
                                                                          10),
                                                              child: Row(
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      ' ' +
                                                                          'Created By : ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      ' ' +
                                                                          oclasslist[index]
                                                                              [
                                                                              'created_by'] +
                                                                          ' ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          letterSpacing:
                                                                              1),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ))
                                                      : Container(),
                                                );
                                              })
                                          : ListView.builder(
                                              itemCount: oclasslist.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return parseddate!
                                                            .difference(DateTime
                                                                .parse(oclasslist[
                                                                        index][
                                                                    'start_date']))
                                                            .inSeconds <
                                                        0
                                                    ? Container(
                                                        child: Card(
                                                            child: Column(
                                                        children: [
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            color:
                                                                CupertinoColors
                                                                    .systemGrey5,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      oclasslist[
                                                                              index]
                                                                          [
                                                                          'subject_name'],
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          /*  Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(' '+oclasslist[index]['id'],
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w400
                                                        ),),
                                                    ),
                                                  ],
                                                ),*/
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      ' ' +
                                                                          'Start Date : ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      ' ' +
                                                                          formatter
                                                                              .format(DateTime.parse(oclasslist[index]['start_date'].toString()))
                                                                              .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          letterSpacing:
                                                                              1),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      'End Date : ',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      formatter
                                                                          .format(
                                                                              DateTime.parse(oclasslist[index]['end_date'].toString()))
                                                                          .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      letterSpacing:
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      'Start Time : ',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  oclasslist[index]
                                                                          [
                                                                          'start_date']
                                                                      .toString()
                                                                      .replaceAll(
                                                                          formatter2
                                                                              .format(DateTime.parse(oclasslist[index]['start_date'].toString())),
                                                                          ''),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      letterSpacing:
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      'End Time : ',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  oclasslist[index]
                                                                          [
                                                                          'end_date']
                                                                      .toString()
                                                                      .replaceAll(
                                                                          formatter2
                                                                              .format(DateTime.parse(oclasslist[index]['end_date'].toString())),
                                                                          ''),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      letterSpacing:
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Wrap(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      'Created By : ',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      oclasslist[
                                                                              index]
                                                                          [
                                                                          'created_by'] +
                                                                      ' ',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      letterSpacing:
                                                                          1),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      )))
                                                    : Container();
                                              });
                                    }),
                              ),
                            )
                          : initialscreen == 'error'
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height - 205,
                                  child: PageView.builder(
                                    itemCount: 2,
                                    controller: controller,
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (v) {
                                      setState(() {
                                        startindex = v;
                                      });
                                    },
                                    itemBuilder: (context, position) {
                                      return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              205,
                                          child: Center(
                                            child: Text(
                                              'Nothing to show',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: CupertinoColors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ));
                                    },
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height - 205,
                                  child: PageView.builder(
                                    itemCount: 2,
                                    scrollDirection: Axis.horizontal,
                                    controller: controller,
                                    onPageChanged: (v) {
                                      setState(() {
                                        startindex = v;
                                      });
                                    },
                                    itemBuilder: (context, position) {
                                      return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              205,
                                          child: Center(
                                            child: Text(
                                              'No online class',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: CupertinoColors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                  if (initialscreen == 'screenloaded')
                    Container(
                      height: 70,
                      color: CupertinoColors.black,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: ToggleSwitch(
                          dividerColor: Colors.transparent,
                          curve: Curves.fastOutSlowIn,
                          minHeight: 30,
                          cornerRadius: 1.0,
                          minWidth: MediaQuery.of(context).size.width,
                          initialLabelIndex: startindex,
                          totalSwitches: 2,
                          changeOnTap: true,
                          inactiveBgColor: Colors.transparent,
                          activeBgColor: [Colors.white, Colors.white],
                          animate: true,
                          labels: ['Recent Classes', 'Upcoming Classes'],
                          iconSize: 30,
                          inactiveFgColor: Colors.white,
                          activeFgColor: Colors.black,
                          onToggle: (v) {
                            if (v == 0) {
                              setState(() {
                                startindex = 0;
                                changescreen(0);
                              });
                            }
                            if (v == 1) {
                              startindex = 1;
                              changescreen(1);
                            }
                          },
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
                              //  Icon(CupertinoIcons.home,color: botoomiconunselectedcolor,),
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
                              //  Icon(CupertinoIcons.book,color: botoomiconunselectedcolor,),
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
                                  elevation: 0,
                                  heroTag: null,
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
                              //   Icon(CupertinoIcons.info,color: botoomiconunselectedcolor,),
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
                              //   Icon(CupertinoIcons.doc_append,color: botoomiconunselectedcolor,),
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
}
