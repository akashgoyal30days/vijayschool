// Home Tab
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:eznext/app_constants/LOADER2.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eznext/api_models/stud_timeline.dart';
import 'package:eznext/api_models/stud_timetable.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import '../main.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
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
  var timeline = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  bool isclicked = false;
  //--------downloads---------//
  String _progress = "-";
  String? _fileUrl;
  String? _fileName;
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

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  final Dio _dio = Dio();

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  final myKey = new GlobalKey<_TimeLineState>();

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

  bool filedownloading = false;

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      if (isclicked == true) {
        OpenFile.open(obj['filePath']);
      }
    } else {
      if (isclicked == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('${obj['error']}'),
          ),
        );
      }
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    setState(() {
      filedownloading = false;
    });
    final android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        priority: Priority.High, importance: Importance.Max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android, iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin!.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  Future<void> _startDownload(String savePath, String url) async {
    setState(() {
      isclicked = true;
    });
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    if (schoolcode == '') {
      setState(() {
        _fileUrl = siteurl + 'uploads/student_timeline' + '/' + url;
      });
    } else {
      setState(() {
        _fileUrl = 'https://' +
            schoolcode +
            '.eznext.in/' +
            'uploads/student_timeline' +
            '/' +
            url;
      });
    }

    try {
      final response = await _dio.download(_fileUrl, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
    }
  }

  @override
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    final initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin!
        .initialize(initSettings, onSelectNotification: _onSelectNotification);
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
    gettimeline();
  }

  Future gettimeline() async {
    try {
      var rsp = await Stud_timeline(stdid, token.toString(), uid);
      //debugPrint(rsp.toString());
      setState(() {
        timeline = rsp;
        initialscreen = 'screenloaded';
      });
      if (rsp == [] || rsp == null) {
        setState(() {
          initialscreen = 'no homework found';
        });
      }
      if (rsp[0]['status'] == 401) {
        logOut(context);
        Toast.show(unautherror, context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            backgroundRadius: 5);
      }
      //debugPrint(initialscreen);
    } catch (error) {
      //debugPrint(error.toString());
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  Future<bool> _requestPermissions() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }

  bool debug = true;
  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }

  Directory? appDocDir;
  String? filePath;
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    //debugPrint('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future getdirectory(String url) async {
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/timeline');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/timeline';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        //debugPrint(siteurl);
        final savePath = path.join(dirPath, url);
        //debugPrint(url.toString());
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /* if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.toString().split(".");
          //debugPrint(ak.toString());
          var tstamp;
          var newfname;
          var myspath;
          setState(() {
            tstamp = DateTime.now().toString().replaceAll(" ", "");
            tstamp = tstamp.replaceAll("-", "");
            tstamp= tstamp.replaceAll(":", "");
            tstamp=tstamp.replaceAll(".", "");
            newfname = tstamp+'.'+ak[1].toString();
            var nurl = url;
            myspath = savePath.replaceAll(nurl, "");
            myspath = myspath+newfname;
          });
          //debugPrint(newfname);
          //debugPrint(savePath);

          await _startDownload(myspath, url);
        }else {
          showPrintedMessage('Please wait',
              "Downloading file..");
          await _startDownload(savePath, url);
        }*/
        showPrintedMessage('Please wait', "Downloading file..");
        File(savePath).delete(recursive: true);
        var ak = url.toString().split(".");
        //debugPrint(ak.toString());
        var tstamp;
        var newfname;
        var myspath;
        setState(() {
          tstamp = DateTime.now().toString().replaceAll(" ", "");
          tstamp = tstamp.replaceAll("-", "");
          tstamp = tstamp.replaceAll(":", "");
          tstamp = tstamp.replaceAll(".", "");
          newfname = tstamp + '.' + ak[1].toString();
          var nurl = url;
          myspath = savePath.replaceAll(nurl, "");
          myspath = myspath + newfname;
        });
        //debugPrint(newfname);
        //debugPrint(savePath);

        await _startDownload(myspath, url);
      } else {
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/timeline';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        final savePath = path.join(dirPath, url);
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /* if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.toString().split(".");
          //debugPrint(ak.toString());
          var tstamp;
          var newfname;
          var myspath;
          setState(() {
            tstamp = DateTime.now().toString().replaceAll(" ", "");
            tstamp = tstamp.replaceAll("-", "");
            tstamp= tstamp.replaceAll(":", "");
            tstamp=tstamp.replaceAll(".", "");
            newfname = tstamp+'.'+ak[1].toString();
            var nurl = url;
            myspath = savePath.replaceAll(nurl, "");
            myspath = myspath+newfname;
          });
          //debugPrint(newfname);
          //debugPrint(savePath);

          await _startDownload(myspath, url);
        }else {
          showPrintedMessage('Please wait',
              "Downloading file..");
          await _startDownload(savePath, url);
        }*/
        showPrintedMessage('Please wait', "Downloading file..");
        File(savePath).delete(recursive: true);
        var ak = url.toString().split(".");
        //debugPrint(ak.toString());
        var tstamp;
        var newfname;
        var myspath;
        setState(() {
          tstamp = DateTime.now().toString().replaceAll(" ", "");
          tstamp = tstamp.replaceAll("-", "");
          tstamp = tstamp.replaceAll(":", "");
          tstamp = tstamp.replaceAll(".", "");
          newfname = tstamp + '.' + ak[1].toString();
          var nurl = url;
          myspath = savePath.replaceAll(nurl, "");
          myspath = myspath + newfname;
        });
        //debugPrint(newfname);
        //debugPrint(savePath);

        await _startDownload(myspath, url);
      }
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
              backgroundColor: appbarcolor,
              leading: Container(),
              middle: Text(
                'Timeline',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
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
                                  itemCount: timeline.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .circle_fill,
                                                          size: 15,
                                                          color: CupertinoColors
                                                              .systemOrange,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          timeline[index]
                                                              ['title'],
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 25),
                                                      child: Text(
                                                        formatter.format(DateTime
                                                            .parse(timeline[
                                                                        index][
                                                                    'timeline_date']
                                                                .toString())),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 13),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 25),
                                                      child: Text(
                                                        timeline[index]
                                                            ['description'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (timeline[index]['document']
                                                  .isNotEmpty)
                                                IconButton(
                                                  icon: Icon(
                                                    CupertinoIcons
                                                        .arrow_down_circle_fill,
                                                    size: 30,
                                                    color:
                                                        filedownloading == false
                                                            ? CupertinoColors
                                                                .systemBlue
                                                            : CupertinoColors
                                                                .systemGrey,
                                                  ),
                                                  onPressed: () {
                                                    if (filedownloading ==
                                                        false) {
                                                      setState(() {
                                                        filedownloading = true;
                                                      });

                                                      getdirectory(
                                                          timeline[index]
                                                              ['document']);
                                                    }
                                                  },
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
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
                                    'No timeline available',
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
}
