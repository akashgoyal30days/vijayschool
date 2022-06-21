import 'package:eznext/app_constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



Future Scul_code(String scode) async {
  var uri = "https://$scode.$customurl";
  final response = await http.post(
      uri, body: {
  },
      headers: <String, String>{
        'Accept': 'application/json',
      });
  var convertedDatatoJson = json.decode(response.body.replaceAll(r"\\n", ""));
  return convertedDatatoJson;
  //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyProfileClickedEvent);
}
