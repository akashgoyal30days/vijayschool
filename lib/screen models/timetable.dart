// Home Tab
import 'package:eznext/api_models/stud_timetable.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class Timetable extends StatefulWidget {
  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
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

  final myKey = new GlobalKey<_TimetableState>();
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
    gettimetable();
  }

  Future gettimetable() async {
    try {
      var rsp = await Stud_timetable(stdid, token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == '200') {
          setState(() {
            timetablelist = rsp['timetable'];
            initialscreen = 'screenloaded';
            monday = rsp['timetable']['Monday'];
            tuesday = rsp['timetable']['Tuesday'];
            wednesday = rsp['timetable']['Wednesday'];
            thursday = rsp['timetable']['Thursday'];
            friday = rsp['timetable']['Friday'];
            saturday = rsp['timetable']['Saturday'];
            sunday = rsp['timetable']['Sunday'];
          });
        }
        if (rsp['status'] == 401) {
          logOut(context);
          Toast.show(unautherror, context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              backgroundRadius: 5);
        }
        if (rsp['timetable'] == '' || rsp['timetable'] == null) {
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
                'Time Table',
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
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: themecolor,
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
                                  itemCount: 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Monday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height:
                                                      monday.isEmpty ? 0 : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: monday.isEmpty
                                                      ? 0
                                                      : monday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount: monday.isEmpty
                                                          ? 0
                                                          : monday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  monday[index][
                                                                          'time_from'] +
                                                                      '-' +
                                                                      monday[index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      monday[index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      monday[index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  monday[index][
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Tuesday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height:
                                                      tuesday.isEmpty ? 0 : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: tuesday.isEmpty
                                                      ? 0
                                                      : tuesday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount: tuesday.isEmpty
                                                          ? 0
                                                          : tuesday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  tuesday[index]
                                                                          [
                                                                          'time_from'] +
                                                                      '-' +
                                                                      tuesday[index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      tuesday[index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      tuesday[index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  tuesday[index]
                                                                          [
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Wednesday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height: wednesday.isEmpty
                                                      ? 0
                                                      : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: wednesday.isEmpty
                                                      ? 0
                                                      : wednesday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount: wednesday
                                                              .isEmpty
                                                          ? 0
                                                          : wednesday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  wednesday[index]
                                                                          [
                                                                          'time_from'] +
                                                                      '-' +
                                                                      wednesday[
                                                                              index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      wednesday[
                                                                              index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      wednesday[
                                                                              index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  wednesday[index]
                                                                          [
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Thursday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height:
                                                      thursday.isEmpty ? 0 : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: thursday.isEmpty
                                                      ? 0
                                                      : thursday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          thursday.isEmpty
                                                              ? 0
                                                              : thursday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  thursday[index]
                                                                          [
                                                                          'time_from'] +
                                                                      '-' +
                                                                      thursday[
                                                                              index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      thursday[
                                                                              index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      thursday[
                                                                              index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  thursday[index]
                                                                          [
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Friday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height:
                                                      friday.isEmpty ? 0 : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: friday.isEmpty
                                                      ? 0
                                                      : friday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount: friday.isEmpty
                                                          ? 0
                                                          : friday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  friday[index][
                                                                          'time_from'] +
                                                                      '-' +
                                                                      friday[index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      friday[index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      friday[index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  friday[index][
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Saturday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height:
                                                      saturday.isEmpty ? 0 : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: saturday.isEmpty
                                                      ? 0
                                                      : saturday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          saturday.isEmpty
                                                              ? 0
                                                              : saturday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  saturday[index]
                                                                          [
                                                                          'time_from'] +
                                                                      '-' +
                                                                      saturday[
                                                                              index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      saturday[
                                                                              index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      saturday[
                                                                              index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  saturday[index]
                                                                          [
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  color: CupertinoColors
                                                      .systemGrey5,
                                                  child: Center(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            ' Sunday',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          ))),
                                                ),
                                                Container(
                                                  height:
                                                      sunday.isEmpty ? 0 : 30,
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
                                                          child: Text(
                                                            ' Time',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            ' Subject',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                          child: Text(
                                                            ' Room No. ',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        15),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: sunday.isEmpty
                                                      ? 0
                                                      : sunday.length * 50,
                                                  child: ListView.builder(
                                                      itemCount: sunday.isEmpty
                                                          ? 0
                                                          : sunday.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
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
                                                                child: Text(
                                                                  sunday[index][
                                                                          'time_from'] +
                                                                      '-' +
                                                                      sunday[index]
                                                                          [
                                                                          'time_to'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3,
                                                                child: Text(
                                                                  '  ' +
                                                                      sunday[index]
                                                                          [
                                                                          'subject_name'] +
                                                                      ' ' +
                                                                      '(' +
                                                                      sunday[index]
                                                                          [
                                                                          'code'] +
                                                                      ')',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                )),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Center(
                                                                    child: Text(
                                                                  sunday[index][
                                                                          'room_no'] +
                                                                      ' ',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                          fontSize:
                                                                              12),
                                                                ))),
                                                          ],
                                                        );
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
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
                                      builder: (BuildContext context) =>
                                          Homework()));
                            } else {
                              showPrintedMessage(
                                  'Oops!!', 'This module is disabled by admin');
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
                                elevation: 0,
                                onPressed: null,
                                heroTag: null,
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
                              showPrintedMessage(
                                  'Oops!!', 'This module is disabled by admin');
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
