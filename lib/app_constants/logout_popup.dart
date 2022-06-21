import 'package:eznext/logoutmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class LogOutPopup {
  static Future<void> shoLogOutPopup(
      BuildContext context, GlobalKey key) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CupertinoAlertDialog(
              key: key,
              title: Text('Log out'),
              content: Text('Are you sure you want to log out ?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                     logOut(context);
                    },
                    child: Text('Yes')),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'))
              ],
            ),
          );
        });
  }
}