import 'package:eznext/screen%20models/online_exam.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Lexam {
  static Future<void> showPopDialoguge(
      BuildContext context, GlobalKey key, String text, String title) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CupertinoAlertDialog(
              key: key,
              title: Text(title),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ok')),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(context,
                          CupertinoPageRoute(builder: (BuildContext context) => OnlineExam(
                            state: false,
                          )));
                    },
                    child: Text('Leave Exam'))
              ],
            ),
          );
        });
  }
}