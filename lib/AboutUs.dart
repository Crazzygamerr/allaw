import 'package:allaw/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
    @override
    _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
                pageConProvider.of(context).pageCon.jumpToPage(1);
                return false;
            },
            child: Padding(
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
                    padding: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(20),
                        ScreenUtil().setHeight(0),
                        ScreenUtil().setWidth(20),
                        ScreenUtil().setHeight(0),
                    ),
                    child: Column(
                        children: [

                            SizedBox(
                                height: ScreenUtil().setHeight(50),
                            ),

                            Container(
                                height: ScreenUtil().setHeight(120),
                                width: ScreenUtil().setWidth(120),
                                decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20)
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset("assets/Logo.jpg"),
                            ),

                            Container(
                                padding: EdgeInsets.fromLTRB(
                                    0,
                                    ScreenUtil().setHeight(5),
                                    0,
                                    ScreenUtil().setHeight(5),
                                ),
                                child: Text(
                                    "by LexLiase",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Times New Roman",
                                        fontSize: ScreenUtil().setSp(10),
                                    ),
                                ),
                            ),

                            Text(
                                "Your Ally for Law",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Times New Roman",
                                    fontSize: ScreenUtil().setSp(13),
                                    fontWeight: FontWeight.bold,
                                ),
                            ),

                            SizedBox(
                                height: ScreenUtil().setHeight(50),
                            ),

                            Text(
                                "Allaw aims to be a one stop solutions for all the Legal needs of law "
                                        "students/enthusiasts and anyone in the field of law.\n\n"
                                        "The app provides quick access to all the information as well as study "
                                        "material that law students generally require during their law school "
                                        "journey. Starting from all the bare acts, Legal terms, study notes, and a "
                                        "dashboard for the latest legal news.",
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(13),
                                ),
                            ),

                            SizedBox(
                                height: ScreenUtil().setHeight(50),
                            ),

                            Row(
                                children: [
                                    Icon(
                                        Icons.email,
                                        size: 25,
                                    ),
                                    SizedBox(
                                        width: ScreenUtil().setWidth(10),
                                    ),
                                    GestureDetector(
                                        child: Text("allaw.help@gmail.com",
                                            style: TextStyle(fontSize: ScreenUtil().setSp(12),
                                                fontWeight: FontWeight.w300,
                                                decoration: TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.start,
                                        ),
                                        onTap: (){
                                            _urlFunc("mailto:allaw.help@gmail.com");
                                        },
                                    ),
                                ],
                            ),

                            SizedBox(
                                height: ScreenUtil().setHeight(10),
                            ),

                            Row(
                                children: [
                                    Image.asset(
                                        "assets/instagram.png",
                                        height: ScreenUtil().setHeight(25),
                                        width: ScreenUtil().setWidth(25),
                                    ),
                                    SizedBox(
                                        width: ScreenUtil().setWidth(10),
                                    ),
                                    GestureDetector(
                                        child: Text("@allaw.lexliaise",
                                            style: TextStyle(fontSize: ScreenUtil().setSp(12),
                                                fontWeight: FontWeight.w300,
                                                decoration: TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.start,
                                        ),
                                        onTap: (){
                                            _urlFunc("https://www.instagram.com/allaw.lexliaise/");
                                        },
                                    ),
                                ],
                            ),

                        ],
                    ),
                ),
            ),
        );
    }

    _urlFunc(String url) async{
        if(await canLaunch(url)){
            await launch(url);
        } else {
            Fluttertoast.showToast(msg: "Could not perform action",
                textColor: Colors.black,
                fontSize: ScreenUtil().setSp(20),
                toastLength: Toast.LENGTH_LONG,
            );
        }

    }
}