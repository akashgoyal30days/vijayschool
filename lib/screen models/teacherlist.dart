// Home Tab
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/api_models/teacher_list.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/studentexam.dart';
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
import 'noticeboard.dart';

class TeacherList extends StatefulWidget {
  @override
  _TeacherListState createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  //--------defining & initialising parameters------------//
  dynamic commentController = TextEditingController();
  String token = '';
  String stdid = '';
  String sid = '';
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
  var rllist;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';

  //--------html tags remover---------//
  final myKey = new GlobalKey<_TeacherListState>();

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
      sid = studentdetails.getString('id');
    });
    getteacherlist();
  }

  String rated = '0';

  Future<void> Rate(BuildContext context, String stfid) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.document_scanner),
                SizedBox(
                  width: 10,
                ),
                Text('Rating'),
              ],
            ),
            content: Container(
              height: 100,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    child: RatingBar(
                      updateOnDrag: true,
                      initialRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 10,
                        ),
                        half: Icon(
                          Icons.star_half,
                          color: Colors.amber,
                          size: 10,
                        ),
                        empty: Icon(
                          Icons.star_border,
                          color: CupertinoColors.systemGrey,
                          size: 10,
                        ),
                      ),
                      itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      onRatingUpdate: (rating) {
                        setState(() {
                          rated = rating.toString();
                        });

                        //debugPrint(rating.toString());
                      },
                    ),
                  ),
                  Container(
                    height: 50,
                    child: CupertinoTextField(
                      placeholder: 'Add Comment',
                      controller: commentController,
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    rateteacher(stfid, rated);
                  },
                  child: Text('SUBMIT')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    commentController.clear();
                  },
                  child: Text('CANCEL'))
            ],
          );
        });
  }

  List indexlist = [];
  Future getteacherlist() async {
    try {
      var rsp =
          await Stud_tchr_list(sid, cls_id, section_id, token.toString(), uid);
      //debugPrint(sid);
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
        if (rsp['result_list'] != null) {
          setState(() {
            initialscreen = 'screenloaded';
            rllist = rsp['result_list'];
            indexlist = rllist.keys.toList();
            //debugPrint(indexlist.toString());
            for (var i = 0; i < indexlist.length; i++) {
              //nextdet.add(rllist(indexlist[i]));
              nextdet.add(rllist[indexlist[i]]);
            }
            //debugPrint(nextdet.toString());
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

  Future rateteacher(String stfid, String rate) async {
    try {
      var rsp = await Stud_tchr_rate(sid, stfid, rate.replaceAll('.0', ''),
          commentController.text, token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp['status'].toString() == '1') {
        commentController.clear();
        rllist.clear();
        indexlist.clear();
        nextdet.clear();
        getteacherlist();
      } else {
        showPrintedMessage('Failed!!', 'Failed to mark rating');
        rllist.clear();
        indexlist.clear();
        nextdet.clear();
        getteacherlist();
        commentController.clear();
      }
    } catch (error) {
      //debugPrint(error.toString());
      commentController.clear();
    }
  }

  Future modalSheet(List details) async {
    //debugPrint(details.toString());
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              height: 40,
              color: CupertinoColors.secondaryLabel,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.doc_append,
                            color: CupertinoColors.white,
                            size: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Subject Details',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          CupertinoIcons.clear,
                          color: CupertinoColors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              child: Card(
                elevation: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 130,
                          child: Text(
                            'Time',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          width: 70,
                          child: Text(
                            'Day',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          width: 70,
                          child: Text(
                            'Subject',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          width: 70,
                          child: Center(
                            child: Text(
                              'Room',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: CupertinoColors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 180,
              child: ListView.builder(
                  itemCount: details.length,
                  itemBuilder: (BuildContext context, index) {
                    return Container(
                      height: 40,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 130,
                                child: Text(
                                  details[index]['time_from'] +
                                      '-' +
                                      details[index]['time_to'],
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: CupertinoColors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Text(
                                  details[index]['day'],
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: CupertinoColors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Text(
                                  details[index]['subject_name'] +
                                      ' ' +
                                      '(' +
                                      details[index]['code'] +
                                      ')',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: CupertinoColors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Container(
                                width: 70,
                                child: Center(
                                  child: Text(
                                    details[index]['room_no'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: CupertinoColors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
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
                'Teachers',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
              leading: Container(),
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
                                  itemCount: nextdet.length,
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
                                                        child: Row(
                                                      mainAxisAlignment: modulelist[
                                                                      12][
                                                                  'is_active'] ==
                                                              '1'
                                                          ? MainAxisAlignment
                                                              .spaceBetween
                                                          : MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              100,
                                                          child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                nextdet[index][
                                                                        'staff_name'] +
                                                                    '  ' +
                                                                    '(' +
                                                                    nextdet[index]
                                                                        [
                                                                        'employee_id'] +
                                                                    ')',
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )),
                                                        ),
                                                        if (modulelist[12][
                                                                    'is_active'] ==
                                                                '1' &&
                                                            nextdet[index]
                                                                        ['rate']
                                                                    .toString() ==
                                                                '0')
                                                          GestureDetector(
                                                            onTap: () {
                                                              Rate(
                                                                  context,
                                                                  nextdet[index]
                                                                          [
                                                                          'staff_id']
                                                                      .toString());
                                                            },
                                                            child: Text(
                                                                'Add Rating',
                                                                style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .blue)),
                                                          ),
                                                        if (modulelist[12][
                                                                    'is_active'] ==
                                                                '1' ||
                                                            nextdet[index]
                                                                    ['rate'] !=
                                                                '0')
                                                          if (nextdet[index]
                                                                      ['rate']
                                                                  .toString() ==
                                                              '1')
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .star,
                                                                  size: 15,
                                                                  color: CupertinoColors
                                                                      .systemYellow,
                                                                ),
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .star,
                                                                  size: 15,
                                                                ),
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .star,
                                                                  size: 15,
                                                                ),
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .star,
                                                                  size: 15,
                                                                ),
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .star,
                                                                  size: 15,
                                                                ),
                                                              ],
                                                            ),
                                                        if (nextdet[index]
                                                                    ['rate']
                                                                .toString() ==
                                                            '2')
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                              ),
                                                            ],
                                                          ),
                                                        if (nextdet[index]
                                                                    ['rate']
                                                                .toString() ==
                                                            '3')
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                              ),
                                                            ],
                                                          ),
                                                        if (nextdet[index]
                                                                    ['rate']
                                                                .toString() ==
                                                            '4')
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                              ),
                                                            ],
                                                          ),
                                                        if (nextdet[index]
                                                                    ['rate']
                                                                .toString() ==
                                                            '5')
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .star,
                                                                size: 15,
                                                                color: CupertinoColors
                                                                    .systemYellow,
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    )),
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
                                                            Icon(
                                                              Icons
                                                                  .email_outlined,
                                                              size: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              nextdet[index]
                                                                  ['email'],
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
                                                                  .view_comfy_sharp,
                                                              size: 15,
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                modalSheet(nextdet[
                                                                        index][
                                                                    'subjects']);
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
                                    'No timetable available',
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

class Customer {
  String name;
  String age;

  Customer(this.name, this.age);

  @override
  String toString() {
    return '{ ${this.name}, ${this.age} }';
  }
}
