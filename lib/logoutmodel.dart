import 'package:eznext/screen%20models/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future logOut(BuildContext context)async{
  SharedPreferences studentdetails = await SharedPreferences.getInstance();
  studentdetails.remove('student_id');
  studentdetails.remove('role');
  studentdetails.remove("childids");
  studentdetails.remove("childcls");
  studentdetails.remove("childsections");
  studentdetails.remove("childclsid");
  studentdetails.remove("childsecid");
  studentdetails.remove("childname");
  studentdetails.remove("childimage");
  studentdetails.remove('student_name');
  Navigator.popUntil(context, (_) => !Navigator.canPop(context));
  Navigator.pushReplacement(context,
      CupertinoPageRoute(builder: (BuildContext context) => Login()));
}