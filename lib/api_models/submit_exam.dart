import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



Future Sub_exam(String stdid, String stoken, String uid, List rows) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/saveonlineexam';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/saveonlineexam";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'onlineexam_student_id': stdid,
    'rows': rows

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
 // var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
 var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
}
