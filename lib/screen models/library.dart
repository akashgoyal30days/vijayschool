// Home Tab
import 'package:eznext/api_models/lib_rary.dart';
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'fee.dart';
import 'noticeboard.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
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
  var library = [];
  var issuedbooks = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';

  //--------html tags remover---------//

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
    issuedBooks();
    getBooks();
  }

  Future getBooks() async {
    try {
      var rsp = await Libr_ary(token.toString(), uid);
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
        if (rsp['success'] == 1) {
          setState(() {
            library = rsp['data'];
            //debugPrint(library.toString());
          });
        }
      }
    } catch (error) {
      setState(() {
        // initialscreen = 'error';
      });
    }
  }

  Future issuedBooks() async {
    try {
      var rsp = await Issued_books(stdid, token.toString(), uid);
      // //debugPrint(rsp.toString());
      setState(() {
        issuedbooks = rsp;
        initialscreen = 'screenloaded';
        //debugPrint(issuedbooks.toString());
      });
      //debugPrint(initialscreen);
    } catch (error) {
      //debugPrint(error.toString());
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  String booklist = 'notshow';

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
                'Library',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
              leading: Container(),
              backgroundColor: appbarcolor,
              trailing: booklist == 'notshow'
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          booklist = 'show';
                        });
                      },
                      child: Icon(
                        CupertinoIcons.book,
                        color: Colors.white,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          booklist = 'notshow';
                        });
                      },
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ))),
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
                            child: booklist == 'show'
                                ? GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 2.0,
                                    mainAxisSpacing: 2.0,
                                    shrinkWrap: false,
                                    children:
                                        List.generate(library.length, (index) {
                                      return Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            height: 100,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color:
                                                  CupertinoColors.systemGrey5,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)),
                                              image: new DecorationImage(
                                                image: AssetImage(
                                                  'assets/book.png',
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              color: CupertinoColors.systemGrey5
                                                  .withOpacity(0.5),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors
                                                        .systemBlue
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          library[index]
                                                                  ['book_title']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Genere : ' +
                                                          library[index]
                                                                  ['subject']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Author : ' +
                                                          library[index]
                                                                  ['author']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Available : ' +
                                                          library[index]
                                                                  ['available']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Publisher : ' +
                                                          library[index]
                                                                  ['publish']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Qty : ' +
                                                          library[index]['qty']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Rack No. : ' +
                                                          library[index]
                                                                  ['rack_no']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: CupertinoColors.white
                                                        .withOpacity(0.5),
                                                    child: Text(
                                                      ' ' +
                                                          'Price : ' +
                                                          ' ' +
                                                          '₹' +
                                                          ' ' +
                                                          library[index][
                                                                  'perunitcost']
                                                              .toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: CupertinoColors
                                                              .black,
                                                          decoration:
                                                              TextDecoration
                                                                  .none),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  )
                                : ListView.builder(
                                    itemCount: issuedbooks.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return Container(
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ' ' +
                                                      'Book number : ' +
                                                      issuedbooks[index]
                                                              ['book_no']
                                                          .toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  ' ' +
                                                      'Book name : ' +
                                                      issuedbooks[index]
                                                              ['book_title']
                                                          .toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  ' ' +
                                                      'Issued date : ' +
                                                      formatter
                                                          .format(DateTime.parse(
                                                              issuedbooks[index]
                                                                  [
                                                                  'issue_date']))
                                                          .toString(),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15),
                                                ),
                                                if (issuedbooks[index]
                                                        ['is_returned'] !=
                                                    '0')
                                                  Text(
                                                    ' ' + 'Returned : ' + 'yes',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15),
                                                  ),
                                                if (issuedbooks[index]
                                                        ['is_returned'] ==
                                                    '0')
                                                  Text(
                                                    ' ' + 'Returned : ' + 'no',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15),
                                                  ),
                                                Text(
                                                  ' ' +
                                                      'Subject : ' +
                                                      issuedbooks[index]
                                                          ['subject'],
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  ' ' +
                                                      'Due return date : ' +
                                                      formatter
                                                          .format(DateTime.parse(
                                                              issuedbooks[index]
                                                                  [
                                                                  'due_return_date']))
                                                          .toString(),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                          ))
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
                                    'No books issued',
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
