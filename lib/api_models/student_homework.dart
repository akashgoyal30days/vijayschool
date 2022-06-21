import 'dart:io';

import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



Future Stud_hwork_get(String stdid, String stoken, String uid) async {
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/gethomework';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/gethomework";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'student_id': stdid
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
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}


Future Stud_upld_hwrk(String stdid,String hid,String msg, String stoken,File docpath,String fname, String uid) async {
  print(docpath.path);
  print(fname);
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}webservice/addaa';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/webservice/addaa";
  }
  Map<String, String> headers = { 'Accept': 'application/json',
    'Client-Service': clientservice,
    'Auth-Key': authkey,
    'User-ID': uid,
    'Authorization': stoken.toString()
  };
  var request = new http.MultipartRequest(
      "POST", Uri.parse(uri));
  request.headers.addAll(headers);
  request.fields['student_id'] = stdid;
  request.fields['homework_id'] = hid;
  request.fields['message'] = msg;
  request.files.add(await http.MultipartFile('file',
      docpath.readAsBytes().asStream(),
      docpath.lengthSync(),
      filename: fname+'.pdf'));
  http.Response response = await http.Response.fromStream(
      await request.send());
  print("Result: ${response.statusCode}");
  print(response.body.toString());
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
}
