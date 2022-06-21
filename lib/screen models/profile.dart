// Home Tab
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/fee.dart';
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
import 'mydocuments.dart';
import 'noticeboard.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  String admno = '';
  String admdate = '';
  String firstname = '';
  String lastname = '';
  String img = '';
  String mno = '';
  String stdemail = '';
  String gtype = '';
  String permadd = '';
  String gphone = '';
  String gname = '';
  String gaddress = '';
  String gemail = '';
  String fathername = '';
  String fatherphone = '';
  String fatherocuupation = '';

  final myKey = new GlobalKey<_ProfileState>();

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
      admno = studentdetails.getString('admission_no');
      admdate = studentdetails.getString('admission_date');
      firstname = studentdetails.getString('firstname');
      lastname = studentdetails.getString('lastname');
      img = studentdetails.getString('std_image');
      mno = studentdetails.getString('mobileno');
      stdemail = studentdetails.getString('email_stud');
      gtype = studentdetails.getString('guardian_is');
      permadd = studentdetails.getString('permanent_address');
      gphone = studentdetails.getString('guardian_phone');
      gname = studentdetails.getString('guardian_name');
      gaddress = studentdetails.getString('guardian_address');
      gemail = studentdetails.getString('guardian_email');
      fathername = studentdetails.getString('father_name');
      fatherphone = studentdetails.getString('father_phone');
      fatherocuupation = studentdetails.getString('father_occupation');
      roll_number = studentdetails.getString('roll');
    });
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
          elevation: 0,
          leading: Container(),
          backgroundColor: appbarcolor,
          title: Text(
            'Profile',
            style:
                GoogleFonts.poppins(fontSize: 18, color: CupertinoColors.white),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                _showPopupMenu();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(
                  CupertinoIcons.list_bullet,
                  color: CupertinoColors.white,
                  size: 28,
                ),
              ),
            )
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 130,
                        width: 120,
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                          image: schoolcode == ''
                              ? new NetworkImage(siteurl + '/' + student_image)
                              : NetworkImage('https://' +
                                  schoolcode +
                                  '.eznext.in' +
                                  '/' +
                                  student_image),
                          fit: BoxFit.fill,
                        ))),
                  ),
                  Container(
                    width: 50,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: CupertinoColors.systemBlue.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              firstname.toString() + ' ' + lastname.toString(),
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                  color: CupertinoColors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 4, right: 4, top: 4),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                color: CupertinoColors.extraLightBackgroundGray,
                                child: Row(
                                  children: [
                                    Center(
                                        child: Text(
                                      ' ' + 'Student Details',
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Adm no : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        admno.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Roll no : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        roll_number.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Mobile no : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        mno.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Address : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        permadd.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 4, right: 4, top: 4),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                color: CupertinoColors.extraLightBackgroundGray,
                                child: Row(
                                  children: [
                                    Center(
                                        child: Text(
                                      ' ' + 'Guardian Details',
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Guardian : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        gtype.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Guardian name : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        gname.toString() + '  ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Guardian phone : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        gphone.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Guardian address : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        gaddress.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + 'Guardian email : ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        gemail.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 4, right: 4, top: 4),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                color: CupertinoColors.extraLightBackgroundGray,
                                child: Row(
                                  children: [
                                    Center(
                                        child: Text(
                                      ' ' + 'Father Details',
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + "Father's name : ",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        fathername.toString() + '  ',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '  ' + "Father's phone : ",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                      Text(
                                        fatherphone.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '  ' + "Father's occupation : ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: CupertinoColors.black),
                                  ),
                                  Text(
                                    fatherocuupation.toString() + '  ',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        color: CupertinoColors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                                  builder: (BuildContext context) => MyHome()));
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
                                    builder: (BuildContext context) => Fees()));
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
