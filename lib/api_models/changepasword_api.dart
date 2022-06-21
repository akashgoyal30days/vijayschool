import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


Future Stud_change_pass(String stdid, String cpass, String npass,String username,String cnf, String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/changepass';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/changepass";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'current_pass': cpass,
    'new_pass':npass, 'username':username,
    'id':stdid,
    'confirm_pass': cnf
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
