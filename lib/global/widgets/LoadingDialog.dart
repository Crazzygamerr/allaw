import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'dart:convert';

void showLoadingDialog(BuildContext context, {bool? isError}) {
  showDialog(
    context: context,
    builder: (_) => WillPopScope(
      onWillPop: () async {
        return isError ?? false;
      },
      child: AlertDialog(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (isError ?? false)?"Error!":"Loading...",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14),
              ),
            ),
            (isError ?? false)
              ? Icon(
                  Icons.clear,
                  color: Colors.red,
              ) : CircularProgressIndicator(),
          ],
        ),
      ),
    ),
    barrierDismissible: isError ?? false,
  );
}

void showResposeDialog(BuildContext context, String s, Response response) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(s),
                        Icon(
                            (jsonDecode(response.body)['status'] == "SUCCESS")
                              ? Icons.check
                              : Icons.clear,
                            color: (jsonDecode(response.body)['status'] == "SUCCESS")
                              ? Colors.green
                              : Colors.red,
                        ),
                    ],
                ),
            ],
        ),
    ),
  );
}