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
import 'package:eznext/screen%20models/timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:path/path.dart' as path;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eznext/api_models/student_homework.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/upload_homework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../logoutmodel.dart';
import '../main.dart';
import 'fee.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class Homework extends StatefulWidget {
  @override
  _HomeworkState createState() => _HomeworkState();
}

class _HomeworkState extends State<Homework> {
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
  var homeworklist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool ishomeworkdetclicked = false;
  String hwrkdet = '';
  String? currentTime;
  DateTime? parseddate;
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  String variable = '';

  void gdatetime() {
    setState(() {
      currentTime = formatter1.format(DateTime.now());
    });
    //debugPrint(currentTime);
    parseddate = DateTime.parse(currentTime.toString());
    //debugPrint(parseddate.toString());
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

  //--------downloads---------//
  String _progress = "-";
  String? _fileUrl;
  String? _fileName;

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      if (isclicked == true) {
        OpenFile.open(obj['filePath']);
      }
      if (os != 'ios') {
        // MoveToBackground.moveTaskToBack();
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

  bool filedownloading = false;

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
    //debugPrint(json);

    await flutterLocalNotificationsPlugin!.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  Future<void> _startDownload(
      String savePath, String url, String tstamp) async {
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
        var myurl = siteurl.replaceAll('https://', '');
        myurl = myurl.replaceAll('.eznext.in/', '');
        _fileUrl = 'https://eznext' +
            myurl +
            '.s3.us-west-2.amazonaws.com/uploads/' +
            variable +
            '/' +
            url +
            "?q=$tstamp";
        //debugPrint(_fileUrl);
      });
    } else {
      setState(() {
        _fileUrl = 'https://eznext' +
            schoolcode +
            '.s3.us-west-2.amazonaws.com/uploads/' +
            variable +
            '/' +
            url +
            "?q=$tstamp";
        //debugPrint(_fileUrl.toString());
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
      //debugPrint('finally');
      await _showNotification(result);
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

  Future getdirectory(String url) async {
    //debugPrint(url);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/download center/$variable');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/$variable';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        //debugPrint('ssdf'+siteurl.toString());
        final savePath = path.join(dirPath, url);
        //debugPrint(url.toString());
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /*   if(a==true){
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

        await _startDownload(myspath, url, tstamp);
      } else {
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/$variable';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        final savePath = path.join(dirPath, url);
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        //debugPrint(siteurl);
        /*  if(a==true){
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

        await _startDownload(myspath, url, tstamp);
      }
    }
  }

  final myKey = new GlobalKey<_HomeworkState>();

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
    gethomework();
  }

  Future gethomework() async {
    try {
      var rsp = await Stud_hwork_get(stdid, token.toString(), uid);
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
        if (rsp['homeworklist'] != null) {
          setState(() {
            homeworklist = rsp['homeworklist'];
            initialscreen = 'screenloaded';
            gdatetime();
          });
        } else {
          setState(() {
            initialscreen = 'no homework found';
          });
        }
      }
    } catch (error) {
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  bool isclicked = false;

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
                'Homework',
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
                  color: Colors.white,
                  size: 25,
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
                              flex: ishomeworkdetclicked == false ? 6 : 4,
                              child: ListView.builder(
                                itemCount:
                                    homeworklist == [] || homeworklist == null
                                        ? 0
                                        : homeworklist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      child: Card(
                                          elevation: 0,
                                          color: CupertinoColors
                                              .extraLightBackgroundGray,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                    color: CupertinoColors
                                                        .systemGrey
                                                        .withOpacity(0.3),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5,
                                                            top: 10,
                                                            bottom: 10,
                                                            right: 5),
                                                    child: Center(
                                                        child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              homeworklist[
                                                                      index]
                                                                  ['name'],
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black),
                                                            ))),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0, top: 5),
                                                  child: Wrap(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        homeworklist[index]
                                                                ['class'] +
                                                            ' ' +
                                                            homeworklist[index]
                                                                ['section'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              200,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 1,
                                                                    top: 2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'H/W Date :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  formatter
                                                                      .format(DateTime.parse(homeworklist[index]
                                                                              [
                                                                              'homework_date']
                                                                          .toString()))
                                                                      .toString(),
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 1,
                                                                    top: 2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Submit Date :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                if (homeworklist[index]
                                                                            [
                                                                            'submit_date'] !=
                                                                        '' ||
                                                                    homeworklist[index]
                                                                            [
                                                                            'submit_date'] !=
                                                                        null)
                                                                  Text(
                                                                    formatter
                                                                        .format(
                                                                            DateTime.parse(homeworklist[index]['submit_date'].toString()))
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 1,
                                                                    top: 2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Eval. Date :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                if (homeworklist[
                                                                            index]
                                                                        [
                                                                        'evaluation_date'] !=
                                                                    '0000-00-00')
                                                                  Text(
                                                                    formatter
                                                                        .format(
                                                                            DateTime.parse(homeworklist[index]['evaluation_date'].toString()))
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 1,
                                                                    top: 2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Created By :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                if (homeworklist[
                                                                            index]
                                                                        [
                                                                        'staff_created'] !=
                                                                    null)
                                                                  Text(
                                                                    homeworklist[index]
                                                                            [
                                                                            'staff_created']
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 1,
                                                                    top: 2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Evaluated By :',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                if (homeworklist[
                                                                            index]
                                                                        [
                                                                        'staff_evaluated'] !=
                                                                    '0')
                                                                  Text(
                                                                    homeworklist[index]
                                                                            [
                                                                            'staff_evaluated']
                                                                        .toString(),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 170,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (homeworklist[
                                                                          index]
                                                                      [
                                                                      'document'] !=
                                                                  '')
                                                                Container(
                                                                  height: 30,
                                                                  child: FloatingActionButton(
                                                                      elevation: 0,
                                                                      backgroundColor: Colors.transparent,
                                                                      tooltip: "Download assigned homework",
                                                                      onPressed: () {
                                                                        if (filedownloading ==
                                                                            false) {
                                                                          setState(
                                                                              () {
                                                                            variable =
                                                                                'homework';
                                                                            filedownloading =
                                                                                true;
                                                                          });

                                                                          String
                                                                              str =
                                                                              homeworklist[index]['document'];
                                                                          //debugPrint(str.toString());
                                                                          var arr =
                                                                              str.split('.');
                                                                          //debugPrint(arr[1]);
                                                                          getdirectory(homeworklist[index]['id'] +
                                                                              '.' +
                                                                              arr[1].toString());
                                                                        }
                                                                      },
                                                                      child: Icon(
                                                                        CupertinoIcons
                                                                            .arrow_down_doc,
                                                                        color: filedownloading ==
                                                                                false
                                                                            ? CupertinoColors.systemBlue
                                                                            : CupertinoColors.systemGrey,
                                                                      )),
                                                                ),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      ishomeworkdetclicked =
                                                                          true;
                                                                      setState(
                                                                          () {
                                                                        hwrkdet = homeworklist[index]['description'].toString().replaceAll(
                                                                            RegExp(r'<[^>]*>|&[^;]+;'),
                                                                            ' ');
                                                                      });
                                                                    });
                                                                  },
                                                                  icon: Icon(
                                                                    CupertinoIcons
                                                                        .info,
                                                                    color: CupertinoColors
                                                                        .systemBlue,
                                                                  )),
                                                              if (parseddate!
                                                                          .difference(DateTime.parse(homeworklist[index]['submit_date'] +
                                                                              ' ' +
                                                                              '23:59:59'))
                                                                          .inSeconds <
                                                                      0 ||
                                                                  parseddate!
                                                                          .difference(DateTime.parse(homeworklist[index]['submit_date'] +
                                                                              ' ' +
                                                                              '23:59:59'))
                                                                          .inSeconds ==
                                                                      0)
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          CupertinoPageRoute(
                                                                              builder: (BuildContext context) => UploadHomework(
                                                                                    hid: homeworklist[index]['id'].toString(),
                                                                                  )));
                                                                    },
                                                                    icon: Icon(
                                                                      CupertinoIcons
                                                                          .arrow_up_circle,
                                                                      color: CupertinoColors
                                                                          .systemBlue,
                                                                    )),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              if (homeworklist[
                                                                              index]
                                                                          [
                                                                          'report']
                                                                      [
                                                                      'docs'] !=
                                                                  '')
                                                                Container(
                                                                  height: 30,
                                                                  child: FloatingActionButton(
                                                                      elevation: 0,
                                                                      backgroundColor: Colors.transparent,
                                                                      tooltip: "Download uploaded homework",
                                                                      onPressed: () {
                                                                        if (filedownloading ==
                                                                            false) {
                                                                          setState(
                                                                              () {
                                                                            variable =
                                                                                'homework/assignment';
                                                                            filedownloading =
                                                                                true;
                                                                          });

                                                                          getdirectory(homeworklist[index]['report']
                                                                              [
                                                                              'docs']);
                                                                        }
                                                                      },
                                                                      child: Icon(
                                                                        CupertinoIcons
                                                                            .arrow_down_circle,
                                                                        color: filedownloading ==
                                                                                false
                                                                            ? CupertinoColors.systemBlue
                                                                            : CupertinoColors.systemGrey,
                                                                      )),
                                                                ),
                                                              if (homeworklist[
                                                                              index]
                                                                          [
                                                                          'report']
                                                                      [
                                                                      'message'] !=
                                                                  '')
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        ishomeworkdetclicked =
                                                                            true;
                                                                        hwrkdet =
                                                                            homeworklist[index]['report']['message'].toString();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                      CupertinoIcons
                                                                          .chat_bubble_text,
                                                                      color: CupertinoColors
                                                                          .systemBlue,
                                                                    )),
                                                              if (homeworklist[
                                                                              index]
                                                                          [
                                                                          'teacher_remarks'] !=
                                                                      '' &&
                                                                  homeworklist[
                                                                              index]
                                                                          [
                                                                          'teacher_remarks'] !=
                                                                      null)
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        ishomeworkdetclicked =
                                                                            true;
                                                                        hwrkdet =
                                                                            homeworklist[index]['teacher_remarks'].toString();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .person_remove_outlined,
                                                                      color: CupertinoColors
                                                                          .systemBlue,
                                                                    )),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [],
                                                ),
                                                if (homeworklist[index]
                                                        ['report']['docs'] !=
                                                    '')
                                                  Container(
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5.0),
                                                      ),
                                                      color: CupertinoColors
                                                          .activeGreen,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Center(
                                                        child: Text(
                                                          'Completed',
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (homeworklist[index]
                                                        ['report']['docs'] ==
                                                    '')
                                                  Container(
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5.0),
                                                      ),
                                                      color: CupertinoColors
                                                          .systemRed,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Center(
                                                        child: Text(
                                                          'Incomplete',
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color:
                                                                  CupertinoColors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                },
                              ),
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
                                    'No homework',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        decoration: TextDecoration.none,
                                        color: CupertinoColors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )),
                if (ishomeworkdetclicked == true)
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        hwrkdet = '';
                                        ishomeworkdetclicked = false;
                                      });
                                    },
                                    child: Icon(
                                      CupertinoIcons.clear,
                                      size: 18,
                                      color: CupertinoColors.black,
                                    ))),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  hwrkdet,
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      decoration: TextDecoration.none,
                                      color: CupertinoColors.black,
                                      fontWeight: FontWeight.normal),
                                )),
                          ),
                        ],
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
                          onTap: () {},
                          child: Column(children: [
                            //         Icon(CupertinoIcons.book,color: botoomiconselectedcolor,),
                            Image.asset(
                              'assets/dash_icons/homework.png',
                              height: 30,
                              width: 30,
                            ),
                            Text(
                              'Homework',
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
                            //  Icon(CupertinoIcons.money_dollar_circle,color: botoomiconunselectedcolor,),
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
                            //Icon(CupertinoIcons.info,color: botoomiconunselectedcolor,),
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
                            //Icon(CupertinoIcons.doc_append,color: botoomiconunselectedcolor,),
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
