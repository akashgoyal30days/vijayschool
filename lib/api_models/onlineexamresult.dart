import 'package:eznext/app_constants/constants.dart';
import 'package:eznext/services/sharedpreferences_instance.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



Future Stud_onlineexam_result(String oestdid, String eid, String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    var url = SharedPreferencesInstance.getString('url').toString();
    uri  = '${url}webservice/getonlineexamresult';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/getonlineexamresult";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'onlineexam_student_id': oestdid,
    'exam_id': eid
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

