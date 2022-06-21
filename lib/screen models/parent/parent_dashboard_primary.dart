import 'package:eznext/api_models/profile_student.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/mydocuments.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:toast/toast.dart';

import '../../logoutmodel.dart';
import '../dashboard.dart';

List modulelist = [];
String initScreen = 'loader';

class ParentHome extends StatefulWidget {
  @override
  _ParentHomeState createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  //--------defining & initialising parameters------------//
  late var newVersion = NewVersion(context: context);
  final myKey = new GlobalKey<_ParentHomeState>();
  _launchURL() async {
    StoreRedirect.redirect(
        androidAppId: "com.in30days.ima", iOSAppId: "i588190962");
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

  //--------navigation menu bar---------------------//
  void _showPopupMenu() async {
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(600, 80, 0, 100),
        items: [
          if (initScreen == 'screenloaded')
            PopupMenuItem(
              value: 1,
              child: Center(
                child: Text(
                  'Timeline',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          if (initScreen == 'screenloaded')
            PopupMenuItem(
              value: 2,
              child: Center(
                child: Text(
                  'My Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          if (initScreen == 'screenloaded')
            PopupMenuItem(
              value: 3,
              child: Center(
                child: Text(
                  'Teachers',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
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
        iOSId: 'com.in30days.ima',
        androidId: 'com.in30days.ima',
        context: context,
        updateText: "Update Now");
    // basicStatusCheck(newVersion);
    gettingSavedData();
    super.initState();
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    print("stt" + status.toString());
    newVersion.showUpdateDialog(
      status,
    );
  }

  basicStatusCheck(NewVersion newVersion) {
    newVersion.showAlertIfNecessary();
  }

  List<String> sid = [];
  List<String> sclass = [];
  List<String> ssection = [];
  List<String> sclsid = [];
  List<String> ssecid = [];
  List<String> sname = [];
  List<String> simage = [];

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
      sid = studentdetails.getStringList("childids");
      sclass = studentdetails.getStringList("childcls");
      ssection = studentdetails.getStringList("childsections");
      sclsid = studentdetails.getStringList("childclsid");
      ssecid = studentdetails.getStringList("childsecid");
      sname = studentdetails.getStringList("childname");
      simage = studentdetails.getStringList("childimage");
    });
    print(sname.length);
    if (sname.length <= 1) {
      Navigator.pushReplacement(context,
          CupertinoPageRoute(builder: (BuildContext context) => MyHome()));
    } else {
      showbs();
    }
  }

  void showbs() {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Child List',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                        // IconButton(onPressed: (){}, icon: Icon(Icons.cancel_outlined, color: Colors.black,)),
                      ],
                    ),
                  ),
                  Container(
                    height: 410,
                    child: ListView.builder(
                        itemCount: sname.length,
                        itemBuilder: (BuildContext context, index) {
                          return GestureDetector(
                            onTap: () async {
                              SharedPreferences studentdetails =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                studentdetails.setString(
                                    'student_id', sid[index]);
                                studentdetails.setString(
                                    'student_name', sname[index]);
                                studentdetails.setString(
                                    'class', sclass[index]);
                                studentdetails.setString(
                                    'class_id', sclsid[index]);
                                studentdetails.setString(
                                    'section', ssection[index]);
                                studentdetails.setString(
                                    'section_id', ssecid[index]);
                                studentdetails.setString(
                                    'image', simage[index]);
                              });
                              Future.delayed(const Duration(seconds: 0), () {
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            MyHome()));
                              });
                            },
                            child: Container(
                              child: Card(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                            image: schoolcode == ''
                                                ? new NetworkImage(siteurl +
                                                    '/' +
                                                    simage[index])
                                                : NetworkImage('https://' +
                                                    schoolcode +
                                                    '.eznext.in' +
                                                    '/' +
                                                    simage[index]),
                                            fit: BoxFit.fill,
                                          ))),
                                    ),
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sname[index],
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            sclass[index],
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        });
  }

  String studentroll = '';
  Future getStudProfile() async {
    try {
      var rsp = await Stud_profile(stdid, token.toString(), uid);
      //debugPrint(rsp.toString());
      setState(() {
        studentroll = rsp['student_result']['roll_no'].toString();
      });
      SharedPreferences studentdetails = await SharedPreferences.getInstance();
      studentdetails.setString(
          'admission_no', rsp['student_result']['admission_no'].toString());
      studentdetails.setString(
          'admission_date', rsp['student_result']['admission_date'].toString());
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
      studentdetails.setString(
          'guardian_phone', rsp['student_result']['guardian_phone'].toString());
      studentdetails.setString(
          'guardian_name', rsp['student_result']['guardian_name'].toString());
      studentdetails.setString('guardian_address',
          rsp['student_result']['guardian_address'].toString());
      studentdetails.setString(
          'guardian_email', rsp['student_result']['guardian_email'].toString());
      studentdetails.setString(
          'father_name', rsp['student_result']['father_name'].toString());
      studentdetails.setString(
          'father_phone', rsp['student_result']['father_phone'].toString());
      studentdetails.setString('father_occupation',
          rsp['student_result']['father_occupation'].toString());
      studentdetails.setString(
          'roll', rsp['student_result']['roll_no'].toString());
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
        setState(() {});
      }
    } catch (error) {
      print(error.toString());
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
    //Upgrader().clearSavedSettings();
    return CupertinoPageScaffold(
        backgroundColor: themecolor,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Select your child'),
          leading: Container(),
        ),
        child: WillPopScope(
          onWillPop: () async => false,
          child: Container(),
        ));
  }
}
