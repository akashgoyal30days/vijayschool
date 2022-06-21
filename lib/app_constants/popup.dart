import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class PopUps {
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
                    child: Text('ok'))
              ],
            ),
          );
        });
  }
}