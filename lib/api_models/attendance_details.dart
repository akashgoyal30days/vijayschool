import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



Future Stud_attendance(String stdid,String year,String date, String month, String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/getAttendenceRecords';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/getAttendenceRecords";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'student_id': stdid,
    'year':year,
    'month':month,
    'date':date
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'Accept': 'application/json',
        'Client-Service': clientservice,
        'Auth-Key': authkey,
        'User-ID': uid,
        'Authorization': stoken.toString()
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
}


Future Stud_attendance_mark(String stdid,String cid, String time, String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString().replaceAll('api/', '');
    uri  = '${url}biometric';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.${baseurl.toString().replaceAll("/api", "")}/biometric";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'user_id': stdid,
    'serial_number':'liveclass',
    't':time,
    'class_id':cid
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'Accept': 'application/json',
        'Client-Service': clientservice,
        'Auth-Key': authkey,
        'User-ID': uid,
        'Authorization': stoken.toString()
      });
  //var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
  return convertedDatatoJson;
}
