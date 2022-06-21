import 'dart:io';

import 'package:eznext/api_models/student_login.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/popup.dart';
import 'package:eznext/screen%20models/driver/driver_dashboard.dart';
import 'package:eznext/screen%20models/parent/parent_dashboard_primary.dart';
import 'package:eznext/screen%20models/schoolcode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final myKey = new GlobalKey<_LoginState>();
  dynamic usernameController = TextEditingController();
  dynamic passwordController = TextEditingController();
  FocusNode textSecondFocusNode = new FocusNode();
  String applogo = '';
  String siteurl = '';
  bool enabled = true;

  @override
  void initState() {
    tokens();
    if (schoolcode == '') {
      getlogo();
    }
    super.initState();
  }

  void tokens() async {
    await Firebase.initializeApp();
    FirebaseMessaging messagings = FirebaseMessaging.instance;
    SharedPreferences studentdetails = await SharedPreferences.getInstance();
    setState(() {
      os = Platform.operatingSystem;
      //debugPrint(os);

      //---getting username----//

      //----saving firebasetoken---//

      messagings.getToken().then((token) {
        studentdetails.setString('fbasetoken', token);
      });
      devtoken = studentdetails.getString('fbasetoken');
      //debugPrint(devtoken);
    });
  }

  void getlogo() async {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    setState(() {
      applogo = initialschoolcode.getString('app_logo');
      siteurl = initialschoolcode.getString('site_url');
      //debugPrint(siteurl);
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
    return CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // SizedBox(
                  //   height: 30,
                  // ),
                  if (schoolcode == '')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset("assets/splash.png")),
                    ),
                  if (schoolcode != '')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/schoollogo.jpeg',
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Text(
                      'Welcome!',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 8, 8),
                    child: Text(
                      'Login Here,',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 50,
                      child: CupertinoTextField(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        enabled: enabled,
                        controller: usernameController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(textSecondFocusNode);
                        },
                        suffix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            CupertinoIcons.person,
                            color: CupertinoColors.white,
                          ),
                        ),
                        placeholder: "Username",
                        placeholderStyle: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.white),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 50,
                      child: CupertinoTextField(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        focusNode: textSecondFocusNode,
                        enabled: enabled,
                        obscureText: true,
                        obscuringCharacter: '*',
                        controller: passwordController,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        suffix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(CupertinoIcons.padlock,
                              color: CupertinoColors.white),
                        ),
                        placeholder: "Password",
                        placeholderStyle: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.white),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            )),
                        child: RaisedButton(
                            elevation: 0,
                            color: Colors.transparent,
                            child: Text(
                              'Login Now',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.white),
                            ),
                            onPressed: () async {
                              if (usernameController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                var uname = usernameController.text;
                                var pass = passwordController.text;
                                setState(() {
                                  enabled = false;
                                });
                                try {
                                  var rsp = await Stud_login(uname, pass);
                                  if (rsp.containsKey('status')) {
                                    setState(() {
                                      enabled = true;
                                    });
                                    if (rsp['status'] == 200) {
                                      Toast.show(
                                          rsp['message'].toString(), context,
                                          duration: Toast.LENGTH_LONG,
                                          gravity: Toast.BOTTOM,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          backgroundRadius: 5);
                                      //--------saving student data locally in session ----------//
                                      SharedPreferences studentdetails =
                                          await SharedPreferences.getInstance();
                                      //--------navigating to dashboard screen--------//

                                      if (rsp['role'] == "student") {
                                        studentdetails.setString(
                                            'role', rsp['role'].toString());
                                        studentdetails.setString(
                                            'id', rsp['id'].toString());
                                        studentdetails.setString(
                                            'token', rsp['token'].toString());
                                        studentdetails.setString(
                                            'username',
                                            rsp['record']['username']
                                                .toString());
                                        studentdetails.setString(
                                            'student_id',
                                            rsp['record']['student_id']
                                                .toString());
                                        studentdetails.setString('class',
                                            rsp['record']['class'].toString());
                                        studentdetails.setString(
                                            'class_id',
                                            rsp['record']['class_id']
                                                .toString());
                                        studentdetails.setString(
                                            'section',
                                            rsp['record']['section']
                                                .toString());
                                        studentdetails.setString(
                                            'section_id',
                                            rsp['record']['section_id']
                                                .toString());
                                        studentdetails.setString('image',
                                            rsp['record']['image'].toString());
                                        studentdetails.setString(
                                            'currency_symbol',
                                            rsp['record']['currency_symbol']
                                                .toString());
                                        studentdetails.setString(
                                            'sch_name',
                                            rsp['record']['sch_name']
                                                .toString());
                                        Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        MyHome()));
                                      }
                                      if (rsp['role'] == "parent") {
                                        studentdetails.setString(
                                            'role', rsp['role'].toString());
                                        studentdetails.setString(
                                            'id', rsp['id'].toString());
                                        studentdetails.setString(
                                            'token', rsp['token'].toString());
                                        studentdetails.setString(
                                            'student_id',
                                            rsp['record']['student_id']
                                                .toString());
                                        studentdetails.setString(
                                            'username',
                                            rsp['record']['username']
                                                .toString());
                                        studentdetails.setString('class',
                                            rsp['record']['class'].toString());
                                        studentdetails.setString(
                                            'class_id',
                                            rsp['record']['class_id']
                                                .toString());
                                        studentdetails.setString(
                                            'section',
                                            rsp['record']['section']
                                                .toString());
                                        studentdetails.setString(
                                            'section_id',
                                            rsp['record']['section_id']
                                                .toString());
                                        studentdetails.setString(
                                            'currency_symbol',
                                            rsp['record']['currency_symbol']
                                                .toString());
                                        studentdetails.setString(
                                            'sch_name',
                                            rsp['record']['sch_name']
                                                .toString());
                                        List a = rsp['record']['parent_childs'];
                                        List<String> sid = [];
                                        List<String> sclass = [];
                                        List<String> ssection = [];
                                        List<String> sclsid = [];
                                        List<String> ssecid = [];
                                        List<String> sname = [];
                                        List<String> simage = [];
                                        for (var i = 0; i < a.length; i++) {
                                          sid.add(rsp['record']['parent_childs']
                                                  [i]['student_id']
                                              .toString());
                                          sclass.add(rsp['record']
                                                  ['parent_childs'][i]['class']
                                              .toString());
                                          ssection.add(rsp['record']
                                                      ['parent_childs'][i]
                                                  ['section']
                                              .toString());
                                          sclsid.add(rsp['record']
                                                      ['parent_childs'][i]
                                                  ['class_id']
                                              .toString());
                                          ssecid.add(rsp['record']
                                                      ['parent_childs'][i]
                                                  ['section_id']
                                              .toString());
                                          sname.add(rsp['record']
                                                  ['parent_childs'][i]['name']
                                              .toString());
                                          simage.add(rsp['record']
                                                  ['parent_childs'][i]['image']
                                              .toString());
                                        }
                                        if (a.length > 1) {
                                          studentdetails.setStringList(
                                              "childids", sid);
                                          studentdetails.setStringList(
                                              "childcls", sclass);
                                          studentdetails.setStringList(
                                              "childsections", ssection);
                                          studentdetails.setStringList(
                                              "childclsid", sclsid);
                                          studentdetails.setStringList(
                                              "childsecid", ssecid);
                                          studentdetails.setStringList(
                                              "childname", sname);
                                          studentdetails.setStringList(
                                              "childimage", simage);
                                          Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ParentHome()));
                                        }
                                        if (a.length <= 1) {
                                          setState(() {
                                            studentdetails.setStringList(
                                                "childids", sid);
                                            studentdetails.setStringList(
                                                "childcls", sclass);
                                            studentdetails.setStringList(
                                                "childsections", ssection);
                                            studentdetails.setStringList(
                                                "childclsid", sclsid);
                                            studentdetails.setStringList(
                                                "childsecid", ssecid);
                                            studentdetails.setStringList(
                                                "childname", sname);
                                            studentdetails.setStringList(
                                                "childimage", simage);
                                            studentdetails.setString(
                                                'student_id', sid[0]);
                                            studentdetails.setString(
                                                'student_name', sname[0]);
                                            studentdetails.setString(
                                                'class', sclass[0]);
                                            studentdetails.setString(
                                                'class_id', sclsid[0]);
                                            studentdetails.setString(
                                                'section', ssection[0]);
                                            studentdetails.setString(
                                                'section_id', ssecid[0]);
                                            studentdetails.setString(
                                                'image', simage[0]);
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            Navigator.pushReplacement(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        MyHome()));
                                          });
                                        }
                                      }
                                      if (rsp["role"] == "driver") {
                                        await studentdetails.setString(
                                            'role', "driver");
                                        await studentdetails.setString(
                                            'id', rsp['id'].toString());
                                        await studentdetails.setString(
                                            'token', rsp['token'].toString());
                                        await studentdetails.setString(
                                            'username',
                                            rsp['record']['username']
                                                .toString());
                                        await studentdetails.setString('image',
                                            rsp['record']['image'].toString());
                                        await studentdetails.setString(
                                            'currency_symbol',
                                            rsp['record']['currency_symbol']
                                                .toString());
                                        await studentdetails.setString('route',
                                            rsp['record']['route'].toString());
                                        await studentdetails.setString(
                                            'route_id',
                                            rsp['record']['route_id']
                                                .toString());
                                        Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        DriverDashboard()));
                                      }
                                    } else {
                                      Toast.show(
                                          rsp['message'].toString(), context,
                                          duration: Toast.LENGTH_LONG,
                                          gravity: Toast.BOTTOM,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          backgroundRadius: 5);
                                    }
                                  }
                                } catch (error) {
                                  //debugPrint(error.toString());
                                  setState(() {
                                    enabled = true;
                                  });
                                  Toast.show(error.toString(), context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      backgroundRadius: 5);
                                }
                              } else {
                                PopUps.showPopDialoguge(context, myKey,
                                    'Please fill all fields', 'error');
                              }
                            }),
                      ),
                      /*       Container(height: 20, child: VerticalDivider(color: CupertinoColors.systemBlue)),
                    CupertinoButton(child: Text('Forgot Password ?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),), onPressed: (){}),*/
                    ],
                  ),
                  // if (enabled == true) Spacer(),
                  if (enabled == false)
                    Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  if (enabled == false)
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Hold on.. processing request',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.blue,
                              decoration: TextDecoration.none),
                        )),
                  if (os != 'ios')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.download_circle,
                                size: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Dowload Teacher's App",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            _launchURL(
                                'https://play.google.com/store/apps/details?id=com.in30days.eznextadmin');
                          }),
                    ),
                  if (schoolcode == '')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CupertinoButton(
                            child: Text(
                              'Privacy Policy',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              _launchURL('https://eznext.in/privacy-policy/');
                            }),
                        Container(
                            height: 20,
                            child: VerticalDivider(
                                color: CupertinoColors.systemBlue)),
                        CupertinoButton(
                            child: Text(
                              'Change Branch',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              SharedPreferences initialschoolcode =
                                  await SharedPreferences.getInstance();
                              initialschoolcode.clear();
                              Future.delayed(const Duration(seconds: 0), () {
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            Scode()));
                              });
                            }),
                      ],
                    ),
                  if (schoolcode != '')
                    Align(
                      alignment: Alignment.center,
                      child: CupertinoButton(
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            _launchURL('https://eznext.in/privacy-policy/');
                          }),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Powered by EZNEXT School ERP',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: CupertinoColors.white,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            );
          },
        ));
  }
}
