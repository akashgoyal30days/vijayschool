import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//---------------defined constants-------------//
const customurl = 'eznext.in/app';
const baseurl = 'eznext.in/api';
const Appname = 'EZNEXT';
const clientservice = 'smartschool';
const authkey = 'schoolAdmin@';
const schoolcode = '';
const applogointrimpath = 'uploads/school_content/logo/app_logo/';
const unautherror = 'Logged in on another device';
const wrong_school_code_error_text = 'Incorrect school code';
Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

Color themecolor = Colors.white;
Color bottombar = Colors.white;
Color appbarcolor = Colors.black;
Color botoomiconselectedcolor = CupertinoColors.systemBlue;
Color botoomiconunselectedcolor = CupertinoColors.black;
Color dashiconcolor = CupertinoColors.activeBlue;

//complementary configs
bool istabswitchingallowed = false;
bool iscallpickingallowed = false;
