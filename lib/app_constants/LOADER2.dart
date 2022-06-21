import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Dialogs2 {
  static Future<void> showLoadingDialog(
      BuildContext context, String text) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: CupertinoColors.extraLightBackgroundGray,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10,),
                        Text(text,style: TextStyle(color: Colors.blueAccent,),
                          textAlign: TextAlign.center,)
                      ]),
                    )
                  ]));
        });
  }
}