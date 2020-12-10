import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(10),
        ScreenUtil().setHeight(10),
        ScreenUtil().setWidth(10),
        ScreenUtil().setHeight(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
                  width: 1,
                  color: Colors.black
          ),
        ),
        child: Column(
          children: [

            GestureDetector(
              onTap: (){

              },
              child: Container(
                //color: Colors.blue,
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(20),
                  ScreenUtil().setHeight(20),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10),
                ),
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setHeight(50),
                width: double.infinity,
                child: Text("About us"),
              ),
            ),

            GestureDetector(
              onTap: (){

              },
              child: Container(
                //color: Colors.blue,
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(20),
                  ScreenUtil().setHeight(20),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10),
                ),
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setHeight(50),
                width: double.infinity,
                child: Text("How to use?"),
              ),
            ),

            GestureDetector(
              onTap: (){

              },
              child: Container(
                //color: Colors.blue,
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(20),
                  ScreenUtil().setHeight(20),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10),
                ),
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setHeight(50),
                width: double.infinity,
                child: Text("Request an Act"),
              ),
            ),

            GestureDetector(
              onTap: (){

              },
              child: Container(
                //color: Colors.blue,
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(20),
                  ScreenUtil().setHeight(20),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10),
                ),
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setHeight(50),
                width: double.infinity,
                child: Text("Rate us"),
              ),
            ),

            GestureDetector(
              onTap: (){

              },
              child: Container(
                //color: Colors.blue,
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(20),
                  ScreenUtil().setHeight(20),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10),
                ),
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setHeight(50),
                width: double.infinity,
                child: Text("Share the app"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
