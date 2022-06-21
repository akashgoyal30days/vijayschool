import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:eznext/api_models/submit_exam.dart';
import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/app_constants/leavexam.dart';
import 'package:eznext/app_constants/loader.dart';
import 'package:eznext/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:volume_control/volume_control.dart';
import 'package:wakelock/wakelock.dart';
import '../logoutmodel.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'online_exam.dart';
import 'package:just_audio/just_audio.dart' as ja;

class ExamScreen extends StatefulWidget {
  final String ename;
  final List quest;
  final int second;
  final String esid;
  const ExamScreen(
      {required this.ename,
      required this.quest,
      required this.second,
      required this.esid});
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  //--------defining & initialising parameters------------//
  int initialsec = 1;
  Timer? timer;
  int finaltimer = 0;
  void addtimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        initialsec = initialsec + 1;
        finaltimer = initialsec;
      });
    });
  }

  StreamSubscription<FGBGType>? subscription;
  final myKey = new GlobalKey<_ExamScreenState>();
  final myKey2 = new GlobalKey<_ExamScreenState>();
  bool val1 = false;
  bool val2 = false;
  bool val3 = false;
  bool val4 = false;
  bool val5 = false;
  var questionlist = [];
  var isplaying = [];
  String applogo = '';
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
  List rows = [];
  var studentids = [];
  var questids = [];
  //---list for checkbox entry----//
  var chckboxvallist = [];
  int scrn = 0;
  PageController? controller;
  bool errorstate = false;

  bool isexamsubmitting = false;

  //---list for answer entry-----//
  var answers = [];

  void changescreen(int scr) {
    setState(() {
      //debugPrint(scr.toString());
      controller = PageController(initialPage: scr);
    });
  }

  Future<void> showPopDialoguge(BuildContext context) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Container(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('All Questions'),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: CupertinoColors.systemRed,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Unattempted Questions',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: CupertinoColors.activeGreen,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Attempted Questions',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ],
                )),
            content: Container(
              height: MediaQuery.of(context).size.height / 2,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 1.5,
                shrinkWrap: false,
                children: List.generate(
                  answers.length,
                  (index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        controller!.jumpToPage(index);
                      },
                      child: Card(
                        color: answers[index] == ''
                            ? CupertinoColors.systemRed
                            : CupertinoColors.activeGreen,
                        child: Center(
                          child: Text(
                            'Q' + (index + 1).toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'))
            ],
          );
        });
  }

  //--Retry submission---//
  Future<void> Retry(
    BuildContext context,
  ) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Retry'),
            content: Text('Please retry submitting your answers'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    subExam();
                  },
                  child: Text('ok'))
            ],
          );
        });
  }

  Future<void> Retryback(
    BuildContext context,
  ) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Retry'),
            content: Text('Please retry submitting your answers'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    subExamOnback();
                  },
                  child: Text('ok'))
            ],
          );
        });
  }

//---exam over---//
  Future<void> showExamOver(
    BuildContext context,
  ) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Exam Over!!'),
            content: Text(
                'Your exam is over and the answer will be submitted automatically'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    disp();
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (BuildContext context) => OnlineExam(
                                  state: false,
                                )));
                  },
                  child: Text('ok'))
            ],
          );
        });
  }

  bool iscall = false;

  dynamic answerController = TextEditingController();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  bool istimetableloaded = false;
  String hwrkdet = '';
  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  String scrss = 'show';
  bool shouldneglectback = false;
  @override
  void initState() {
    Wakelock.enable();
    if (iscallpickingallowed == false) {
      initVolumeState();
      _player.stop();
      _player.play();
      AudioSession.instance.then((audioSession) async {
        await audioSession.configure(AudioSessionConfiguration.music());
        // Listen to audio interruptions and pause or duck as appropriate.
        _handleInterruptions(audioSession);
        // Use another plugin to load audio to play.
      });
      AudioSession.instance.then((audioSession) async {
        // This line configures the app's audio session, indicating to the OS the
        // type of audio we intend to play. Using the "speech" recipe rather than
        // "music" since we are playing a podcast.
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.ambient,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.voicePrompt,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.audibilityEnforced,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ));

        // Listen to audio interruptions and pause or duck as appropriate.
        _handleInterruptions(audioSession);
        // Use another plugin to load audio to play.
      });
    }
    if (istabswitchingallowed == false) {
      subscription = FGBGEvents.stream.listen((event) {
        //debugPrint(event.toString());
        if (event == FGBGType.background) {
          if (shouldneglectback == false) {
            subExamScreenchange1();
          }
        } // FGBGType.foreground or FGBGType.background
      });
    }
    addtimer();
    setState(() {
      controller = PageController(initialPage: scrn);
    });
    gettingSavedData();
    super.initState();
  }

  double _val = 0.5;
  Future<void> initVolumeState() async {
    if (!mounted) return;

    //read the current volume
    _val = await VolumeControl.setVolume(0.0);
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    subscription!.cancel();
    disp();
  }

  void disp() async {
/*    _player =ja.AudioPlayer(
      // Handle audio_session events ourselves for the purpose of this demo.
      handleInterruptions: false,
      androidApplyAudioAttributes: false,
      handleAudioSessionActivation: false,
    );*/
    if (iscallpickingallowed == false) {
      _player.stop();
      await _player.dispose();
    }
  }

  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  late var _player = ja.AudioPlayer(
    // Handle audio_session events ourselves for the purpose of this demo.
    handleInterruptions: true,
    androidApplyAudioAttributes: true,
    handleAudioSessionActivation: true,
  );
  void _handleInterruptions(AudioSession audioSession) {
    // just_audio can handle interruptions for us, but we have disabled that in
    // order to demonstrate manual configuration.
    bool playInterrupted = false;
    audioSession.becomingNoisyEventStream.listen((_) {
      //debugPrint('PAUSE');
      _player.pause();
    });
    _player.playingStream.listen((playing) {
      playInterrupted = false;
      if (playing) {
        audioSession.setActive(true);
      }
    });
    audioSession.interruptionEventStream.listen((event) {
      // //debugPrint('interruption begin: ${event.begin}');
      //  //debugPrint('interruption type: ${event.type}');
      if (event.begin) {
        //debugPrint('here');
        if (os == 'ios') {
          setState(() {
            isinterupted = true;
            iscall = true;
          });
        }

        if (event.type == AudioInterruptionType.unknown) {
          if (os == 'ios') {
            setState(() {
              isinterupted = true;
              // iscall = true;
              shouldneglectback = true;
            });
          }
          if (os != 'ios') {
            _player.stop();
            _player.play();
            AudioSession.instance.then((audioSession) async {
              await audioSession.configure(AudioSessionConfiguration.music());
              // Listen to audio interruptions and pause or duck as appropriate.
              _handleInterruptions(audioSession);
              // Use another plugin to load audio to play.
            });
            AudioSession.instance.then((audioSession) async {
              // This line configures the app's audio session, indicating to the OS the
              // type of audio we intend to play. Using the "speech" recipe rather than
              // "music" since we are playing a podcast.
              final session = await AudioSession.instance;
              await session.configure(AudioSessionConfiguration(
                avAudioSessionCategory: AVAudioSessionCategory.ambient,
                avAudioSessionCategoryOptions:
                    AVAudioSessionCategoryOptions.duckOthers,
                avAudioSessionMode: AVAudioSessionMode.voicePrompt,
                avAudioSessionRouteSharingPolicy:
                    AVAudioSessionRouteSharingPolicy.defaultPolicy,
                avAudioSessionSetActiveOptions:
                    AVAudioSessionSetActiveOptions.none,
                androidAudioAttributes: const AndroidAudioAttributes(
                  contentType: AndroidAudioContentType.speech,
                  flags: AndroidAudioFlags.audibilityEnforced,
                  usage: AndroidAudioUsage.media,
                ),
                androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
                androidWillPauseWhenDucked: true,
              ));

              // Listen to audio interruptions and pause or duck as appropriate.
              _handleInterruptions(audioSession);
              // Use another plugin to load audio to play.
            });
          }
        } else {
          if (os != 'ios') {
            setState(() {
              isinterupted = true;
              // iscall = true;
              shouldneglectback = true;
            });
          }
        }
      } else {
        //debugPrint('end');
        setState(() {
          isinterupted = false;
          // iscall = false;
          Future.delayed(const Duration(seconds: 60), () {
            setState(() {
              shouldneglectback = false;
            });
          });
        });
      }
    });
  }

  //to extarct url
  RegExp extacturl =
      RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
  String? extr(String text) {
    debugPrint(text.toString());

    String? finalurl;
    setState(() {
      finalurl = text;
      var a = finalurl!.split("src=");
      debugPrint(a.toString());
      debugPrint(a.length.toString());
      finalurl = a[1].toString();
      finalurl = finalurl!.replaceAll('"', "");
      /*  finalurl = text.replaceAll('''<div class="ckeditor-html5-audio" style="text-align: center;">''',"");
        finalurl = text.replaceAll('''<div class="ckeditor-html5-audio" style="text-align: left; float: left; margin-right: 10px;">''',"");
        finalurl = finalurl!.replaceAll('''<audio controls="controls" controlslist="nodownload" src="''',"");
        finalurl = finalurl!.replaceAll('''">&nbsp;</audio>''',"");
        finalurl = finalurl!.replaceAll('''</div>''',"");
        finalurl = finalurl!.replaceAll('''<p>&nbsp;</p>''',"");*/
      finalurl = finalurl!.replaceAll('''>&nbsp;</audio>''', "");
      finalurl = finalurl!.replaceAll('''</div>''', "");
      finalurl = finalurl!.replaceAll('''<p>&nbsp;</p>''', "");

      finalurl = finalurl!.trim();

      debugPrint(finalurl.toString());
    });
    return finalurl;
  }

  void gettingSavedData() async {
    //-------initialising sharedpreference-----------//
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    SharedPreferences studentdetails = await SharedPreferences.getInstance();

    //-------setting values-----------------------//
    setState(() {
      applogo = initialschoolcode.getString('app_logo');
      token = studentdetails.getString('token');
      student_name = studentdetails.getString('username');
      class_name = studentdetails.getString('class');
      section_name = studentdetails.getString('section');
      School_name = studentdetails.getString('sch_name');
      student_image = studentdetails.getString('image');
      siteurl = initialschoolcode.getString('site_url');
      stdid = studentdetails.getString('student_id');
      uid = studentdetails.getString('id');
      questionlist = widget.quest;
      for (var i = 0; i < questionlist.length; i++) {
        setState(() {
          chckboxvallist.add([false, false, false, false, false]);
          answers.add('');
          studentids.add(widget.esid);
          isplaying.add(false);
          questids.add('');
        });
      }
    });
    debugPrint(questionlist.toString());
    //debugPrint(chckboxvallist.toString());
    //debugPrint(answers.toString());
  }

  var result;
  List qid = [];
  List ansid = [];
  var map = {};

  Future<void> showConfDial(BuildContext context) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Confirm Submission'),
            content: Text('Are you confirm you want to submit?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    subExam();
                  },
                  child: Text('Yes')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Recheck'))
            ],
          );
        });
  }

  Future subExam() async {
    setState(() {
      isexamsubmitting = true;
    });
    map.clear();
    rows.clear();
    for (var i = 0; i < questionlist.length; i++) {
      setState(() {
        var a = {
          'onlineexam_student_id': studentids[i].toString(),
          'onlineexam_question_id': questids[i].toString(),
          'select_option': answers[i].toString()
        };
        if (answers[i] != '') rows.add(a);
      });
    }

    //debugPrint('rows'+' '+rows.toString());
    if (rows.isNotEmpty) {
      try {
        var rsp = await Sub_exam(widget.esid, token.toString(), uid, rows);
        //debugPrint(rsp.toString());
        if (rsp.containsKey('status')) {
          setState(() {
            isexamsubmitting = false;
          });
          if (rsp['status'] == 401) {
            logOut(context);
            //Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(unautherror),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
          }
          if (rsp['status'] == 1) {
            //Toast.show('Answers submitted successfully', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            showSimpleNotification(Text('Success'),
                context: context,
                subtitle: Text('Answers submitted successfully'),
                background: Colors.green,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            disp();
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => OnlineExam(
                          state: false,
                        )));
          }
          if (rsp['status'] == 2) {
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(rsp['msg'].toString()),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            // Toast.show(rsp['msg'].toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);

          }
        } else {
          setState(() {
            isexamsubmitting = false;
          });
          showSimpleNotification(Text('Oops'),
              context: context,
              subtitle: Text('Server unreachable please try again'),
              background: Colors.redAccent,
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              elevation: 0,
              autoDismiss: true,
              position: NotificationPosition.bottom);
        }
      } catch (error) {
        //debugPrint(error.toString());
        setState(() {
          isexamsubmitting = false;
        });
        showSimpleNotification(Text('Oops'),
            context: context,
            subtitle: Text('Failed to submit answers'),
            background: Colors.redAccent,
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            elevation: 0,
            autoDismiss: true,
            position: NotificationPosition.bottom);
        // Toast.show('Failed to submit answers', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        Retry(context);
      }
    } else {
      // Lexam.showPopDialoguge(context, myKey, 'Need to mark any question to submit the exam', 'Error!');
      showSimpleNotification(Text('Oops'),
          context: context,
          subtitle: Text('Need to mark at least one answer to submit'),
          background: Colors.redAccent,
          leading: Icon(
            Icons.info,
            color: Colors.white,
          ),
          elevation: 0,
          autoDismiss: true,
          position: NotificationPosition.bottom);
      setState(() {
        isexamsubmitting = false;
      });
    }
  }

  Future subExamOnback() async {
    setState(() {
      isexamsubmitting = true;
    });
    map.clear();
    rows.clear();
    for (var i = 0; i < questionlist.length; i++) {
      setState(() {
        var a = {
          'onlineexam_student_id': studentids[i].toString(),
          'onlineexam_question_id': questids[i].toString(),
          'select_option': answers[i].toString()
        };
        if (answers[i] != '') rows.add(a);
      });
    }

    //debugPrint('rows'+' '+rows.toString());
    if (rows.isNotEmpty) {
      try {
        var rsp = await Sub_exam(widget.esid, token.toString(), uid, rows);
        //debugPrint(rsp.toString());
        if (rsp.containsKey('status')) {
          setState(() {
            isexamsubmitting = false;
          });
          if (rsp['status'] == 401) {
            logOut(context);
            //Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(unautherror),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
          }
          if (rsp['status'] == 1) {
            //Toast.show('Answers submitted successfully', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            showSimpleNotification(Text('Success'),
                context: context,
                subtitle: Text('Answers submitted successfully'),
                background: Colors.green,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            SystemNavigator.pop();
          }
          if (rsp['status'] == 2) {
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(rsp['msg'].toString()),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            // Toast.show(rsp['msg'].toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            Retryback(context);
          }
        } else {
          setState(() {
            isexamsubmitting = false;
          });
          showSimpleNotification(Text('Oops'),
              context: context,
              subtitle: Text('Server unreachable please try again'),
              background: Colors.redAccent,
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              elevation: 0,
              autoDismiss: true,
              position: NotificationPosition.bottom);
        }
      } catch (error) {
        setState(() {
          isexamsubmitting = false;
        });
        //debugPrint(error.toString());
        showSimpleNotification(Text('Oops'),
            context: context,
            subtitle: Text('Failed to submit answers'),
            background: Colors.redAccent,
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            elevation: 0,
            autoDismiss: true,
            position: NotificationPosition.bottom);
        // Toast.show('Failed to submit answers', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        Retryback(context);
      }
    } else {
      setState(() {
        isexamsubmitting = false;
      });
      SystemNavigator.pop();
    }
  }

  Future subExamtimeover() async {
    setState(() {
      isexamsubmitting = true;
    });
    map.clear();
    rows.clear();
    for (var i = 0; i < questionlist.length; i++) {
      setState(() {
        var a = {
          'onlineexam_student_id': studentids[i].toString(),
          'onlineexam_question_id': questids[i].toString(),
          'select_option': answers[i].toString()
        };
        if (answers[i] != '') rows.add(a);
      });
    }

    //debugPrint('rows'+' '+rows.toString());
    if (rows.isNotEmpty) {
      //Dialogs.showLoadingDialog(context,myKey,'Exam time over submitting answers');
      showSimpleNotification(Text('Exam over'),
          context: context,
          subtitle: Text('Exam time over submitting answers'),
          background: Colors.redAccent,
          leading: Icon(
            Icons.info,
            color: Colors.white,
          ),
          elevation: 0,
          autoDismiss: true,
          position: NotificationPosition.bottom);
      try {
        var rsp = await Sub_exam(widget.esid, token.toString(), uid, rows);
        //debugPrint(rsp.toString());
        if (rsp.containsKey('status')) {
          setState(() {
            isexamsubmitting = false;
          });
          if (rsp['status'] == 401) {
            logOut(context);
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(unautherror),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            //Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
          }
          if (rsp['status'] == 1) {
            //Toast.show('Answers submitted successfully', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            showSimpleNotification(Text('Success'),
                context: context,
                subtitle: Text('Answers submitted successfully'),
                background: Colors.green,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            // Navigator.of(context).pop();
            if (isbackclicked == true) {
              OverlaySupportEntry.of(context)!.dismiss();
            }
            disp();
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => OnlineExam(
                          state: false,
                        )));
          }
          if (rsp['status'] == 2) {
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(rsp['msg'].toString()),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            //Toast.show(rsp['msg'].toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            // Navigator.of(context).pop();

          }
        } else {
          setState(() {
            isexamsubmitting = false;
          });
          showSimpleNotification(Text('Oops'),
              context: context,
              subtitle: Text('Server unreachable please try again'),
              background: Colors.redAccent,
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              elevation: 0,
              autoDismiss: true,
              position: NotificationPosition.bottom);
        }
      } catch (error) {
        //debugPrint(error.toString());
        setState(() {
          isexamsubmitting = false;
        });
        //Navigator.of(context).pop();
        showSimpleNotification(Text('Oops'),
            context: context,
            subtitle: Text('Failed to submit answers'),
            background: Colors.redAccent,
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            elevation: 0,
            autoDismiss: true,
            position: NotificationPosition.bottom);
        // Toast.show('Failed to submit answers', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        Retry(context);
      }
    } else {
      setState(() {
        isexamsubmitting = false;
      });
      // Dialogs.showLoadingDialog(context,myKey,'Since you have not marked any question you will be marked absent');
      showSimpleNotification(Text('Oops'),
          context: context,
          subtitle: Text(
              'Since you have not marked any question you will be marked absent'),
          background: Colors.redAccent,
          leading: Icon(
            Icons.info,
            color: Colors.white,
          ),
          elevation: 0,
          autoDismiss: true,
          position: NotificationPosition.bottom);
      disp();
      Future.delayed(const Duration(seconds: 0), () {
        //  Navigator.of(context).pop();
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => OnlineExam(
                      state: false,
                    )));
      });
    }
  }

  Future subExamScreenchange1() async {
    setState(() {
      isexamsubmitting = true;
    });
    map.clear();
    rows.clear();
    for (var i = 0; i < questionlist.length; i++) {
      setState(() {
        var a = {
          'onlineexam_student_id': studentids[i].toString(),
          'onlineexam_question_id': questids[i].toString(),
          'select_option': answers[i].toString()
        };
        if (answers[i] != '') rows.add(a);
      });
    }

    //debugPrint('rows'+' '+rows.toString());
    if (rows.isNotEmpty) {
      // Dialogs.showLoadingDialog(context,myKey,'Exam over due to inactive $Appname, submitting answers');
      showSimpleNotification(Text('Oops'),
          context: context,
          subtitle:
              Text('Exam over due to inactive $Appname, submitting answers'),
          background: Colors.redAccent,
          leading: Icon(
            Icons.info,
            color: Colors.white,
          ),
          elevation: 0,
          autoDismiss: true,
          position: NotificationPosition.bottom);
      try {
        var rsp = await Sub_exam(widget.esid, token.toString(), uid, rows);
        //debugPrint(rsp.toString());
        if (rsp.containsKey('status')) {
          setState(() {
            isexamsubmitting = false;
          });
          if (rsp['status'] == 401) {
            logOut(context);
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(unautherror),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            //Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
          }
          if (rsp['status'] == 1) {
            showSimpleNotification(Text('Success'),
                context: context,
                subtitle: Text('Answers submitted successfully'),
                background: Colors.green,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            // Toast.show('Answers submitted successfully', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            // Navigator.of(context).pop();
            disp();
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => OnlineExam(
                          state: true,
                        )));
          }
          if (rsp['status'] == 2) {
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(rsp['msg'].toString()),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            //Toast.show(rsp['msg'].toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            //   Navigator.of(context).pop();

          }
        } else {
          setState(() {
            isexamsubmitting = false;
          });
          showSimpleNotification(Text('Oops'),
              context: context,
              subtitle: Text('Server unreachable please try again'),
              background: Colors.redAccent,
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              elevation: 0,
              autoDismiss: true,
              position: NotificationPosition.bottom);
        }
      } catch (error) {
        //debugPrint(error.toString());
        setState(() {
          isexamsubmitting = false;
        });
        // Navigator.of(context).pop();
        showSimpleNotification(Text('Oops'),
            context: context,
            subtitle: Text('Failed to submit answers'),
            background: Colors.redAccent,
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            elevation: 0,
            autoDismiss: true,
            position: NotificationPosition.bottom);
        //Toast.show('Failed to submit answers', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        subExamScreenchange2();
      }
    } else {
      setState(() {
        isexamsubmitting = false;
      });
      disp();
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => OnlineExam(
                    state: true,
                  )));
    }
  }

  Future subExamScreenchange2() async {
    setState(() {
      isexamsubmitting = true;
    });
    map.clear();
    rows.clear();
    for (var i = 0; i < questionlist.length; i++) {
      setState(() {
        var a = {
          'onlineexam_student_id': studentids[i].toString(),
          'onlineexam_question_id': questids[i].toString(),
          'select_option': answers[i].toString()
        };
        if (answers[i] != '') rows.add(a);
      });
    }

    //debugPrint('rows'+' '+rows.toString());
    if (rows.isNotEmpty) {
      // Dialogs.showLoadingDialog(context,myKey,'Exam over due to inactive $Appname, retrying submitting answers');
      showSimpleNotification(Text('Oops'),
          context: context,
          subtitle: Text(
              'Exam over due to inactive $Appname, submitting answers, retrying submitting answers'),
          background: Colors.redAccent,
          leading: Icon(
            Icons.info,
            color: Colors.white,
          ),
          elevation: 0,
          autoDismiss: true,
          position: NotificationPosition.bottom);
      try {
        var rsp = await Sub_exam(widget.esid, token.toString(), uid, rows);
        //debugPrint(rsp.toString());
        if (rsp.containsKey('status')) {
          setState(() {
            isexamsubmitting = false;
          });
          if (rsp['status'] == 401) {
            logOut(context);
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(unautherror),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            //Toast.show(unautherror, context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
          }
          if (rsp['status'] == 1) {
            showSimpleNotification(Text('Success'),
                context: context,
                subtitle: Text('Answers submitted successfully'),
                background: Colors.green,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            // Toast.show('Answers submitted successfully', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            //  Navigator.of(context).pop();
            disp();
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => OnlineExam(
                          state: true,
                        )));
          }
          if (rsp['status'] == 2) {
            showSimpleNotification(Text('Oops'),
                context: context,
                subtitle: Text(rsp['msg'].toString()),
                background: Colors.redAccent,
                leading: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                elevation: 0,
                autoDismiss: true,
                position: NotificationPosition.bottom);
            // Toast.show(rsp['msg'].toString(), context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
            //  Navigator.of(context).pop();

          }
        } else {
          setState(() {
            isexamsubmitting = false;
          });
          showSimpleNotification(Text('Oops'),
              context: context,
              subtitle: Text('Server unreachable please try again'),
              background: Colors.redAccent,
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              elevation: 0,
              autoDismiss: true,
              position: NotificationPosition.bottom);
        }
      } catch (error) {
        setState(() {
          isexamsubmitting = false;
        });
        //debugPrint(error.toString());
        // Navigator.of(context).pop();
        showSimpleNotification(Text('Oops'),
            context: context,
            subtitle: Text('Failed to submit answers'),
            background: Colors.redAccent,
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            elevation: 0,
            autoDismiss: true,
            position: NotificationPosition.bottom);
        // Toast.show('Failed to submit answers', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM, backgroundColor: Colors.white, textColor: Colors.black, backgroundRadius: 5);
        disp();
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => OnlineExam(
                      state: true,
                    )));
      }
    } else {
      setState(() {
        isexamsubmitting = false;
      });
      disp();
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => OnlineExam(
                    state: true,
                  )));
    }
  }

  bool isbackclicked = false;
  int foralert = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isbackclicked == false) {
          setState(() {
            foralert = widget.second - finaltimer;
          });
          showSimpleNotification(
            Padding(
              padding: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).size.height / 2.5, 0, 0),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Alert !!',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                      Builder(builder: (BuildContext context) {
                        return CountdownFormatted(
                          duration: Duration(seconds: foralert),
                          onFinish: () {
                            OverlaySupportEntry.of(context)!.dismiss();
                            subExamtimeover();
                          },
                          builder: (BuildContext ctx, String remaining) {
                            return Text(remaining);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            autoDismiss: false,
            contentPadding: EdgeInsets.fromLTRB(
                10, 0, 10, MediaQuery.of(context).size.height - 550),
            elevation: 0,
            subtitle: Container(
              color: Colors.white,
              child: Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          'This action will submit your exam',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'Do you want to exit from the app ?',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Builder(builder: (BuildContext context) {
                            return Container(
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                )),
                                onPressed: () async {
                                  OverlaySupportEntry.of(context)!.dismiss();
                                  setState(() {
                                    isbackclicked = false;
                                  });
                                  subExamOnback();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Yes',
                                      style: GoogleFonts.roboto(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Builder(builder: (BuildContext context) {
                            return Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                  color: Colors.red,
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                )),
                                onPressed: () async {
                                  OverlaySupportEntry.of(context)!.dismiss();
                                  setState(() {
                                    isbackclicked = false;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No',
                                      style: GoogleFonts.roboto(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  )),
            ),
            background: Colors.white.withOpacity(0.7),
            position: NotificationPosition.top,
          );
        }
        setState(() {
          isbackclicked = true;
        });
        return false;
      },
      child: CupertinoPageScaffold(
          backgroundColor: themecolor,
          child: isexamsubmitting == false
              ? Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    leading: Container(),
                    toolbarHeight: _keyboardIsVisible() ? 0 : 205,
                    elevation: 0,
                    backgroundColor:
                        CupertinoColors.systemBlue.withOpacity(0.9),
                    flexibleSpace: _keyboardIsVisible()
                        ? Container()
                        : Container(
                            height: 205,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                if (schoolcode == '' && siteurl != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 8, 8),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Image.network(
                                        siteurl + applogointrimpath + applogo,
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                if (schoolcode != '')
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 8, 8),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/schoollogo.jpeg',
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: 5,
                                ),
                                Center(
                                  child: Text(
                                    widget.ename.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.white),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Note: If you change your system/mobile screen or click on back button, your exam will be submitted automatically.'
                                      .toUpperCase(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.white),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                  ),
                  body: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            color: CupertinoColors.activeGreen,
                            child: Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  color: CupertinoColors.systemGrey5,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.clock,
                                          size: 19,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        CountdownFormatted(
                                          duration:
                                              Duration(seconds: widget.second),
                                          onFinish: () {
                                            subExamtimeover();
                                          },
                                          builder: (BuildContext ctx,
                                              String remaining) {
                                            return Text(remaining);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (iscall == false)
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () {
                                          //debugPrint(answers.toString());
                                          showPopDialoguge(context);
                                        },
                                        child: Text(
                                          'All Questions',
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: CupertinoColors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          if (iscall == false)
                            Expanded(
                              // height: 170,
                              // height:_keyboardIsVisible()?MediaQuery.of(context).size.height-170:MediaQuery.of(context).size.height-270,
                              child: PageView.builder(
                                  allowImplicitScrolling: true,
                                  controller: controller,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: questionlist.length,
                                  onPageChanged: (v) {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);

                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    setState(() {
                                      _player.stop();
                                      isplaying.clear();
                                      for (var i = 0;
                                          i < questionlist.length;
                                          i++) {
                                        isplaying.add(false);
                                      }
                                      scrn = v;
                                    });
                                  },
                                  itemBuilder:
                                      (BuildContext context, position) {
                                    return Container(
                                      color: CupertinoColors.white,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                340,
                                            child: ListView.builder(
                                                itemCount: 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          color: isplaying[
                                                                      index] ==
                                                                  false
                                                              ? CupertinoColors
                                                                  .systemGrey5
                                                              : CupertinoColors
                                                                  .systemBlue,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: questionlist[
                                                                            position]
                                                                        [
                                                                        'question']
                                                                    .toString()
                                                                    .contains(
                                                                        '<div class="ckeditor-html5-audio"')
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      if (isplaying[
                                                                              position] ==
                                                                          false) {
                                                                        var a =
                                                                            extr(questionlist[position]['question'].toString());
                                                                        debugPrint(
                                                                            a.toString());
                                                                        try {
                                                                          _player
                                                                              .play();
                                                                          _player
                                                                              .setUrl(a.toString());
                                                                          setState(
                                                                              () {
                                                                            isplaying[position] =
                                                                                true;
                                                                          });
                                                                        } on ja
                                                                            .PlayerException catch (e) {
                                                                          // iOS/macOS: maps to NSError.code
                                                                          // Android: maps to ExoPlayerException.type
                                                                          // Web: maps to MediaError.code
                                                                          // Linux/Windows: maps to PlayerErrorCode.index
                                                                          print(
                                                                              "Error code: ${e.code}");
                                                                          // iOS/macOS: maps to NSError.localizedDescription
                                                                          // Android: maps to ExoPlaybackException.getMessage()
                                                                          // Web/Linux: a generic message
                                                                          // Windows: MediaPlayerError.message
                                                                          print(
                                                                              "Error message: ${e.message}");
                                                                        } on ja
                                                                            .PlayerInterruptedException catch (e) {
                                                                          // This call was interrupted since another audio source was loaded or the
                                                                          // player was stopped or disposed before this audio source could complete
                                                                          // loading.
                                                                          print(
                                                                              "Connection aborted: ${e.message}");
                                                                        } catch (e) {
                                                                          // Fallback for all errors
                                                                          print(
                                                                              e);
                                                                        }
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          isplaying[position] =
                                                                              false;
                                                                          _player
                                                                              .pause();
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          if (isplaying[position] ==
                                                                              false)
                                                                            Icon(
                                                                              Icons.play_circle_fill,
                                                                              size: 40,
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                            )
                                                                          else
                                                                            Icon(Icons.stop_circle_outlined,
                                                                                size: 40,
                                                                                color: Colors.white)
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Html(
                                                                    data: questionlist[
                                                                            position]
                                                                        [
                                                                        'question'],
                                                                    shrinkToFit:
                                                                        true,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (questionlist[position]
                                                                  ['opt_a'] !=
                                                              '' &&
                                                          questionlist[position]
                                                                  ['qtype'] ==
                                                              'MCQ')
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                value: chckboxvallist[
                                                                    position][0],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    if (value ==
                                                                        true) {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          value!;
                                                                      answers[position] =
                                                                          'opt_a';
                                                                      questids[
                                                                          position] = questionlist[position]
                                                                              [
                                                                              'id']
                                                                          .toString();
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    } else {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          value!;
                                                                      answers[position] =
                                                                          '';
                                                                      questids[
                                                                          position] = '';
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Html(
                                                                  data: questionlist[
                                                                          position]
                                                                      ['opt_a'],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      if (questionlist[position]
                                                                  ['opt_b'] !=
                                                              '' &&
                                                          questionlist[position]
                                                                  ['qtype'] ==
                                                              'MCQ')
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                value: chckboxvallist[
                                                                    position][1],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    if (value ==
                                                                        true) {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          value!;
                                                                      answers[position] =
                                                                          'opt_b';
                                                                      questids[
                                                                          position] = questionlist[position]
                                                                              [
                                                                              'id']
                                                                          .toString();
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    } else {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          value!;
                                                                      answers[position] =
                                                                          '';
                                                                      questids[
                                                                          position] = '';
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Html(
                                                                  data: questionlist[
                                                                          position]
                                                                      ['opt_b'],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      if (questionlist[position]
                                                                  ['opt_c'] !=
                                                              '' &&
                                                          questionlist[position]
                                                                  ['qtype'] ==
                                                              'MCQ')
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                value: chckboxvallist[
                                                                    position][2],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    if (value ==
                                                                        true) {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          value!;
                                                                      answers[position] =
                                                                          'opt_c';
                                                                      questids[
                                                                          position] = questionlist[position]
                                                                              [
                                                                              'id']
                                                                          .toString();
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    } else {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          value!;
                                                                      answers[position] =
                                                                          '';
                                                                      questids[
                                                                          position] = '';
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Html(
                                                                  data: questionlist[
                                                                          position]
                                                                      ['opt_c'],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      if (questionlist[position]
                                                                  ['opt_d'] !=
                                                              '' &&
                                                          questionlist[position]
                                                                  ['qtype'] ==
                                                              'MCQ')
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                value: chckboxvallist[
                                                                    position][3],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    if (value ==
                                                                        true) {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          value!;
                                                                      answers[position] =
                                                                          'opt_d';
                                                                      questids[
                                                                          position] = questionlist[position]
                                                                              [
                                                                              'id']
                                                                          .toString();
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                    } else {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          value!;
                                                                      answers[position] =
                                                                          '';
                                                                      questids[
                                                                          position] = '';
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          false;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Html(
                                                                  data: questionlist[
                                                                          position]
                                                                      ['opt_d'],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      if (questionlist[position]
                                                                  ['opt_e'] !=
                                                              '' &&
                                                          questionlist[position]
                                                                  ['qtype'] ==
                                                              'MCQ')
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                value: chckboxvallist[
                                                                    position][4],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    if (value ==
                                                                        true) {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          value!;
                                                                      answers[position] =
                                                                          'opt_e';
                                                                      questids[
                                                                          position] = questionlist[position]
                                                                              [
                                                                              'id']
                                                                          .toString();
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    } else {
                                                                      chckboxvallist[position]
                                                                              [
                                                                              4] =
                                                                          value!;
                                                                      answers[position] =
                                                                          '';
                                                                      questids[
                                                                          position] = '';
                                                                      chckboxvallist[position]
                                                                              [
                                                                              0] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              1] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              2] =
                                                                          false;
                                                                      chckboxvallist[position]
                                                                              [
                                                                              3] =
                                                                          false;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Html(
                                                                  data: questionlist[
                                                                          position]
                                                                      ['opt_e'],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      _keyboardIsVisible()
                                                          ? SizedBox(
                                                              height: 40,
                                                            )
                                                          : SizedBox(
                                                              height: 10,
                                                            ),
                                                      if (questionlist[position]
                                                              ['qtype'] ==
                                                          'OW')
                                                        Container(
                                                            //height: 60,
                                                            child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              height: 100,
                                                              child:
                                                                  CupertinoTextField(
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black)),
                                                                placeholder:
                                                                    'Your answer here',
                                                                placeholderStyle:
                                                                    GoogleFonts.poppins(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black),
                                                                onChanged: (v) {
                                                                  setState(() {
                                                                    answers[
                                                                        position] = v;
                                                                  });
                                                                  if (v
                                                                      .isNotEmpty) {
                                                                    setState(
                                                                        () {
                                                                      questids[
                                                                          position] = questionlist[position]
                                                                              [
                                                                              'id']
                                                                          .toString();
                                                                    });
                                                                  }
                                                                  if (v
                                                                      .isEmpty) {
                                                                    questids[
                                                                        position] = '';
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                    ],
                                                  );
                                                }),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          if (iscall == false)
                            Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: scrn == 0
                                    ? Text(
                                        '1' +
                                            '/' +
                                            questionlist.length.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: CupertinoColors.black,
                                            fontWeight: FontWeight.w500),
                                      )
                                    : Text(
                                        (scrn + 1).toString() +
                                            '/' +
                                            questionlist.length.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: CupertinoColors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                              ),
                            ),
                          if (iscall == false)
                            Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              color: CupertinoColors.activeGreen,
                              child: Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    color: scrn == 0
                                        ? CupertinoColors.systemGrey
                                        : CupertinoColors.systemGrey5,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: scrn == 0
                                            ? null
                                            : () {
                                                if (scrn > 0) {
                                                  setState(() {
                                                    controller!
                                                        .jumpToPage(scrn - 1);
                                                  });
                                                  FocusScopeNode currentFocus =
                                                      FocusScope.of(context);

                                                  if (!currentFocus
                                                      .hasPrimaryFocus) {
                                                    currentFocus.unfocus();
                                                  }
                                                }
                                              },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.back,
                                              color: scrn == 0
                                                  ? CupertinoColors.systemGrey5
                                                  : CupertinoColors.systemBlue,
                                            ),
                                            Text(
                                              'PREVIOUS',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: scrn == 0
                                                      ? CupertinoColors
                                                          .systemGrey5
                                                      : CupertinoColors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: scrn ==
                                                questionlist.length - 1
                                            ? () {
                                                showConfDial(context);
                                              }
                                            : () {
                                                if (scrn <
                                                    questionlist.length) {
                                                  setState(() {
                                                    controller!
                                                        .jumpToPage(scrn + 1);
                                                  });
                                                  FocusScopeNode currentFocus =
                                                      FocusScope.of(context);

                                                  if (!currentFocus
                                                      .hasPrimaryFocus) {
                                                    currentFocus.unfocus();
                                                  }
                                                }
                                              },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            scrn == questionlist.length - 1
                                                ? Text(
                                                    'SUBMIT',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        color: CupertinoColors
                                                            .black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )
                                                : Text(
                                                    'NEXT',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        color: CupertinoColors
                                                            .black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                            Icon(
                                              scrn == questionlist.length - 1
                                                  ? CupertinoIcons.checkmark_alt
                                                  : CupertinoIcons.forward,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (iscall == true)
                            Container(
                              height: MediaQuery.of(context).size.height - 245,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Exam interrupted due to call',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Please disconnect/decline the call to continue exam',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                        ],
                      )),
                )
              : Scaffold(
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
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
                        Center(child: Text("Submitting exam")),
                        SizedBox(
                          height: 20,
                        ),
                        Center(child: Text("Please wait..")),
                      ],
                    ),
                  ),
                )),
    );
  }
}
