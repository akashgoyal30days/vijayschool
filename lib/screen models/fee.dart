// Home Tab
import 'dart:convert';
import 'dart:math';

import 'package:eznext/api_models/fees_api.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/fee_pay.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_state/extensions_static.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import 'noticeboard.dart';

class Fees extends StatefulWidget {
  @override
  _FeesState createState() => _FeesState();
}

class _FeesState extends State<Fees> {
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
  String paymethod = '';
  var studfeedet = [];
  var grandfee;
  var paidlist;
  List newpaidlist = [];
  var feelist = [];
  var alldates = [];
  var differencedates = [];
  var unpaidindex = [];
  var discount = [];
  bool isdiscountClicked = false;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  bool onpayclicked = false;
  bool onviewClicked = false;
  String paydescripttext = '';
  String payamount = '0';
  String disamount = '0';
  String totalamountpay = '0';
  String paymonth = '';
  String feemasterid = '';
  String feegrpid = '';
  List indexlist = [];
  var nextdet = [];
  String payid = '';
  //--------html tags remover---------//

  //--------navigation menu bar---------------------//
  void _showPopupMenu() async {
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(600, 100, 0, 100),
        items: [
          /*      PopupMenuItem(
            value: 1,
            child: Center(
              child: Text('Profile',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('Timeline',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('My Documents',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('Teachers',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('Hostels',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('About School',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('Feedback',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text('Partner Offer',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),),
            ),
          ),*/
          PopupMenuItem(
            value: 2,
            child: Center(
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ]);
  }

  @override
  void initState() {
    gettingSavedData();
    super.initState();
  }

  int indexval = 0;
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
    getFeeList();
  }

  Future getFeeList() async {
    try {
      var rsp = await Stud_fee(stdid, token.toString(), uid);
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
          paymethod = rsp['pay_method'].toString();
          grandfee = rsp['grand_fee'];
          discount = rsp['student_discount_fee'];
        });
        if (rsp['student_due_fee'] != '' || rsp['student_due_fee'] != []) {
          setState(() {
            initialscreen = 'screenloaded';
            studfeedet = rsp['student_due_fee'];

            //  feelist = rsp['student_due_fee'][0]['fees'];
            for (var i = 0; i < studfeedet.length; i++) {
              setState(() {
                feelist.addAll(studfeedet[i]['fees']);
              });
            }

            for (var k = 0; k < feelist.length; k++) {
              setState(() {
                if (feelist[k]['status'] == 'unpaid' ||
                    feelist[k]['status'] == 'partial') {
                  unpaidindex.add(k);
                  alldates.add(feelist[k]['due_date']);
                }
              });
            }
            if (alldates.isNotEmpty) {
              for (var n = 0; n < alldates.length; n++) {
                setState(() {
                  DateTime dob = DateTime.parse(alldates[n].toString());
                  Duration dur = DateTime.now().difference(dob);
                  String differenceInYears = (dur.inDays).toString();
                  //debugPrint(differenceInYears + ' days');
                  differencedates.add(int.parse(differenceInYears));
                });
              }
              //debugPrint('k');
              var largest_value = differencedates[0];
              var smallest_value = differencedates[0];
              for (var i = 0; i < differencedates.length; i++) {
                if (differencedates[i] > largest_value) {
                  largest_value = differencedates[i];
                }
                if (differencedates[i] < smallest_value) {
                  smallest_value = differencedates[i];
                }
              }
              //debugPrint(largest_value.toString());
              var index = differencedates.indexOf(largest_value);
              //debugPrint('ii' + index.toString());
              setState(() {
                indexval = int.parse(index.toString());
              });

              //debugPrint(feelist.toString());
              //debugPrint(feelist.length.toString());
              //debugPrint(alldates.toString());
              //debugPrint(differencedates.toString());
              //debugPrint(unpaidindex.toString());
              final yMin = differencedates.cast<num>().reduce(min);
              final yMax = differencedates.cast<num>().reduce(max);
              //debugPrint(yMin.toString()); // 1
              //debugPrint(yMax.toString()); //92
              //debugPrint('dis - $discount');
              ////debugPrint(feelist);
            }
          });
        } else {
          setState(() {
            initialscreen = 'no homework found';
          });
        }
      }
      //debugPrint('aa-'+initialscreen);
    } catch (error, stacktrace) {
      //debugPrint(error.toString());
      //debugPrint(stacktrace.toString());
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
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                initialscreen == 'loader'
                    ? Container(
                        height: MediaQuery.of(context).size.height - 70,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.8,
                          ),
                        ))
                    : initialscreen == 'screenloaded'
                        ? Container(
                            height: MediaQuery.of(context).size.height - 80,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 110,
                                  width: MediaQuery.of(context).size.width,
                                  color: CupertinoColors.white,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 30,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: CupertinoColors.systemGrey5,
                                          child: Center(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    ' ' + 'Grand Fee',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ))),
                                        ),
                                        Container(
                                          height: 20,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ' ' + 'Amount : ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '₹' +
                                                        ' ' +
                                                        grandfee['amount'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    ' ' + 'Discount : ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '₹' +
                                                        ' ' +
                                                        grandfee[
                                                            'amount_discount'] +
                                                        ' ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 20,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ' ' + 'Paid : ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '₹' +
                                                        ' ' +
                                                        grandfee['amount_paid'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    ' ' + 'Balance : ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '₹' +
                                                        ' ' +
                                                        grandfee[
                                                            'amount_remaining'] +
                                                        ' ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 20,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ' ' + 'Fine : ',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    '₹' +
                                                        ' ' +
                                                        grandfee['amount_fine'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isdiscountClicked == false)
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount: feelist.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              child: Card(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 120,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height: 30,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            color:
                                                                CupertinoColors
                                                                    .systemGrey5,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      ' ' +
                                                                          feelist[index]
                                                                              [
                                                                              'name'] +
                                                                          ' ' +
                                                                          '-' +
                                                                          ' ' +
                                                                          feelist[index]
                                                                              [
                                                                              'code'],
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    )),
                                                                if (feelist[index]
                                                                            [
                                                                            'status'] ==
                                                                        'paid' ||
                                                                    feelist[index]
                                                                            [
                                                                            'status'] ==
                                                                        'partial')
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          onviewClicked =
                                                                              true;
                                                                          payid =
                                                                              feelist[index]['id'].toString();
                                                                          paidlist =
                                                                              feelist[index]['amount_detail'];
                                                                          //debugPrint(paidlist);
                                                                          //debugPrint(paidlist.runtimeType.toString());
                                                                          Map valueMap =
                                                                              json.decode(paidlist);
                                                                          //debugPrint(valueMap.toString());
                                                                          indexlist = valueMap
                                                                              .keys
                                                                              .toList();
                                                                          //debugPrint(indexlist.toString());
                                                                          nextdet
                                                                              .clear();
                                                                          for (var i = 0;
                                                                              i < indexlist.length;
                                                                              i++) {
                                                                            //nextdet.add(rllist(indexlist[i]));
                                                                            nextdet.add(valueMap[indexlist[i]]);
                                                                          }
                                                                          //debugPrint(nextdet.toString());
                                                                        });
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        'View',
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ))
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          ' ' +
                                                                              'Due Date : ',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                        Text(
                                                                          formatter
                                                                              .format(DateTime.parse(feelist[index]['due_date'].toString()))
                                                                              .toString(),
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400,
                                                                              letterSpacing: 1),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      height:
                                                                          20,
                                                                      color: feelist[index]['status'] ==
                                                                              'unpaid'
                                                                          ? CupertinoColors
                                                                              .systemRed
                                                                          : feelist[index]['status'] == 'partial'
                                                                              ? CupertinoColors.systemYellow
                                                                              : CupertinoColors.activeGreen,
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                4,
                                                                            right:
                                                                                4),
                                                                        child: Center(
                                                                            child: Text(
                                                                          feelist[index]
                                                                              [
                                                                              'status'],
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: CupertinoColors.white),
                                                                        )),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      ' ' +
                                                                          'Amount : ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    Text(
                                                                      ' ' +
                                                                          '₹' +
                                                                          ' ' +
                                                                          feelist[index]['amount']
                                                                              .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          letterSpacing:
                                                                              1),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      ' ' +
                                                                          'Paid Amt. : ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    Text(
                                                                      ' ' +
                                                                          '₹' +
                                                                          ' ' +
                                                                          feelist[index]['total_amount_paid']
                                                                              .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          letterSpacing:
                                                                              1),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          ' ' +
                                                                              'Balance Amt. : ',
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                        Text(
                                                                          ' ' +
                                                                              '₹' +
                                                                              ' ' +
                                                                              feelist[index]['total_amount_remaining'].toString(),
                                                                          style: GoogleFonts.poppins(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400,
                                                                              letterSpacing: 1),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    if (unpaidindex
                                                                        .isNotEmpty)
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (index ==
                                                                              unpaidindex[indexval]) {
                                                                            setState(() {
                                                                              onpayclicked = true;
                                                                              payamount = feelist[index]['amount'].toString();
                                                                              paymonth = feelist[index]['type'].toString();
                                                                              disamount = feelist[index]['total_amount_discount'].toString();
                                                                              totalamountpay = feelist[index]['total_amount_remaining'].toString();
                                                                              feegrpid = feelist[index]['fee_groups_feetype_id'].toString();
                                                                              feemasterid = feelist[index]['id'].toString();
                                                                            });
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              20,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 4, right: 4),
                                                                            child: Center(
                                                                                child: Text(
                                                                              '₹' + ' ' + 'Pay' + ' ',
                                                                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: index == unpaidindex[indexval] ? CupertinoColors.systemIndigo : CupertinoColors.systemGrey5, letterSpacing: 1),
                                                                            )),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (unpaidindex
                                                                        .isEmpty)
                                                                      Container(
                                                                        height:
                                                                            20,
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left: 4,
                                                                              right: 4),
                                                                          child: Center(
                                                                              child: Text(
                                                                            '₹' +
                                                                                ' ' +
                                                                                'Pay' +
                                                                                ' ',
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: CupertinoColors.systemGrey5,
                                                                                letterSpacing: 1),
                                                                          )),
                                                                        ),
                                                                      )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })),
                                if (isdiscountClicked == true)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isdiscountClicked = false;
                                        });
                                      },
                                      child: Text('Back'),
                                    ),
                                  ),
                                if (isdiscountClicked == true)
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount: discount.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              child: Card(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 100,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height: 30,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            color:
                                                                CupertinoColors
                                                                    .systemGrey5,
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  ' ' +
                                                                      'Discount' +
                                                                      ' ' +
                                                                      '-' +
                                                                      ' ' +
                                                                      discount[
                                                                              index]
                                                                          [
                                                                          'name'] +
                                                                      '  ' +
                                                                      '[Code - ${discount[index]['code']}]',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                )),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      ' ' +
                                                                          'Discount of ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    Text(
                                                                      ' ' +
                                                                          '₹' +
                                                                          ' ' +
                                                                          discount[index]['amount']
                                                                              .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          letterSpacing:
                                                                              1),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      ' ' +
                                                                          'Status : ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    Text(
                                                                      ' ' +
                                                                          discount[index]['status']
                                                                              .toString(),
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          letterSpacing:
                                                                              1),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      ' ' +
                                                                          'Description : ',
                                                                      style: GoogleFonts.poppins(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    if (discount[index]
                                                                            [
                                                                            'student_fees_discount_description'] !=
                                                                        null)
                                                                      Text(
                                                                        ' ' +
                                                                            discount[index]['student_fees_discount_description'].toString(),
                                                                        style: GoogleFonts.poppins(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            letterSpacing: 1),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })),
                                if (discount.isNotEmpty &&
                                    isdiscountClicked == false &&
                                    onpayclicked == false)
                                  Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    color: CupertinoColors.systemBlue,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ' ' + 'Discount available',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: CupertinoColors.white,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isdiscountClicked = true;
                                            });
                                          },
                                          child: Text(
                                            'View' + '   ',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: CupertinoColors.white,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                if (onpayclicked == true)
                                  Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    color: CupertinoColors
                                        .extraLightBackgroundGray,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Fees Payment Details',
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: CupertinoColors.systemBlue,
                                              decoration: TextDecoration.none),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ' ' + 'Description : ',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Text(
                                              ' ' + paydescripttext,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ' ' + 'Amount : ',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Text(
                                              '₹' +
                                                  payamount +
                                                  ' ' +
                                                  ',' +
                                                  ' ' +
                                                  paymonth,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ' ' + 'Discount : ',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Text(
                                              '₹' + disamount,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ' ' + 'Total : ',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Text(
                                              '₹' + totalamountpay,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  onpayclicked = false;
                                                });
                                              },
                                              child: Text(
                                                'Back',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: CupertinoColors
                                                        .systemRed,
                                                    decoration:
                                                        TextDecoration.none),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                //debugPrint('a');
                                                if (schoolcode == '') {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Pay_Fee(
                                                                  urii: siteurl +
                                                                      'api/' +
                                                                      'payment/index/' +
                                                                      feemasterid +
                                                                      '/' +
                                                                      feegrpid +
                                                                      '/' +
                                                                      stdid)));
                                                } else {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Pay_Fee(
                                                                  urii: 'https://' +
                                                                      schoolcode +
                                                                      '.eznext.in/' +
                                                                      'app/' +
                                                                      'payment/index/' +
                                                                      feemasterid +
                                                                      '/' +
                                                                      feegrpid +
                                                                      '/' +
                                                                      stdid)));
                                                }
                                              },
                                              child: Text(
                                                'Pay Now' + ' ',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: CupertinoColors
                                                        .systemBlue,
                                                    decoration:
                                                        TextDecoration.none),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                if (onviewClicked == true)
                                  Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    color: CupertinoColors.systemGrey5,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 30,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: CupertinoColors.black,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  ' ' + 'Paid Fee Details',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          CupertinoColors.white,
                                                      decoration:
                                                          TextDecoration.none),
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        onviewClicked = false;
                                                        nextdet.clear();
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Icon(
                                                        CupertinoIcons.clear,
                                                        color: CupertinoColors
                                                            .white,
                                                        size: 20,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              ' ' + 'Id',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Container(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  ' ' + 'Date',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          CupertinoColors.black,
                                                      decoration:
                                                          TextDecoration.none),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              ' ' + 'Discount',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Text(
                                              ' ' + 'Fine',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                            Text(
                                              ' ' + 'Paid',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: CupertinoColors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 130,
                                          child: ListView.builder(
                                              itemCount: nextdet.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      index) {
                                                return Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        ' ' +
                                                            payid +
                                                            '/' +
                                                            (index + 1)
                                                                .toString() +
                                                            '\n' +
                                                            '(' +
                                                            nextdet[index][
                                                                    'payment_mode']
                                                                .toString() +
                                                            ')',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            decoration:
                                                                TextDecoration
                                                                    .none),
                                                      ),
                                                      Container(
                                                        width: 100,
                                                        child: Text(
                                                          ' ' +
                                                              formatter.format(DateTime
                                                                  .parse(nextdet[
                                                                              index]
                                                                          [
                                                                          'date']
                                                                      .toString())),
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  CupertinoColors
                                                                      .black,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none),
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹' +
                                                            ' ' +
                                                            nextdet[index][
                                                                    'amount_discount']
                                                                .toString(),
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            decoration:
                                                                TextDecoration
                                                                    .none),
                                                      ),
                                                      Text(
                                                        '  ' +
                                                            '₹' +
                                                            ' ' +
                                                            nextdet[index][
                                                                    'amount_fine']
                                                                .toString(),
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            decoration:
                                                                TextDecoration
                                                                    .none),
                                                      ),
                                                      Text(
                                                        '₹' +
                                                            ' ' +
                                                            nextdet[index]
                                                                    ['amount']
                                                                .toString(),
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            decoration:
                                                                TextDecoration
                                                                    .none),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          )
                        : initialscreen == 'error'
                            ? Container(
                                height: MediaQuery.of(context).size.height - 70,
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
                                height: MediaQuery.of(context).size.height - 70,
                                child: Center(
                                  child: Text(
                                    'No fees',
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
                                    fullscreenDialog: true,
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
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    fullscreenDialog: true,
                                    builder: (BuildContext context) =>
                                        Homework()));
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
                          onTap: () {},
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
                                color: botoomiconselectedcolor,
                                decoration: TextDecoration.none,
                              ),
                            )
                          ]),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    fullscreenDialog: true,
                                    builder: (BuildContext context) =>
                                        NoticeBoard()));
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
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    fullscreenDialog: true,
                                    builder: (BuildContext context) =>
                                        StudenExam()));
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
