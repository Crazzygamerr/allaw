import 'package:allaw/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share/share.dart';
import 'package:app_review/app_review.dart';

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
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    border: Border.all(
                        width: 1,
                        color: Colors.black,
                    ),
                    color: Colors.white,
                ),
                child: SingleChildScrollView(
                    child: Column(
                        children: [

                            GestureDetector(
                                onTap: (){
                                    pageConProvider.of(context).pageCon.jumpToPage(5);
                                },
                                child: Container(
                                    //color: Colors.blue,
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(color: Colors.transparent),
                                            bottom: BorderSide(color: Colors.black),
                                            left: BorderSide(color: Colors.transparent),
                                            right: BorderSide(color: Colors.transparent),
                                        ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    height: ScreenUtil().setHeight(60),
                                    width: double.infinity,
                                    child: Text("About us",
                                        style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14)
                                        ),
                                    ),
                                ),
                            ),

                            GestureDetector(
                                onTap: (){

                                },
                                child: Container(
                                    //color: Colors.blue,
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(color: Colors.transparent),
                                            bottom: BorderSide(color: Colors.black),
                                            left: BorderSide(color: Colors.transparent),
                                            right: BorderSide(color: Colors.transparent),
                                        ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    height: ScreenUtil().setHeight(60),
                                    width: double.infinity,
                                    child: Text("How to use?",
                                        style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14)
                                        ),
                                    ),
                                ),
                            ),

                            GestureDetector(
                                onTap: (){
                                    pageConProvider.of(context).pageCon.jumpToPage(6);
                                },
                                child: Container(
                                    //color: Colors.blue,
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(color: Colors.transparent),
                                            bottom: BorderSide(color: Colors.black),
                                            left: BorderSide(color: Colors.transparent),
                                            right: BorderSide(color: Colors.transparent),
                                        ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    height: ScreenUtil().setHeight(60),
                                    width: double.infinity,
                                    child: Text("Request Material",
                                        style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14)
                                        ),
                                    ),
                                ),
                            ),

                            GestureDetector(
                                onTap: (){
                                    AppReview.requestReview;
                                },
                                child: Container(
                                    //color: Colors.blue,
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(color: Colors.transparent),
                                            bottom: BorderSide(color: Colors.black),
                                            left: BorderSide(color: Colors.transparent),
                                            right: BorderSide(color: Colors.transparent),
                                        ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    height: ScreenUtil().setHeight(60),
                                    width: double.infinity,
                                    child: Text("Rate us",
                                        style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14)
                                        ),
                                    ),
                                ),
                            ),

                            GestureDetector(
                                onTap: (){
                                    Share.share("ALLAW by LexLiaise - Your Ally For Law\n"
                                            "A one stop solutions for all the Legal needs.");
                                },
                                child: Container(
                                    //color: Colors.blue,
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(20),
                                        ScreenUtil().setHeight(0),
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(0),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(color: Colors.transparent),
                                            bottom: BorderSide(color: Colors.black),
                                            left: BorderSide(color: Colors.transparent),
                                            right: BorderSide(color: Colors.transparent),
                                        ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    height: ScreenUtil().setHeight(60),
                                    width: double.infinity,
                                    child: Text("Share the app",
                                        style: TextStyle(
                                                fontSize: ScreenUtil().setSp(14)
                                        ),
                                    ),
                                ),
                            ),

                        ],
                    ),
                ),
            ),
        );
    }
}
