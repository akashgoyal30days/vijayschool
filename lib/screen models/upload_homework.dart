// Home Tab
import 'dart:convert';
import 'dart:io';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eznext/api_models/student_homework.dart';
import 'package:eznext/app_constants/loader.dart';
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
import 'homework.dart';

class UploadHomework extends StatefulWidget {
  final String hid;
  const UploadHomework({required this.hid});

  @override
  _UploadHomeworkState createState() => _UploadHomeworkState();
}

class _UploadHomeworkState extends State<UploadHomework> {
  //--------defining & initialising parameters------------//
  dynamic commentController = TextEditingController();
  final myKey = new GlobalKey<_UploadHomeworkState>();
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
      final Directory _appDocDirFolder =
          Directory('${dir!.path}/$Appname/upload homework');
      if (await _appDocDirFolder.exists()) {
        //debugPrint('exists');
        appDocDir = await _getDownloadDirectory();
        final String dirPath = '${appDocDir!.path}/$Appname/upload homework';
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
        final String dirPath = '${appDocDir!.path}/$Appname/upload homework';
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

  String? extension;
  String? selectedfilename;

  Future<void> chhosedoc() async {
    setState(() {
      imagefiles.clear();
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'xlsx', 'xls'],
    );
    setState(() {
      fname = 'dochome';
      //debugPrint(fname);
    });
    if (result != null) {
      File file = File(result.files.single.path);
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
                    'Upload Homework',
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
                    'Upload Homework',
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
  }

  bool ishomeworkuploading = false;

  Future submitHome(String msg, String myfilen, String myfname) async {
    showPrintedMessage('Processing', 'Uploading Homework');
    try {
      var rsp = await Stud_upld_hwrk(stdid, widget.hid, msg, token.toString(),
          File(myfilen), myfname, uid);
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
          setState(() {
            ishomeworkuploading = false;
          });
          if (myfname != 'dochome') {
            File(filename).delete(recursive: true);
          }
          showPrintedMessage('success', rsp['msg'].toString());
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => Homework()));
        } else {
          showPrintedMessage('failed', rsp['error']['message'].toString());
        }
        setState(() {
          ishomeworkuploading = false;
        });
      } else {
        setState(() {
          ishomeworkuploading = false;
        });
      }
    } catch (error) {
      setState(() {
        ishomeworkuploading = false;
        showPrintedMessage('success', error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (BuildContext context) => Homework()));
        return false;
      },
      child: CupertinoPageScaffold(
          backgroundColor: themecolor,
          child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: appbarcolor,
                leading: IconButton(
                  icon: Icon(
                    CupertinoIcons.back,
                    color: ishomeworkuploading == false
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                  onPressed: () {
                    if (ishomeworkuploading == false) {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (BuildContext context) => Homework()));
                    }
                  },
                ),
                elevation: 3,
                title: Text(
                  'Upload Homework',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.height,
                child: ishomeworkuploading == true
                    ? Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 0.8,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                                child: Text(
                                    "Homework uploading in process, please don't change screen")),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                                child: Text(
                                    "Screen will be automatically change ")),
                            Center(child: Text("on successful upload"))
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: Text(
                            'Upload your assignments here',
                            style: GoogleFonts.poppins(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (ishomeworkuploading == false) {
                                    choosehomeworktype(context);
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.arrow_up_circle,
                                  size: 150,
                                  color: ishomeworkuploading == false
                                      ? CupertinoColors.systemBlue
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                          if (myfile != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (ishomeworkuploading == false) {
                                    OpenFile.open(myfile!.path);
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 200,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: CupertinoColors.black),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            if (extension == 'pdf')
                                              Icon(
                                                Icons.picture_as_pdf,
                                                color:
                                                    CupertinoColors.systemRed,
                                              ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              selectedfilename!.toString(),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
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
                                  if (ishomeworkuploading == false) {
                                    setState(() {
                                      myfile = null;
                                    });
                                  }
                                },
                                icon: Icon(
                                  CupertinoIcons.delete,
                                  color: ishomeworkuploading == false
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.systemGrey,
                                )),
                          if (imagefiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 150,
                                child: GridView.count(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 2.0,
                                    mainAxisSpacing: 2.0,
                                    shrinkWrap: false,
                                    children: List.generate(imagefiles.length,
                                        (index) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          image: new DecorationImage(
                                            image: FileImage(imagefiles[index]),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        child: Center(
                                          child: IconButton(
                                              onPressed: () {
                                                if (ishomeworkuploading ==
                                                    false) {
                                                  setState(() {
                                                    imagefiles.removeAt(index);
                                                  });
                                                }
                                              },
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                                color:
                                                    ishomeworkuploading == false
                                                        ? CupertinoColors.white
                                                        : CupertinoColors
                                                            .systemGrey,
                                                size: 30,
                                              )),
                                        ),
                                      );
                                    })),
                              ),
                            ),
                          Container(
                            height: 100,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                              child: CupertinoTextField(
                                placeholder: 'Reason',
                                controller: commentController,
                              ),
                            ),
                          ),
                          RaisedButton(
                            color: ishomeworkuploading == false
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemGrey,
                            onPressed: () {
                              if (ishomeworkuploading == false) {
                                if (myfile != null || imagefiles.isNotEmpty) {
                                  setState(() {
                                    ishomeworkuploading = true;
                                  });
                                  if (myfile != null) {
                                    submitHome(commentController.text,
                                        myfile!.path, fname!);
                                  }
                                  if (imagefiles.isNotEmpty) {
                                    createPDF();
                                  }
                                } else {
                                  showPrintedMessage('error',
                                      'Please select any homework to continue');
                                }
                              } else {
                                showPrintedMessage(
                                    'error', 'Please enter a message');
                              }
                            },
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              ))),
    );
  }
}
