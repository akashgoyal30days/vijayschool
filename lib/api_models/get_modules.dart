import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


Future School_modules_det(String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/getModuleStatus';
  }
  if(schoolcode != ''){
    print('.....');
    uri = "https://$schoolcode.$baseurl/webservice/getModuleStatus";
  }
  //debugPrint('url- $uri');
  Map bodys = {
   'user':'student'
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
  //var convertedDatatoJson = response.body.replaceAll(r"\\n", "");
  return convertedDatatoJson;
}


