// Home Tab
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:eznext/app_constants/LOADER2.dart';
import 'package:eznext/app_constants/loader.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/downcentervideo.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:path/path.dart' as path;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eznext/api_models/download_center.dart';
import 'package:eznext/api_models/onlineclassapi.dart';
import 'package:eznext/api_models/onlineexam.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/homework.dart';
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
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logoutmodel.dart';
import 'classwebview.dart';
import 'mydocuments.dart';

class DownloadCenter extends StatefulWidget {
  @override
  _DownloadCenterState createState() => _DownloadCenterState();
}

class _DownloadCenterState extends State<DownloadCenter>
    with SingleTickerProviderStateMixin {
  //--------defining & initialising parameters------------//
  TabController? controller;
  double listViewOffset1 = 0.0;
  double listViewOffset2 = 0.0;
  double listViewOffset3 = 0.0;
  double listViewOffset4 = 0.0;
  //--------html tags remover---------//

  final myKey = new GlobalKey<_DownloadCenterState>();

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

  Future<bool> webViewMethod() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.microphone);
    }
    WebViewMethodForCamera();
    return permission == PermissionStatus.granted;
  }

  Future<bool> WebViewMethodForCamera() async {
    var permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.camera]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.camera);
    }
    return permission == PermissionStatus.granted;
  }

  @override
  void initState() {
    setState(() {
      controller = new TabController(
        length: 4,
        vsync: this,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
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
      backgroundColor: themecolor,
      child: Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              backgroundColor: appbarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  CupertinoIcons.back,
                  size: 30,
                  color: CupertinoColors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => MyHome()));
                },
              ),
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
                      size: 30,
                    ),
                  ),
                )
              ],
              title: Text(
                'Download Center',
                style: TextStyle(color: CupertinoColors.white, fontSize: 18),
              ),
              pinned: true,
              floating: true,
              bottom: TabBar(
                controller: controller,
                indicatorColor: CupertinoColors.white,
                labelColor: CupertinoColors.white,
                isScrollable: true,
                unselectedLabelColor: CupertinoColors.white,
                tabs: [
                  Tab(child: Text('Assignment')),
                  Tab(child: Text('Study Material')),
                  Tab(child: Text('Syllabus')),
                  Tab(child: Text('Others')),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: controller,
          children: <Widget>[
            new Assignment(
                getOffsetMethod: () => listViewOffset1,
                setOffsetMethod: (offset) => this.listViewOffset1 = offset),
            new StudyMaterial(
                getOffsetMethod: () => listViewOffset2,
                setOffsetMethod: (offset) => this.listViewOffset2 = offset),
            new Syllabus(
                getOffsetMethod: () => listViewOffset3,
                setOffsetMethod: (offset) => this.listViewOffset3 = offset),
            new Others(
                getOffsetMethod: () => listViewOffset4,
                setOffsetMethod: (offset) => this.listViewOffset4 = offset),
          ],
        ),
      )),
    );
  }
}

typedef double GetOffsetMethod();
typedef void SetOffsetMethod(double offset);

////----assignment class------///
class Assignment extends StatefulWidget {
  Assignment({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _AssignmentState createState() => new _AssignmentState();
}

class _AssignmentState extends State<Assignment> {
  bool filedownloading = false;
  ScrollController? scrollController;
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
  String secid = '';
  String classid = '';
  var startindex = 0;
  String initialscreen = 'loader';
  var datalist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat formatter2 = DateFormat('yyyy-MM-dd');
  bool istimetableloaded = false;
  String hwrkdet = '';
  int initpage = 0;
  String? currentTime;
  DateTime? parseddate;
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
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
  bool isclicked = false;
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
        var myurl = siteurl.replaceAll('https://', '');
        myurl = myurl.replaceAll('.eznext.in/', '');
        _fileUrl =
            'https://eznext' + myurl + '.s3.us-west-2.amazonaws.com/' + url;
        //debugPrint(_fileUrl);
      });
    } else {
      setState(() {
        _fileUrl = 'https://eznext' +
            schoolcode +
            '.s3.us-west-2.amazonaws.com/' +
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

  Future getdirectory(String url) async {
    //debugPrint(url);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/download center/assignment');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/assignment';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        //debugPrint(siteurl);

        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        //debugPrint(url.replaceAll('uploads/school_content/material/', '').toString());
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /*if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/assignment';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        //debugPrint('sss'+savePath);
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /*if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
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
      secid = studentdetails.getString('section_id');
      classid = studentdetails.getString('class_id');
    });
    getall();
  }

  Future getall() async {
    try {
      var rsp = await Stud_down_center(secid.toString(), classid.toString(),
          'assignments', token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == 401) {
          /* logOut(context);
          Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        */
        }
      } else {
        if (rsp['success'] == 1) {
          if (rsp['data'].isNotEmpty) {
            setState(() {
              datalist = rsp['data'];
              datalist = datalist.reversed.toList();
            });
          } else {
            setState(() {
              initialscreen = 'no homework found';
            });
          }
        }
      }
      //debugPrint(initialscreen);
    } catch (error) {
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  final myKey = new GlobalKey<_AssignmentState>();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: new NotificationListener(
        child: new ListView.builder(
          controller: scrollController,
          itemCount: datalist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: new Container(
                child: Column(
                  children: [
                    Container(
                      //height: 40,
                      width: MediaQuery.of(context).size.width,
                      color: CupertinoColors.systemGrey5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 120,
                              child: Text(
                                '  ' + datalist[index]['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Text(
                            formatter.format(DateTime.parse(
                                    datalist[index]['date'].toString())) +
                                '  ',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.35,
                              child: Text(
                                datalist[index]['note'].toString(),
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                          if (datalist[index]['is_video'] != '0')
                            IconButton(
                              icon: Icon(CupertinoIcons.eye),
                              onPressed: () {
                                setState(() {});
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            Downcvideo(
                                              urii: datalist[index]['link'],
                                            )));
                              },
                            ),
                          if (datalist[index]['is_video'] == '0')
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.cloud_download,
                                color: filedownloading == false
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey,
                              ),
                              onPressed: () {
                                if (filedownloading == false) {
                                  setState(() {
                                    filedownloading = true;
                                  });

                                  getdirectory(datalist[index]['file']);
                                }
                              },
                            )
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            );
          },
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}

////----studymaterial class------///
class StudyMaterial extends StatefulWidget {
  StudyMaterial({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _StudyMaterialState createState() => new _StudyMaterialState();
}

class _StudyMaterialState extends State<StudyMaterial> {
  bool filedownloading = false;
  ScrollController? scrollController;
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
  String secid = '';
  String classid = '';
  var startindex = 0;
  String initialscreen = 'loader';
  var datalist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat formatter2 = DateFormat('yyyy-MM-dd');
  bool istimetableloaded = false;
  String hwrkdet = '';
  int initpage = 0;
  String? currentTime;
  DateTime? parseddate;
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  final Dio _dio = Dio();

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
  bool isclicked = false;
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
        var myurl = siteurl.replaceAll('https://', '');
        myurl = myurl.replaceAll('.eznext.in/', '');
        _fileUrl =
            'https://eznext' + myurl + '.s3.us-west-2.amazonaws.com/' + url;
        //debugPrint(_fileUrl);
      });
    } else {
      setState(() {
        _fileUrl = 'https://eznext' +
            schoolcode +
            '.s3.us-west-2.amazonaws.com/' +
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

  Future getdirectory(String url) async {
    //debugPrint(url);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/download center/study material');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/study material';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        //debugPrint(siteurl);
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /*if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/study material';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /* if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
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
      secid = studentdetails.getString('section_id');
      classid = studentdetails.getString('class_id');
    });
    getall();
  }

  Future getall() async {
    try {
      var rsp = await Stud_down_center(secid.toString(), classid.toString(),
          'study material', token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == 401) {
          /*  logOut(context);
          Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
   */
        }
      } else {
        if (rsp['success'] == 1) {
          if (rsp['data'].isNotEmpty) {
            setState(() {
              datalist = rsp['data'];
              datalist = datalist.reversed.toList();
            });
          } else {
            setState(() {
              initialscreen = 'no homework found';
            });
          }
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
      child: new NotificationListener(
        child: new ListView.builder(
          controller: scrollController,
          itemCount: datalist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: new Container(
                child: Column(
                  children: [
                    Container(
                      //height: 40,
                      width: MediaQuery.of(context).size.width,
                      color: CupertinoColors.systemGrey5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 120,
                              child: Text(
                                '  ' + datalist[index]['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Text(
                            formatter.format(DateTime.parse(
                                    datalist[index]['date'].toString())) +
                                '  ',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.35,
                              child: Text(
                                datalist[index]['note'].toString(),
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                          if (datalist[index]['is_video'] != '0')
                            IconButton(
                              icon: Icon(CupertinoIcons.eye),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            Downcvideo(
                                              urii: datalist[index]['link'],
                                            )));
                              },
                            ),
                          if (datalist[index]['is_video'] == '0')
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.cloud_download,
                                color: filedownloading == false
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey,
                              ),
                              onPressed: () {
                                if (filedownloading == false) {
                                  setState(() {
                                    filedownloading = true;
                                  });

                                  getdirectory(datalist[index]['file']);
                                }
                              },
                            )
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            );
          },
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}

////----syllabus class------///
class Syllabus extends StatefulWidget {
  Syllabus({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _SyllabusState createState() => new _SyllabusState();
}

class _SyllabusState extends State<Syllabus> {
  bool filedownloading = false;
  ScrollController? scrollController;
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
  String secid = '';
  String classid = '';
  var startindex = 0;
  String initialscreen = 'loader';
  var datalist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat formatter2 = DateFormat('yyyy-MM-dd');
  bool istimetableloaded = false;
  String hwrkdet = '';
  int initpage = 0;
  String? currentTime;
  DateTime? parseddate;
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  final Dio _dio = Dio();

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
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

  //--------downloads---------//
  String _progress = "-";
  String? _fileUrl;
  String? _fileName;

  bool isclicked = false;
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
        var myurl = siteurl.replaceAll('https://', '');
        myurl = myurl.replaceAll('.eznext.in/', '');
        _fileUrl =
            'https://eznext' + myurl + '.s3.us-west-2.amazonaws.com/' + url;
        //debugPrint(_fileUrl);
      });
    } else {
      setState(() {
        _fileUrl = 'https://eznext' +
            schoolcode +
            '.s3.us-west-2.amazonaws.com/' +
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

  Future getdirectory(String url) async {
    //debugPrint(url);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/download center/syllabus');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/syllabus';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        //debugPrint(siteurl);
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /*if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/syllabus';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /* if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
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
      secid = studentdetails.getString('section_id');
      classid = studentdetails.getString('class_id');
    });
    getall();
  }

  Future getall() async {
    try {
      var rsp = await Stud_down_center(secid.toString(), classid.toString(),
          'syllabus', token.toString(), uid);
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
          if (rsp['data'].isNotEmpty) {
            setState(() {
              datalist = rsp['data'];
              datalist = datalist.reversed.toList();
            });
          } else {
            setState(() {
              initialscreen = 'no homework found';
            });
          }
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
      onWillPop: () async => false,
      child: new NotificationListener(
        child: new ListView.builder(
          controller: scrollController,
          itemCount: datalist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: new Container(
                child: Column(
                  children: [
                    Container(
                      //height: 40,
                      width: MediaQuery.of(context).size.width,
                      color: CupertinoColors.systemGrey5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 120,
                              child: Text(
                                '  ' + datalist[index]['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Text(
                            formatter.format(DateTime.parse(
                                    datalist[index]['date'].toString())) +
                                '  ',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.35,
                              child: Text(
                                datalist[index]['note'].toString(),
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                          if (datalist[index]['is_video'] != '0')
                            IconButton(
                              icon: Icon(CupertinoIcons.eye),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            Downcvideo(
                                              urii: datalist[index]['link'],
                                            )));
                              },
                            ),
                          if (datalist[index]['is_video'] == '0')
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.cloud_download,
                                color: filedownloading == false
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey,
                              ),
                              onPressed: () {
                                if (filedownloading == false) {
                                  setState(() {
                                    filedownloading = true;
                                  });

                                  getdirectory(datalist[index]['file']);
                                }
                              },
                            )
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            );
          },
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}

////----syllabus class------///
class Others extends StatefulWidget {
  Others({required this.getOffsetMethod, required this.setOffsetMethod});

  final GetOffsetMethod getOffsetMethod;
  final SetOffsetMethod setOffsetMethod;

  @override
  _OthersState createState() => new _OthersState();
}

class _OthersState extends State<Others> {
  bool filedownloading = false;
  ScrollController? scrollController;
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
  String secid = '';
  String classid = '';
  var startindex = 0;
  String initialscreen = 'loader';
  var datalist = [];
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat formatter2 = DateFormat('yyyy-MM-dd');
  bool istimetableloaded = false;
  String hwrkdet = '';
  int initpage = 0;
  String? currentTime;
  DateTime? parseddate;
  final DateFormat formatter1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
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
  bool isclicked = false;
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
        var myurl = siteurl.replaceAll('https://', '');
        myurl = myurl.replaceAll('.eznext.in/', '');
        _fileUrl =
            'https://eznext' + myurl + '.s3.us-west-2.amazonaws.com/' + url;
        //debugPrint(_fileUrl);
      });
    } else {
      setState(() {
        _fileUrl = 'https://eznext' +
            schoolcode +
            '.s3.us-west-2.amazonaws.com/' +
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

  Future getdirectory(String url) async {
    //debugPrint(url);
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/download center/others');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/others';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        //debugPrint(siteurl);
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /* if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        final String dirPath =
            '${appDocDir!.path}/$Appname/download center/others';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        final savePath = path.join(
            dirPath, url.replaceAll('uploads/school_content/material/', ''));
        bool a = await File(savePath).exists();
        //debugPrint(a.toString());
        /* if(a==true){
          showPrintedMessage('Please wait',
              "Downloading file..");
          File(savePath).delete(recursive: true);
          var ak = url.replaceAll('uploads/school_content/material/', '').toString().split(".");
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
            var nurl = url.replaceAll("uploads/school_content/material/", "");
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
        var ak = url
            .replaceAll('uploads/school_content/material/', '')
            .toString()
            .split(".");
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
          var nurl = url.replaceAll("uploads/school_content/material/", "");
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
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
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
      secid = studentdetails.getString('section_id');
      classid = studentdetails.getString('class_id');
    });
    getall();
  }

  Future getall() async {
    try {
      var rsp = await Stud_down_center(secid.toString(), classid.toString(),
          'other content', token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp.containsKey('status')) {
        if (rsp['status'] == 401) {
          /* logOut(context);
          Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
      */
        }
      } else {
        if (rsp['success'] == 1) {
          if (rsp['data'].isNotEmpty) {
            setState(() {
              datalist = rsp['data'];
              datalist = datalist.reversed.toList();
            });
          } else {
            setState(() {
              initialscreen = 'no homework found';
            });
          }
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
      onWillPop: () async => false,
      child: new NotificationListener(
        child: new ListView.builder(
          controller: scrollController,
          itemCount: datalist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: new Container(
                child: Column(
                  children: [
                    Container(
                      //height: 40,
                      width: MediaQuery.of(context).size.width,
                      color: CupertinoColors.systemGrey5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 120,
                              child: Text(
                                '  ' + datalist[index]['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Text(
                            formatter.format(DateTime.parse(
                                    datalist[index]['date'].toString())) +
                                '  ',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.35,
                              child: Text(
                                datalist[index]['note'].toString(),
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                          if (datalist[index]['is_video'] != '0')
                            IconButton(
                              icon: Icon(CupertinoIcons.eye),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) =>
                                            Downcvideo(
                                              urii: datalist[index]['link'],
                                            )));
                              },
                            ),
                          if (datalist[index]['is_video'] == '0')
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.cloud_download,
                                color: filedownloading == false
                                    ? CupertinoColors.systemBlue
                                    : CupertinoColors.systemGrey,
                              ),
                              onPressed: () {
                                if (filedownloading == false) {
                                  setState(() {
                                    filedownloading = true;
                                  });

                                  getdirectory(datalist[index]['file']);
                                }
                              },
                            )
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            );
          },
        ),
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            widget.setOffsetMethod(notification.metrics.pixels);
          }
          return true;
        },
      ),
    );
  }
}
