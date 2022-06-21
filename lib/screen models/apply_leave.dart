// Home Tab
import 'dart:convert';
import 'dart:io';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eznext/api_models/applyleave_api.dart';
import 'package:eznext/api_models/student_homework.dart';
import 'package:eznext/app_constants/loader.dart';
import 'package:eznext/app_constants/logout_popup.dart';
import 'package:eznext/screen%20models/studentexam.dart';
import 'package:eznext/screen%20models/teacherlist.dart';
import 'package:eznext/screen%20models/timeline.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:eznext/api_models/lib_rary.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../logoutmodel.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';

import 'dashboard.dart';
import 'fee.dart';
import 'homework.dart';
import 'mydocuments.dart';
import 'noticeboard.dart';

class ApplyLeave extends StatefulWidget {
  @override
  _ApplyLeaveState createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  //--------defining & initialising parameters------------//
  dynamic commentController = TextEditingController();
  final myKey = new GlobalKey<_ApplyLeaveState>();
  File? myfile;
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
  final DateFormat formatter = DateFormat('ddMMyyyyhhmmss');
  final DateFormat formatter1 = DateFormat('dd-MM-yyyy');
  final DateFormat formatter2 = DateFormat('yyyy/MM/dd');
  bool istimetableloaded = false;
  String hwrkdet = '';
  String? img64;
  File? _image;
  File? imageResized;
  final picker = ImagePicker();
  List<File> imagefiles = [];
  var pdf = pw.Document();
  List<Uint8List> imagesUint8list = [];
  img.Image? fixedImage;

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxHeight: 1080,
        maxWidth: 1080,
        preferredCameraDevice: CameraDevice.rear);
    final bytes = await File(pickedFile.path).readAsBytesSync();
    img64 = base64Encode(bytes);
    if (debug == 'yes') {
      //debugPrint(img64!.substring(0, img64!.length));
    }
    setState(() {
      myfile = null;
      _image = File(pickedFile.path);
      imagefiles.add(_image!);
    });
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

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxHeight: 1080,
        maxWidth: 1080,
        preferredCameraDevice: CameraDevice.rear);
    final bytes = await File(pickedFile.path).readAsBytesSync();
    img64 = base64Encode(bytes);
    //debugPrint(img64!.substring(0, img64!.length));
    setState(() {
      myfile = null;
      _image = File(pickedFile.path);
      imagefiles.add(_image!);
    });
  }

  createPDF() async {
    setState(() {
      pdf = pw.Document();
    });
    for (var img in imagefiles) {
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.FittedBox(child: pw.Image(image));
          }));
    }
    getdirectory();
    setState(() {});
  }

  String filename = '';

  //--------navigation menu bar---------------------//
  void _showPopupMenu() async {
    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(600, 80, 0, 100),
        items: [
          /*        if(initScreen=='screenloaded')
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
  String? fname;
  Future getdirectory() async {
    setState(() {
      fname = formatter.format(DateTime.now());
    });
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      final Directory _appDocDirFolder = Directory('${dir!.path}/$Appname');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        //debugPrint(filePath);
        if (imagefiles.isNotEmpty) {
          try {
            final file = File('${filePath}/${fname}.pdf');
            await file.writeAsBytes(await pdf.save());

            setState(() {
              filename = file.path.toString();
            });
            submitHome(commentController.text, filename, fname!);
          } catch (e) {
            showPrintedMessage('error', e.toString());
          }
        }
      } else {
        final Directory _appDocNewFolder =
            await _appDocDirFolder.create(recursive: true);
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname';
        await Directory(dirPath).create(recursive: true);
        filePath = '$dirPath';
        if (imagefiles.isNotEmpty) {
          try {
            final file = File('${filePath}/${fname}.pdf');
            await file.writeAsBytes(await pdf.save());
            setState(() {
              filename = file.path.toString();
            });
            submitHome(commentController.text, filename, fname!);
          } catch (e) {
            showPrintedMessage('error', e.toString());
          }
        }
      }
    }
  }

  DateTime? _chosenDateTimefrom;
  DateTime? _chosenDateTimeto;

  _showDatePickerfrom(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    setState(() {
      fromdate = formatter2.format(selected!);
    });
  }

  _showDatePickerto(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    setState(() {
      todate = formatter2.format(selected!);
    });
  }

  // Show the modal that contains the CupertinoDatePicker

  String? extension;
  String? selectedfilename;
  Future<void> chhosedoc() async {
    setState(() {
      imagefiles.clear();
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    setState(() {
      fname = 'dochome';
      //debugPrint(fname);
    });
    if (result != null) {
      File file = File(result.files.single.path);
      //debugPrint(file.path);
      setState(() {
        extension = result.files.single.extension.toString();
        selectedfilename = result.files.single.name.toString();
        myfile = file;
      });
    } else {
      // User canceled the picker
      Toast.show('No any file picked', context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          backgroundRadius: 5);
    }
  }

  Future<void> choosehomeworktype(
    BuildContext context,
  ) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                  ),
                  Text(
                    'Upload attatchment',
                    style: GoogleFonts.poppins(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(CupertinoIcons.clear)),
                ],
              ),
            ),
            content: Text(
              'Please choose file type you want to upload',
              style: GoogleFonts.poppins(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    chooseimagemethod(context);
                  },
                  child: Text('Picture')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    chhosedoc();
                  },
                  child: Text('Document'))
            ],
          );
        });
  }

  Future<void> chooseimagemethod(
    BuildContext context,
  ) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                  ),
                  Text(
                    'Upload attatchment',
                    style: GoogleFonts.poppins(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(CupertinoIcons.clear)),
                ],
              ),
            ),
            content: Text(
              'Please choose image from',
              style: GoogleFonts.poppins(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImageFromCamera();
                  },
                  child: Text('Camera')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImageFromGallery();
                  },
                  child: Text('Gallery'))
            ],
          );
        });
  }

  @override
  void initState() {
    setState(() {
      fromdate = formatter2.format(DateTime.now());
      todate = formatter2.format(DateTime.now());
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
    gettLeave();
  }

  var leavelist = [];
  Future gettLeave() async {
    try {
      var rsp = await Stud_fetchleave(stdid, token.toString(), uid);
      //debugPrint(rsp.toString());
      if (rsp['status'] == 401) {
        logOut(context);
        Toast.show(unautherror, context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            backgroundRadius: 5);
      }
      setState(() {
        leavelist = rsp['result_array'];
        initialscreen = 'screenloaded';
      });
      if (rsp == [] || rsp == null) {
        setState(() {
          initialscreen = 'no homework found';
        });
      }
      //debugPrint(initialscreen);
    } catch (error) {
      //debugPrint(error.toString());
      setState(() {
        initialscreen = 'error';
      });
    }
  }

  Future submitHome(String msg, String myfilen, String myfname) async {
    Dialogs.showLoadingDialog(context, myKey, 'Applying leave');
    try {
      var rsp = await Stud_leave(stdid, formatter2.format(DateTime.now()),
          fromdate, todate, msg, token.toString(), File(myfilen), myfname, uid);
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
        if (rsp['status'] == '1') {
          Navigator.of(context).pop();
          if (myfname != 'dochome' && myfname != '') {
            File(filename).delete(recursive: true);
          }
          showPrintedMessage('success', rsp['msg'].toString());
          commentController.clear();
          setState(() {
            fromdate = formatter2.format(DateTime.now());
            todate = formatter2.format(DateTime.now());
            myfile = null;
            imagefiles.clear();
            showapplyscreen = false;
            gettLeave();
          });
        }
      } else {
        Navigator.of(context).pop();
        showPrintedMessage('success', rsp['msg'].toString());
      }
    } catch (error) {
      setState(() {
        Navigator.of(context).pop();
        showPrintedMessage('success', error.toString());
      });
    }
  }

  String fromdate = '';
  String todate = '';
  bool showapplyscreen = false;
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
        appBar: AppBar(
          centerTitle: true,
          leading: Container(),
          backgroundColor: appbarcolor,
          actions: [
            IconButton(
              icon: Icon(
                CupertinoIcons.list_bullet,
                size: 30,
                color: CupertinoColors.white,
              ),
              onPressed: () {
                _showPopupMenu();
              },
            ),
          ],
          elevation: 3,
          title: Text(
            'Apply Leave',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                initialscreen == 'loader'
                    ? Container(
                        height: MediaQuery.of(context).size.height - 221,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.8,
                          ),
                        ))
                    : initialscreen == 'screenloaded'
                        ? Container(
                            height: MediaQuery.of(context).size.height - 221,
                            child: showapplyscreen == true
                                ? ListView.builder(
                                    itemCount: 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                height: 100,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '  ' + 'From',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showDatePickerfrom(
                                                            context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: CupertinoColors
                                                                        .black,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                          child: Center(
                                                            child: Text(
                                                              fromdate,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 100,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '  ' + 'To',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showDatePickerto(
                                                            context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: CupertinoColors
                                                                        .black,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                          child: Center(
                                                            child: Text(
                                                              todate,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            height: 100,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      25, 8, 25, 8),
                                              child: CupertinoTextField(
                                                placeholder: 'Reason',
                                                controller: commentController,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 25,
                                                right: 25,
                                                top: 8,
                                                bottom: 8),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 40,
                                              color: Colors.red,
                                              child: RaisedButton(
                                                color: Colors.transparent,
                                                elevation: 0,
                                                onPressed: () {
                                                  choosehomeworktype(context);
                                                },
                                                child: Text(
                                                  'UPLOAD FILE',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: CupertinoColors
                                                          .white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 25,
                                                right: 25,
                                                top: 8,
                                                bottom: 8),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 40,
                                              color: Colors.green,
                                              child: RaisedButton(
                                                color: Colors.transparent,
                                                elevation: 0,
                                                onPressed: () {
                                                  if (todate != '' &&
                                                      fromdate != '') {
                                                    if (myfile != null ||
                                                        imagefiles.isNotEmpty) {
                                                      if (myfile != null) {
                                                        submitHome(
                                                            commentController
                                                                .text,
                                                            myfile!.path,
                                                            fname!);
                                                      }
                                                      if (imagefiles
                                                          .isNotEmpty) {
                                                        createPDF();
                                                      }
                                                    } else {
                                                      //debugPrint('here');
                                                      submitHome(
                                                          commentController
                                                              .text,
                                                          '',
                                                          '');
                                                    }
                                                  } else {
                                                    showPrintedMessage('error',
                                                        'Please select date');
                                                  }
                                                },
                                                child: Text(
                                                  'SUBMIT',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: CupertinoColors
                                                          .white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (myfile != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  OpenFile.open(myfile!.path);
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: 200,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    CupertinoColors
                                                                        .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            if (extension ==
                                                                'pdf')
                                                              Icon(
                                                                Icons
                                                                    .picture_as_pdf,
                                                                color: CupertinoColors
                                                                    .systemRed,
                                                              ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              selectedfilename!
                                                                  .toString(),
                                                              style: GoogleFonts.poppins(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ),
                                          if (myfile != null)
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    myfile = null;
                                                  });
                                                },
                                                icon: Icon(
                                                  CupertinoIcons.delete,
                                                  color:
                                                      CupertinoColors.systemRed,
                                                )),
                                          if (imagefiles.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 150,
                                                child: GridView.count(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 2.0,
                                                    mainAxisSpacing: 2.0,
                                                    shrinkWrap: false,
                                                    children: List.generate(
                                                        imagefiles.length,
                                                        (index) {
                                                      return Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              new DecorationImage(
                                                            image: FileImage(
                                                                imagefiles[
                                                                    index]),
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  imagefiles
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              icon: Icon(
                                                                CupertinoIcons
                                                                    .delete,
                                                                color:
                                                                    CupertinoColors
                                                                        .white,
                                                                size: 30,
                                                              )),
                                                        ),
                                                      );
                                                    })),
                                              ),
                                            ),
                                        ],
                                      );
                                    })
                                : ListView.builder(
                                    itemCount: leavelist.length,
                                    itemBuilder: (BuildContext context, index) {
                                      return Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color:
                                                  CupertinoColors.systemGrey5,
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        ' ' + 'Apply Date : ',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      if (leavelist[index]
                                                              ['apply_date'] !=
                                                          '0000-00-00')
                                                        Text(
                                                          ' ' +
                                                              formatter1.format(
                                                                  DateTime.parse(
                                                                      leavelist[index]
                                                                              [
                                                                              'from_date']
                                                                          .toString())),
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              color:
                                                                  CupertinoColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 70,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        ' ' + 'From Date : ',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      if (leavelist[index]
                                                              ['from_date'] !=
                                                          '0000-00-00')
                                                        Text(
                                                          ' ' +
                                                              formatter1.format(
                                                                  DateTime.parse(
                                                                      leavelist[index]
                                                                              [
                                                                              'from_date']
                                                                          .toString())),
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              color:
                                                                  CupertinoColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        ' ' + 'To Date : ',
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      if (leavelist[index]
                                                              ['to_date'] !=
                                                          '0000-00-00')
                                                        Text(
                                                          ' ' +
                                                              formatter1.format(
                                                                  DateTime.parse(
                                                                      leavelist[index]
                                                                              [
                                                                              'to_date']
                                                                          .toString())) +
                                                              ' ',
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              color:
                                                                  CupertinoColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                    ],
                                                  ),
                                                  if (leavelist[index]['status']
                                                          .toString() ==
                                                      '0')
                                                    Container(
                                                      height: 30,
                                                      width: 70,
                                                      color: CupertinoColors
                                                          .destructiveRed,
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'Pending',
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                color:
                                                                    CupertinoColors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (leavelist[index]['status']
                                                          .toString() ==
                                                      '1')
                                                    Container(
                                                      height: 30,
                                                      width: 70,
                                                      color: CupertinoColors
                                                          .activeGreen,
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'Approved',
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                color:
                                                                    CupertinoColors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                          )
                        : initialscreen == 'error'
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height - 161,
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
                                    MediaQuery.of(context).size.height - 161,
                                child: Center(
                                  child: Text(
                                    'No leaves taken',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        decoration: TextDecoration.none,
                                        color: CupertinoColors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )),
                if (showapplyscreen == false)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              showapplyscreen = true;
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showapplyscreen == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              showapplyscreen = false;
                            });
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )),
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
                    //  Icon(CupertinoIcons.home,color: botoomiconunselectedcolor,),
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
                              builder: (BuildContext context) => StudenExam()));
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
      ),
    );
  }
}
