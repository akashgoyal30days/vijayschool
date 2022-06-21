// @dart=2.9
import 'dart:io' show Platform;
import 'package:eznext/screen%20models/driver/driver_dashboard.dart';
import 'package:eznext/screen%20models/parent/parent_dashboard_primary.dart';
import 'package:eznext/services/sharedpreferences_instance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:audio_session/audio_session.dart';
import 'package:eznext/screen%20models/dashboard.dart';
import 'package:eznext/screen%20models/login.dart';
import 'package:eznext/screen%20models/schoolcode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'app_constants/constants.dart';
import 'package:overlay_support/overlay_support.dart';

bool isinterupted = false;
String os;
String devtoken;

//---firebase initialisation----//
FirebaseMessaging messaging = FirebaseMessaging.instance;

//--global key handler---//
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  //debugPrint("Handling a background message: ${message.messageId}");
}

//----initialising local notification----//
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//---- show local notification-----//
Future<void> _showNotification(String title, String body) async {
  final android = AndroidNotificationDetails(
      'channel id', 'channel name', 'channel description',
      priority: Priority.High, importance: Importance.Max);
  final iOS = IOSNotificationDetails();
  final platform = NotificationDetails(android, iOS);

  await flutterLocalNotificationsPlugin.show(
      0,
      title != null ? title : Appname,
      body, // notification id
      platform,
      payload: body);
}

//---main initialiser---//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesInstance.initialize();
  //--initialising firebase---//
  await Firebase.initializeApp();

  //---geting os----//
  os = Platform.operatingSystem;
  //debugPrint(os);

  //---getting username----//
  SharedPreferences studentdetails = await SharedPreferences.getInstance();
  var username = studentdetails.getString('student_id');
  var role = studentdetails.getString('role');
  //debugPrint(role);
  SharedPreferences oncecalled = await SharedPreferences.getInstance();
  oncecalled.remove("called");
  //----saving firebasetoken---//

  messaging.getToken().then((token) {
    studentdetails.setString('fbasetoken', token);
  });
  devtoken = studentdetails.getString('fbasetoken');
  //debugPrint(devtoken);

  //---starting to get notification----//
  if (username != null) {
    if (role == null) {
      studentdetails.remove('student_id');
      studentdetails.remove('token');
    }
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    final initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    //debugPrint('User granted permission: ${settings.authorizationStatus}');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //debugPrint('sss');
      //debugPrint('Message data: ${message.data['title']}');
      if (os == 'ios') {
        if (message.notification != null) {
          _showNotification(
            message.notification.title,
            message.notification.body,
          );
        } else {
          _showNotification(
            message.data['title'],
            message.data['body'],
          );
        }
      } else {
        if (message.notification != null) {
          _showNotification(
            message.notification.title,
            message.notification.body,
          );
        } else {
          _showNotification(
            message.data['title'],
            message.data['body'],
          );
        }
      }
      if (message.notification != null) {
        //debugPrint('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  //---setting potrait---//
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  //---running materialapp---//
  runApp(OverlaySupport.global(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: role == "driver"
          ? const DriverDashboard()
          : username == null
              ? MyApp()
              : role == "student"
                  ? MyHome()
                  : role == "parent"
                      ? ParentHome()
                      : MyApp(),
      navigatorKey: navigatorKey,
    ),
  ));
}

//--starting player---//
final _player = ja.AudioPlayer(
  // Handle audio_session events ourselves for the purpose of this demo.
  handleInterruptions: true,
  androidApplyAudioAttributes: true,
  handleAudioSessionActivation: true,
);

//---handling interuptions---//
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
    //debugPrint('interruption begin: ${event.begin}');
    //debugPrint('interruption type: ${event.type}');
    if (event.begin) {
      //debugPrint('here');
      if (os == 'ios') {
        isinterupted = true;
      }

      if (event.type == AudioInterruptionType.unknown) {
        //debugPrint('hhh');
        if (os == 'ios') {
          isinterupted = true;
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
          isinterupted = true;
        }
      }
    } else {
      //debugPrint('end');
      isinterupted = false;
    }
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String savedschoolurl = '';

  @override
  void initState() {
    tokens();
    getsavedschool();
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

  void getsavedschool() async {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    savedschoolurl = initialschoolcode.getString('url');
    //debugPrint(savedschoolurl);
    movetonext();
  }

  void movetonext() {
    if (schoolcode == '' && savedschoolurl == null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (BuildContext context) => Scode()));
      });
    }
    if (schoolcode != '' && savedschoolurl != null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (BuildContext context) => Login()));
      });
    }
    if (schoolcode != '' && savedschoolurl == null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (BuildContext context) => Login()));
      });
    }
    if (schoolcode == '' && savedschoolurl != null) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (BuildContext context) => Login()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Image.asset('assets/splash.png'),
          ),
        ));
  }
}
