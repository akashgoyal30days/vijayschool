import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


Future School_det(String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/getschooldetails';
  }
  if(schoolcode != ''){
    print('a...');
    uri = "https://$schoolcode.$baseurl/webservice/getschooldetails";
  }
  //debugPrint('url- $uri');
  Map bodys = {

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

Future Stud_dash(String startdate, String stdid, String stoken, String uid) async {
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  DateTime newdate = DateTime.now();
  var formatdate = formatter.format(newdate);
  print(formatdate.toString());

  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/dashboard';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/dashboard";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'student_id':stdid,
    'date_from': startdate,
    'date_to': formatdate,
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

