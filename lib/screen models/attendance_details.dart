// Home Tab
import 'package:eznext/api_models/attendance_details.dart';
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
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class MyAttendanceDetails extends StatefulWidget {
  @override
  _MyAttendanceDetailsState createState() => _MyAttendanceDetailsState();
}

class _MyAttendanceDetailsState extends State<MyAttendanceDetails> {
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
  var attendancelist = [];
  var newattlist = [];
  var monday = [];
  var tuesday = [];
  var wednesday = [];
  var thursday = [];
  var friday = [];
  var saturday = [];
  var sunday = [];
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  String? year;
  String? month;
  String dates = DateTime.now().toString();

  final myKey = new GlobalKey<_MyAttendanceDetailsState>();

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
    setState(() {
      year = DateTime.now().year.toString();

      if (DateTime.now().month.toString().length == 1) {
        month = '0' + DateTime.now().month.toString();
        if (DateTime.now().day.toString().length == 1) {
          dates = DateTime.now().year.toString() +
              '-' +
              '0' +
              DateTime.now().month.toString() +
              '-' +
              '0' +
              DateTime.now().day.toString();
        } else {
          dates = DateTime.now().year.toString() +
              '-' +
              '0' +
              DateTime.now().month.toString() +
              '-' +
              DateTime.now().day.toString();
        }
      } else {
        month = DateTime.now().month.toString();
        if (DateTime.now().day.toString().length == 1) {
          dates = DateTime.now().year.toString() +
              '-' +
              DateTime.now().month.toString() +
              '-' +
              '0' +
              DateTime.now().day.toString();
        } else {
          dates = DateTime.now().year.toString() +
              '-' +
              DateTime.now().month.toString() +
              '-' +
              DateTime.now().day.toString();
        }
      }
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
    });
    getAttendance();
  }

  String atttype = 'noany';
  var attdatelist = [];
  var type = [];
  Future getAttendance() async {
    try {
      var rsp = await Stud_attendance(
          stdid, year!, dates, month.toString(), token.toString(), uid);
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
          atttype = rsp['attendence_type'];
        });
        if (rsp['data'].isNotEmpty) {
          setState(() {
            initialscreen = 'screenloaded';
            if (atttype == '1') {
              attendancelist = rsp['data'];
            }
            if (atttype == '0') {
              newattlist = rsp['data'];
              for (var i = 0; i < newattlist.length; i++) {
                setState(() {
                  attdatelist
                      .add(DateTime.parse(newattlist[i]['date'].toString()));
                  type.add(newattlist[i]['type'].toString());
                });
              }
              //debugPrint(attdatelist.toString());
            }
          });
        } else {
          setState(() {
            initialscreen = 'no homework found';
          });
        }
      }
      //debugPrint(attendancelist.toString());
    } catch (error) {
      //debugPrint(error.toString());
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  Future getAttendance2(String year, String date, String month) async {
    //debugPrint(year);
    //debugPrint(date);
    //debugPrint(month);
    if (month.length == 1) {
      setState(() {
        month = ('0' + month).toString();
      });
    }
    if (date.length == 1) {
      setState(() {
        date = ('0' + date).toString();
      });
    }
    //debugPrint(date);
    //debugPrint(month);
    try {
      var rsp = await Stud_attendance(
          stdid, year, date, month.toString(), token.toString(), uid);
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
          atttype = rsp['attendence_type'];
        });
        if (rsp['data'].isNotEmpty) {
          setState(() {
            initialscreen = 'screenloaded';
            if (atttype == '1') {
              attendancelist = rsp['data'];
            }
            if (atttype == '0') {
              newattlist = rsp['data'];
              attdatelist.clear();
              for (var i = 0; i < newattlist.length; i++) {
                setState(() {
                  attdatelist
                      .add(DateTime.parse(newattlist[i]['date'].toString()));
                  type.add(newattlist[i]['type'].toString());
                });
              }
              //debugPrint(attdatelist.toString());
            }
          });
        } else {
          setState(() {
            // initialscreen = 'no homework found';
          });
        }
      }
      //debugPrint(attendancelist.toString());
    } catch (error) {
      //debugPrint(error.toString());
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  DateTime? _chosenDateTime;

  // Show the modal that contains the CupertinoDatePicker
  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (val) {
                          setState(() {
                            _chosenDateTime = val;
                            year = _chosenDateTime!.year.toString();
                            month = _chosenDateTime!.month.toString();
                            dates = _chosenDateTime.toString();
                          });
                          //debugPrint(_chosenDateTime.toString());
                          //debugPrint(month.toString());
                          //debugPrint(year.toString());
                        }),
                  ),

                  // Close the modal
                  CupertinoButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        if (_chosenDateTime!.month.toString().length == 1) {
                          month = '0' + _chosenDateTime!.month.toString();
                          if (_chosenDateTime!.day.toString().length == 1) {
                            dates = _chosenDateTime!.year.toString() +
                                '-' +
                                '0' +
                                _chosenDateTime!.month.toString() +
                                '-' +
                                '0' +
                                _chosenDateTime!.day.toString();
                          } else {
                            dates = _chosenDateTime!.year.toString() +
                                '-' +
                                '0' +
                                _chosenDateTime!.month.toString() +
                                '-' +
                                _chosenDateTime!.day.toString();
                          }
                        } else {
                          month = _chosenDateTime!.month.toString();
                          if (_chosenDateTime!.day.toString().length == 1) {
                            dates = _chosenDateTime!.year.toString() +
                                '-' +
                                _chosenDateTime!.month.toString() +
                                '-' +
                                '0' +
                                _chosenDateTime!.day.toString();
                          } else {
                            dates = _chosenDateTime!.year.toString() +
                                '-' +
                                _chosenDateTime!.month.toString() +
                                '-' +
                                _chosenDateTime!.day.toString();
                          }
                        }
                      });
                      getAttendance();
                    },
                  )
                ],
              ),
            ));
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    for (var i = 0; i < attdatelist.length; i++) {
      meetings.add(
        Meeting(
            type[i],
            DateTime(attdatelist[i].year, attdatelist[i].month,
                attdatelist[i].day, 9, 0, 0),
            DateTime(attdatelist[i].year, attdatelist[i].month,
                attdatelist[i].day, 10, 0, 0),
            type[i] == 'Present'
                ? CupertinoColors.activeGreen
                : type[i] == 'Holiday'
                    ? CupertinoColors.systemGrey
                    : type[i] == 'Late'
                        ? CupertinoColors.systemYellow
                        : CupertinoColors.destructiveRed,
            false),
      );
    }
    return meetings;
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
                    // Icon(CupertinoIcons.money_dollar_circle,color: botoomiconunselectedcolor,),
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
                    // Icon(CupertinoIcons.info,color: botoomiconunselectedcolor,),
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
                              builder: (BuildContext context) => StudenExam()));
                    } else {
                      showPrintedMessage(
                          'Oops!!', 'This module is disabled by admin');
                    }
                  },
                  child: Column(children: [
                    //  Icon(CupertinoIcons.doc_append,color: botoomiconunselectedcolor,),
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
        appBar: AppBar(
          centerTitle: true,
          leading: Container(),
          title: Text(
            'Attendance',
            style:
                GoogleFonts.poppins(color: CupertinoColors.white, fontSize: 18),
          ),
          elevation: 0,
          backgroundColor: appbarcolor,
          actions: [
            GestureDetector(
              onTap: () {
                _showPopupMenu();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  CupertinoIcons.list_bullet,
                  color: CupertinoColors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: themecolor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Expanded(
                    child: Column(
                  children: [
                    if (atttype == '1')
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: CupertinoColors.systemBlue,
                        child: Row(
                          children: [
                            Text(
                              '  ' + 'Date' + ' : ',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, color: CupertinoColors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showDatePicker(context);
                              },
                              child: Text(
                                formatter
                                    .format(DateTime.parse(dates.toString())),
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: CupertinoColors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (initialscreen == 'loader')
                      Container(
                          height: MediaQuery.of(context).size.height - 211,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 0.8,
                            ),
                          )),
                    if (initialscreen == 'screenloaded')
                      Container(
                        height: MediaQuery.of(context).size.height - 211,
                        child: atttype == '1'
                            ? Column(
                                children: [
                                  Container(
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: Text(
                                            ' ' + 'Subject',
                                            style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Container(
                                          width: 110,
                                          child: Center(
                                            child: Text(
                                              'Time',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Room',
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          'Attendance' + ' ',
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Divider(),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height -
                                        242,
                                    child: ListView.builder(
                                        itemCount: attendancelist.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          return Container(
                                            height: 30,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  child: Text(
                                                    ' ' +
                                                        attendancelist[index]
                                                            ['name'] +
                                                        ' ' +
                                                        '[' +
                                                        attendancelist[index]
                                                            ['code'] +
                                                        ']',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Container(
                                                  width: 110,
                                                  child: Text(
                                                    attendancelist[index]
                                                            ['time_from'] +
                                                        '-' +
                                                        attendancelist[index]
                                                            ['time_to'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Text(
                                                  attendancelist[index]
                                                      ['room_no'],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                if (attendancelist[index]
                                                        ['type'] ==
                                                    'Present')
                                                  Container(
                                                    width: 100,
                                                    child: Center(
                                                      child: Text(
                                                        'P',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: CupertinoColors
                                                                .activeGreen),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              )
                            : atttype == '0'
                                ? Container(
                                    child: SfCalendar(
                                      onViewChanged: (v) {
                                        //debugPrint(v.toString());
                                        List dates = v.visibleDates;
                                        //debugPrint(dates.toString());
                                        getAttendance2(
                                            dates[0].year.toString(),
                                            dates[0].toString(),
                                            dates[0].month.toString());
                                      },
                                      view: CalendarView.month,
                                      showNavigationArrow: true,
                                      cellEndPadding: 1,
                                      showCurrentTimeIndicator: false,
                                      todayHighlightColor: Colors.transparent,
                                      todayTextStyle: TextStyle(
                                          color: CupertinoColors.black),
                                      dataSource:
                                          MeetingDataSource(_getDataSource()),
                                      monthViewSettings: MonthViewSettings(
                                          navigationDirection:
                                              MonthNavigationDirection
                                                  .horizontal,
                                          appointmentDisplayMode:
                                              MonthAppointmentDisplayMode
                                                  .appointment,
                                          agendaItemHeight: 10.0),
                                    ),
                                  )
                                : Container(),
                      ),
                    if (initialscreen == 'error')
                      Container(
                          height: MediaQuery.of(context).size.height - 211,
                          child: Center(
                              child: Text(
                            'Nothing to show',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                            ),
                          ))),
                    if (initialscreen == 'no homework found')
                      Container(
                          height: MediaQuery.of(context).size.height - 211,
                          child: Center(
                              child: Text(
                            'No attendance history',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                            ),
                          ))),
                    Spacer(),
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
                )),
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

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
