import 'dart:io';

import 'package:eznext/app_constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future Stud_leave(
    String stdid,
    String applydate,
    String fromdate,
    String todate,
    String msg,
    String stoken,
    File docpath,
    String fname,
    String uid) async {
  //debugPrint(docpath.path.toString());
  //debugPrint(fname.toString());
  var uri = '';
  if (schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri = '${url}webservice/addLeave';
  }
  if (schoolcode != '') {
    uri = "https://$schoolcode.$baseurl/webservice/addLeave";
  }
  Map<String, String> headers = {
    'Accept': 'application/json',
    'Client-Service': clientservice,
    'Auth-Key': authkey,
    'User-ID': uid,
    'Authorization': stoken.toString()
  };
  var request = new http.MultipartRequest("POST", Uri.parse(uri));
  request.headers.addAll(headers);
  request.fields['student_id'] = stdid;
  request.fields['from_date'] = fromdate;
  request.fields['to_date'] = todate;
  request.fields['apply_date'] = applydate;
  request.fields['reason'] = msg;
  if (docpath.path != '') {
    request.files.add(await http.MultipartFile(
        'file', docpath.readAsBytes().asStream(), docpath.lengthSync(),
        filename: fname + '.pdf'));
  }
  http.Response response = await http.Response.fromStream(await request.send());
  //debugPrint("Result: ${response.statusCode}");
  //debugPrint(response.body.toString());
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
}

Future Stud_fetchleave(String stdid, String stoken, String uid) async {
  //debugPrint(stdid);
  var uri = '';
  if (schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();

    var url = initialschoolcode.getString('url').toString();

    uri = '${url}webservice/getApplyLeave';
  }
  if (schoolcode != '') {
    uri = "https://$schoolcode.$baseurl/webservice/getApplyLeave";
  }
  //debugPrint('url- $uri'.toString());
  Map bodys = {'student_id': stdid};
  String body = json.encode(bodys);
  final response = await http.post(uri, body: body, headers: <String, String>{
    'Accept': 'application/json',
    'Client-Service': clientservice,
    'Auth-Key': authkey,
    'User-ID': uid,
    'Authorization': stoken.toString()
  });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
}
