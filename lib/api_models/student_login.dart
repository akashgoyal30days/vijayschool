import 'package:eznext/app_constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';



Future Stud_login(String uname, String password) async {
  //debugPrint(devtoken);
  var uri = '';
  if(schoolcode == '') {
    SharedPreferences initialschoolcode = await SharedPreferences.getInstance();
    var url = initialschoolcode.getString('url').toString();
    uri  = '${url}auth/login';
  }
  if(schoolcode != ''){
    uri = "https://$schoolcode.$baseurl/auth/login";
  }
  //debugPrint('url- $uri');
  Map bodys = {
    'username': uname, 'password': password,
    if(devtoken!=null)
      'deviceToken': devtoken
    else
      'deviceToken': ''
  };
  String body = json.encode(bodys);
  final response = await http.post(
      uri, body: body,
      headers: <String, String>{
        'Accept': 'application/json',
        'Client-Service': clientservice,
        'Auth-Key': authkey,
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  //debugPrint(convertedDatatoJson.toString());
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}
