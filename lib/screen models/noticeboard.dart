// Home Tab
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/api_models/student_notice_board.dart';
import 'package:eznext/api_models/teacher_list.dart';
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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'fee.dart';
import 'mydocuments.dart';

class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  //--------defining & initialising parameters------------//
  dynamic commentController = TextEditingController();
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
  String cls_id = '';
  String section_id = '';
  var noticelist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';

  final myKey = new GlobalKey<_NoticeBoardState>();

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

  //--------navigation menu bar---------------------//
  void _showPopupMenu() async {
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(600, 80, 0, 100),
        items: [
          /*         if(initScreen=='screenloaded')
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

  var nextdet = [];
  @override
  void initState() {
    gettingSavedData();
    super.initState();
  }

  String comment = '';
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
      cls_id = studentdetails.getString('class_id');
      section_id = studentdetails.getString('section_id');
    });
    getNotice();
  }

  List indexlist = [];
  Future getNotice() async {
    try {
      var rsp = await Stud_notice(token.toString(), uid);
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
        setState(() {});
        if (rsp['success'] == 1) {
          setState(() {
            initialscreen = 'screenloaded';
            noticelist = rsp['data'];
          });
        } else {
          setState(() {
            initialscreen = 'no homework found';
          });
        }
      }
      //debugPrint('aa-'+initialscreen);
    } catch (error) {
      //debugPrint(error.toString());
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  Future modalSheet(String det) async {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  det,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          )),
    );
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
              middle: Text(
                'Noticeboard',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
              backgroundColor: appbarcolor,
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
                                  itemCount: noticelist.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        Container(
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  // height: 40,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 8),
                                                    child: Center(
                                                        child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              ' ' +
                                                                  noticelist[
                                                                          index]
                                                                      ['title'],
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ))),
                                                  ),
                                                ),
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              ' ' +
                                                                  'Date : ' +
                                                                  formatter.format(
                                                                      DateTime.parse(
                                                                          noticelist[index]
                                                                              [
                                                                              'date'])),
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .remove_red_eye,
                                                              size: 15,
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                modalSheet(noticelist[
                                                                            index]
                                                                        [
                                                                        'message']
                                                                    .toString()
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'<[^>]*>|&[^;]+;'),
                                                                        ' '));
                                                              },
                                                              child: Text(
                                                                'View',
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          )
                        : initialscreen == 'error'
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height - 144,
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
                                    MediaQuery.of(context).size.height - 144,
                                child: Center(
                                  child: Text(
                                    'No notice available',
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
                            //    Icon(CupertinoIcons.home,color: botoomiconunselectedcolor,),
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
                            //   Icon(CupertinoIcons.book,color: botoomiconunselectedcolor,),
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
                            //   Icon(CupertinoIcons.money_dollar_circle,color: botoomiconunselectedcolor,),
                            Container(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
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
                          onTap: () {},
                          child: Column(children: [
                            //    Icon(CupertinoIcons.info,color: botoomiconselectedcolor,),
                            Image.asset('assets/dash_icons/notice.png',
                                height: 30, width: 30),
                            Text(
                              'Notice',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: botoomiconselectedcolor,
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

class Customer {
  String name;
  String age;

  Customer(this.name, this.age);

  @override
  String toString() {
    return '{ ${this.name}, ${this.age} }';
  }
}
