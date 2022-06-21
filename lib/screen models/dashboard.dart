import 'dart:developer';

import 'package:eznext/api_models/dash_board.dart';
import 'package:eznext/api_models/get_modules.dart';
import 'package:eznext/api_models/profile_student.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/apply_leave.dart';
import 'package:eznext/screen%20models/attendance_details.dart';
import 'package:eznext/screen%20models/downloadcenter.dart';
import 'package:eznext/screen%20models/fee.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/library.dart';
import 'package:eznext/screen%20models/mydocuments.dart';
import 'package:eznext/screen%20models/noticeboard.dart';
import 'package:eznext/screen%20models/parent/parent_dashboard_primary.dart';
import 'package:eznext/screen%20models/profile.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:eznext/screen%20models/timetable.dart';
import 'package:eznext/screen%20models/track_bus.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:toast/toast.dart';
import 'package:upgrader/upgrader.dart';

import '../logoutmodel.dart';
import 'change_pass.dart';
import 'examscreen.dart';
import 'online_class.dart';
import 'online_exam.dart';

List modulelist = [];
String initScreen = 'loader';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  //--------defining & initialising parameters------------//
  late var newVersion = NewVersion(context: context);
  final myKey = new GlobalKey<_MyHomeState>();
  _launchURL() async {
    StoreRedirect.redirect(
        androidAppId: "com.in30days.eznext", iOSAppId: "i588190962");
  }

  String token = '';
  String stdid = '';
  String student_name = '';
  String class_name = '';
  String School_name = '';
  String section_name = '';
  String student_image = '';
  String roll_number = '';
  String siteurl = '';
  String sessionmonth = '';
  String sessionstartyear = '';
  String sessiondate = '01';
  String startdate = '';
  String child_name = '';
  List<String> sname = [];

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

  String uid = '';

  @override
  void initState() {
    newVersion = NewVersion(
        iOSId: 'com.in30days.eznext',
        androidId: 'com.in30days.eznext',
        context: context,
        updateText: "Update Now");
    basicStatusCheck(newVersion);
    gettingSavedData();
    super.initState();
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    //debugPrint("stt"+status.toString());
    if (status != null) {
      //debugPrint(status.appStoreLink);
      //debugPrint(status.localVersion);
      //debugPrint(status.storeVersion);
      //debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        status,
      );
    }
  }

  basicStatusCheck(NewVersion newVersion) async {
    SharedPreferences oncecalled = await SharedPreferences.getInstance();
    if (oncecalled.getString("called") == null) {
      setpopupcalled();
      newVersion.showAlertIfNecessary();
    }
  }

  void setpopupcalled() async {
    SharedPreferences oncecalled = await SharedPreferences.getInstance();
    oncecalled.setString("called", "yes");
  }

  String? role;
  void gettingSavedData() async {
    //-------initialising sharedpreference-----------//
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    SharedPreferences studentdetails = await SharedPreferences.getInstance();

    //-------setting values-----------------------//
    setState(() {
      role = studentdetails.getString('role');
      token = studentdetails.getString('token');
      student_name = studentdetails.getString('username');
      class_name = studentdetails.getString('class');
      section_name = studentdetails.getString('section');
      School_name = studentdetails.getString('sch_name');
      student_image = studentdetails.getString('image');
      siteurl = initialschoolcode.getString('site_url');
      stdid = studentdetails.getString('student_id');
      uid = studentdetails.getString('id');
      sname = studentdetails.getStringList("childname");
      child_name = studentdetails.getString('student_name');
    });
    getGeneralModules();
    getSchDet();
  }

  Future getSchDet() async {
    //debugPrint('sss');
    try {
      var rsp = await School_det(token.toString(), uid);
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
        setState(() {
          sessionstartyear = rsp['session'].toString();
          sessionstartyear = sessionstartyear.substring(0, 4);
          sessionmonth = rsp['start_month'].toString();
          if (sessionmonth.length == 1) {
            startdate =
                sessiondate + '-' + '0' + sessionmonth + '-' + sessionstartyear;
          } else {
            startdate =
                sessiondate + '-' + sessionmonth + '-' + sessionstartyear;
          }
        });
        getStudDet();
      }
    } catch (error) {
      //debugPrint(error.toString());
    }
  }

  Future getStudDet() async {
    try {
      var rsp = await Stud_dash(startdate, stdid, token.toString(), uid);
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
        getStudProfile();
        setState(() {});
      }
    } catch (error) {
      //debugPrint(error.toString());
    }
  }

  Future getGeneralModules() async {
    SharedPreferences preferencesmodules =
        await SharedPreferences.getInstance();
    try {
      var rsp = await School_modules_det(token.toString(), uid);
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
        setState(() {
          if (rsp['module_list'] != null || rsp['module_list'].isNotEmpty) {
            modulelist = rsp['module_list'];
            initScreen = 'screenloaded';
            /*   preferencesmodules.setString(
                'fees', modulelist[0]['is_active'].toString());
            preferencesmodules.setString(
                'ctimetable', modulelist[1]['is_active'].toString());
            preferencesmodules.setString(
                'homewrk', modulelist[2]['is_active'].toString());
            preferencesmodules.setString(
                'dcenter', modulelist[3]['is_active'].toString());
            preferencesmodules.setString(
                'attend', modulelist[4]['is_active'].toString());
            preferencesmodules.setString(
                'exami', modulelist[5]['is_active'].toString());
            preferencesmodules.setString(
                'nboard', modulelist[6]['is_active'].toString());
            preferencesmodules.setString(
                'libr', modulelist[7]['is_active'].toString());
            preferencesmodules.setString(
                'troutes', modulelist[8]['is_active'].toString());
            preferencesmodules.setString(
                'hrooms', modulelist[9]['is_active'].toString());
            preferencesmodules.setString(
                'ctodolist', modulelist[10]['is_active'].toString());
            preferencesmodules.setString(
                'oexam', modulelist[11]['is_active'].toString());
            preferencesmodules.setString(
                'trate', modulelist[12]['is_active'].toString());
            preferencesmodules.setString(
                'chat', modulelist[13]['is_active'].toString());
            preferencesmodules.setString(
                'mclass', modulelist[14]['is_active'].toString());*/
          } else {
            initScreen = 'empty';
          }
        });
      }
    } catch (error) {
      setState(() {
        initScreen = 'erro';
      });
      //debugPrint(error.toString());
    }
  }

  String studentroll = '';
  Future getStudProfile() async {
    try {
      var rsp = await Stud_profile(stdid, token.toString(), uid);
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
        setState(() {
          studentroll = rsp['student_result']['roll_no'].toString();
        });
        SharedPreferences studentdetails =
            await SharedPreferences.getInstance();
        studentdetails.setString(
            'admission_no', rsp['student_result']['admission_no'].toString());
        studentdetails.setString('admission_date',
            rsp['student_result']['admission_date'].toString());
        studentdetails.setString(
            'firstname', rsp['student_result']['firstname'].toString());
        studentdetails.setString(
            'lastname', rsp['student_result']['lastname'].toString());
        studentdetails.setString(
            'std_image', rsp['student_result']['image'].toString());
        studentdetails.setString(
            'mobileno', rsp['student_result']['mobileno'].toString());
        studentdetails.setString(
            'email_stud', rsp['student_result']['email'].toString());
        studentdetails.setString(
            'guardian_is', rsp['student_result']['guardian_is'].toString());
        studentdetails.setString('permanent_address',
            rsp['student_result']['permanent_address'].toString());
        studentdetails.setString('guardian_phone',
            rsp['student_result']['guardian_phone'].toString());
        studentdetails.setString(
            'guardian_name', rsp['student_result']['guardian_name'].toString());
        studentdetails.setString('guardian_address',
            rsp['student_result']['guardian_address'].toString());
        studentdetails.setString('guardian_email',
            rsp['student_result']['guardian_email'].toString());
        studentdetails.setString(
            'father_name', rsp['student_result']['father_name'].toString());
        studentdetails.setString(
            'father_phone', rsp['student_result']['father_phone'].toString());
        studentdetails.setString('father_occupation',
            rsp['student_result']['father_occupation'].toString());
        studentdetails.setString(
            'roll', rsp['student_result']['roll_no'].toString());
      }
    } catch (error) {
      //debugPrint(error.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text(
            'Dashboard',
            style: GoogleFonts.poppins(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: appbarcolor,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  _showPopupMenu();
                },
                child: Icon(CupertinoIcons.list_bullet),
              ),
            )
          ],
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (initScreen == 'screenloaded')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                          image: AssetImage("assets/cardback.jpeg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: role == 'student'
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: new BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              image: new DecorationImage(
                                                image: schoolcode == ''
                                                    ? new NetworkImage(siteurl +
                                                        '/' +
                                                        student_image)
                                                    : NetworkImage('https://' +
                                                        schoolcode +
                                                        '.eznext.in' +
                                                        '/' +
                                                        student_image),
                                                fit: BoxFit.fill,
                                              ))),
                                    ),
                                    Container(
                                      child: Flexible(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Wrap(
                                                children: [
                                                  //Text('Name :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                  // SizedBox(width: 10,),
                                                  if (student_name != null)
                                                    Text(
                                                      student_name,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: CupertinoColors
                                                              .white),
                                                    ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  // Text('Class :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                  // SizedBox(width: 10,),
                                                  if (class_name != null)
                                                    Text(
                                                      class_name,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: CupertinoColors
                                                              .white),
                                                    ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  //Text('Section :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                  // SizedBox(width: 10,),
                                                  if (section_name != null)
                                                    Text(
                                                      section_name,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: CupertinoColors
                                                              .white),
                                                    ),
                                                ],
                                              ),
                                              Wrap(
                                                children: [
                                                  Text(
                                                    'Roll No. :',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration.none,
                                                        color: CupertinoColors
                                                            .white),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  if (studentroll != null)
                                                    Text(
                                                      studentroll,
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: CupertinoColors
                                                              .white),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              //  Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : role == 'parent'
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (sname.length <= 1)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                                height: 100,
                                                width: 100,
                                                decoration: new BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                100)),
                                                    image: new DecorationImage(
                                                      image: schoolcode == ''
                                                          ? new NetworkImage(
                                                              siteurl +
                                                                  '/' +
                                                                  student_image)
                                                          : NetworkImage(
                                                              'https://' +
                                                                  schoolcode +
                                                                  '.eznext.in' +
                                                                  '/' +
                                                                  student_image),
                                                      fit: BoxFit.fill,
                                                    ))),
                                          ),
                                        if (sname.length > 1)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Container(
                                                    height: 100,
                                                    width: 100,
                                                    decoration:
                                                        new BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            100)),
                                                            image:
                                                                new DecorationImage(
                                                              image: schoolcode ==
                                                                      ''
                                                                  ? new NetworkImage(
                                                                      siteurl +
                                                                          '/' +
                                                                          student_image)
                                                                  : NetworkImage('https://' +
                                                                      schoolcode +
                                                                      '.eznext.in' +
                                                                      '/' +
                                                                      student_image),
                                                              fit: BoxFit.fill,
                                                            ))),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  height: 30,
                                                  width: 120,
                                                  child: RaisedButton(
                                                    elevation: 0,
                                                    color: CupertinoColors
                                                        .systemBlue,
                                                    child: Text(
                                                      'Switch Child',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          CupertinoPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  ParentHome()));
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        Container(
                                          child: Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      //   Text('Name :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.white),),
                                                      // SizedBox(width: 10,),
                                                      if (student_name != null)
                                                        Text(
                                                          student_name,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      // Text('Child name :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                      // SizedBox(width: 10,),
                                                      Text(
                                                        child_name,
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            color:
                                                                CupertinoColors
                                                                    .white),
                                                      ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      // Text('Class :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                      //  SizedBox(width: 10,),
                                                      if (class_name != null)
                                                        Text(
                                                          class_name,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      //Text('Section :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                      // SizedBox(width: 10,),
                                                      if (section_name != null)
                                                        Text(
                                                          section_name,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      Text(
                                                        'Roll No. :',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            color:
                                                                CupertinoColors
                                                                    .white),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      if (studentroll != null)
                                                        Text(
                                                          studentroll,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  //  Spacer(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: new BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(100)),
                                                  image: new DecorationImage(
                                                    image: schoolcode == ''
                                                        ? new NetworkImage(
                                                            siteurl +
                                                                '/' +
                                                                student_image)
                                                        : NetworkImage(
                                                            'https://' +
                                                                schoolcode +
                                                                '.eznext.in' +
                                                                '/' +
                                                                student_image),
                                                    fit: BoxFit.fill,
                                                  ))),
                                        ),
                                        Container(
                                          child: Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      //Text('Name :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                      // SizedBox(width: 10,),
                                                      if (student_name != null)
                                                        Text(
                                                          student_name,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      // Text('Class :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                      // SizedBox(width: 10,),
                                                      if (class_name != null)
                                                        Text(
                                                          class_name,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      //Text('Section :', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, decoration: TextDecoration.none, color: CupertinoColors.black),),
                                                      // SizedBox(width: 10,),
                                                      if (section_name != null)
                                                        Text(
                                                          section_name,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: [
                                                      Text(
                                                        'Roll No. :',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            color:
                                                                CupertinoColors
                                                                    .white),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      if (studentroll != null)
                                                        Text(
                                                          studentroll,
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  //  Spacer(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
              Container(
                //height: MediaQuery.of(context).size.height-300,
                child: Expanded(
                  child: initScreen == 'loader'
                      ? Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.8,
                            ),
                          ))
                      : initScreen == 'screenloaded'
                          ? Container(
                              color: Colors.white,
                              child: GridView.count(
                                crossAxisCount: 4,
                                crossAxisSpacing: 1.0,
                                mainAxisSpacing: 1.0,
                                childAspectRatio: 0.8,
                                shrinkWrap: false,
                                children: List.generate(
                                  16,
                                  (index) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        if (index == 0) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          OnlineClass()));
                                        }
                                        if (index == 1) {
                                          if (modulelist[2]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        Homework()));
                                          } else {
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 2) {
                                          if (modulelist[6]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        NoticeBoard()));
                                          } else {
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 3) {
                                          if (modulelist[1]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        Timetable()));
                                          } else {
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 4) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ApplyLeave()));
                                        }
                                        if (index == 5) {
                                          if (modulelist[4]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        MyAttendanceDetails()));
                                          } else {
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 6) {
                                          if (modulelist[5]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        StudenExam()));
                                          } else {
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 7) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          OnlineExam(
                                                            state: false,
                                                          )));
                                        }
                                        if (index == 8) {
                                          if (modulelist[3]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        DownloadCenter()));
                                          } else {
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 9) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          Profile()));
                                        }
                                        if (index == 10) {
                                          if (modulelist[7]['is_active'] ==
                                              '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        Library()));
                                          }
                                          if (index == 15) {
                                            // if (modulelist[7]['is_active'] ==
                                            //     '1') {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        BusLocationTracking()));
                                            // }
                                          } else {
                                            log(index.toString());
                                            showPrintedMessage('Oops!!',
                                                'This module is disabled by admin');
                                          }
                                        }
                                        if (index == 11) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ChangePass()));
                                        }
                                        if (index == 12) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          TimeLine()));
                                        }
                                        if (index == 13) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          MyDocuments()));
                                        }
                                        if (index == 14) {
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          TeacherList()));
                                        }
                                        if (index == 15) {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        BusLocationTracking()));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                          ),
                                          child: Card(
                                            elevation: 0,
                                            color: Colors.transparent,
                                            child: FittedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (index == 0)
                                                    // Icon(CupertinoIcons.videocam_circle, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/oclass.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 0)
                                                    Text(
                                                      'Online',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 0)
                                                    Text(
                                                      'Classes',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 1)
                                                    // Icon(CupertinoIcons.book, size: 35,color: modulelist[2]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                    Image.asset(
                                                      'assets/dash_icons/homework.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),

                                                  if (index == 1)
                                                    Text(
                                                      'Homework',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[2][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 1)
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (index == 2)
                                                    // Icon(CupertinoIcons.info, size: 35,color: modulelist[6]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                    Image.asset(
                                                        'assets/dash_icons/notice.png',
                                                        height: 75,
                                                        width: 75),
                                                  if (index == 2)
                                                    Text(
                                                      'Notice',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[6][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 2)
                                                    Text(
                                                      'Board',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[6][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 3)
                                                    //  Icon(CupertinoIcons.calendar, size: 35,color: modulelist[1]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                    Image.asset(
                                                      'assets/dash_icons/timetable1.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),

                                                  if (index == 3)
                                                    Text(
                                                      'Time',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[1][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 3)
                                                    Text(
                                                      'Table',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[1][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 4)
                                                    //Icon(CupertinoIcons.calendar_badge_minus, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/leave.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 4)
                                                    Text(
                                                      'Apply',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 4)
                                                    Text(
                                                      'Leave',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 5)
                                                    //   Icon(CupertinoIcons.calendar_badge_plus, size: 35,color: modulelist[4]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                    Image.asset(
                                                      'assets/dash_icons/attendance.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 5)
                                                    Text(
                                                      'Attendance',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[4][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 5)
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (index == 6)
                                                    // Icon(CupertinoIcons.doc_append, size: 35,color: modulelist[5]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                    Image.asset(
                                                      'assets/dash_icons/examination.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 6)
                                                    Text(
                                                      'Examination',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[5][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 6)
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (index == 7)
                                                    //   Icon(CupertinoIcons.desktopcomputer, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/oexam.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 7)
                                                    Text(
                                                      'Online',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 7)
                                                    Text(
                                                      'Exam',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 8)
                                                    //    Icon(CupertinoIcons.cloud_download, size: 35,color: modulelist[3]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                    Image.asset(
                                                      'assets/dash_icons/downloadcenter.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 8)
                                                    Text(
                                                      'Download',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[3][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 8)
                                                    Text(
                                                      'Center',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[3][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 9)
                                                    // Icon(CupertinoIcons.person, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/student.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 9)
                                                    Text(
                                                      'My',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 9)
                                                    Text(
                                                      'Profile',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  //  Icon(CupertinoIcons.bookmark, size: 35,color: modulelist[7]['is_active']=='1'?dashiconcolor:CupertinoColors.systemGrey,),
                                                  if (index == 10)
                                                    Image.asset(
                                                        'assets/dash_icons/library.png',
                                                        height: 75,
                                                        width: 75),

                                                  if (index == 10)
                                                    Text(
                                                      'Library',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: modulelist[7][
                                                                    'is_active'] ==
                                                                '1'
                                                            ? CupertinoColors
                                                                .black
                                                            : CupertinoColors
                                                                .systemGrey,
                                                      ),
                                                    ),
                                                  if (index == 10)
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  if (index == 11)
                                                    // Icon(CupertinoIcons.lock, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/cpass.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 11)
                                                    Text(
                                                      'Change',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 11)
                                                    Text(
                                                      'Password',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 12)
                                                    // Icon(CupertinoIcons.lock, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/timeline.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 12)
                                                    Text(
                                                      'Timeline',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 12)
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (index == 13)
                                                    //Icon(CupertinoIcons.lock, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/mydocs.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 13)
                                                    Text(
                                                      'My',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 13)
                                                    Text(
                                                      'Documents',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 14)
                                                    // Icon(CupertinoIcons.lock, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/teacher.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 14)
                                                    Text(
                                                      'Teachers',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 14)
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                  if (index == 15)
                                                    //Icon(CupertinoIcons.lock, size: 35,color: dashiconcolor,),
                                                    Image.asset(
                                                      'assets/dash_icons/transport.png',
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  if (index == 15)
                                                    Text(
                                                      'Transport',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  if (index == 15)
                                                    Text(
                                                      'Routes',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : initScreen == 'empty'
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: Text(
                                      'No modules fetched',
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                          color: CupertinoColors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ))
                              : Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: Text(
                                      'Modules fetching error\nPlease relogin',
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          decoration: TextDecoration.none,
                                          color: CupertinoColors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  )),
                ),
              ),
              if (initScreen == 'screenloaded')
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
              if (initScreen == 'screenloaded')
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  color: bottombar,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
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
                              color: botoomiconselectedcolor,
                              decoration: TextDecoration.none,
                            ),
                          )
                        ]),
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
                                color: Colors.black,
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
                                color: Colors.black,
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
                                color: Colors.black,
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
                                color: Colors.black,
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
      ),
    );
  }
}
