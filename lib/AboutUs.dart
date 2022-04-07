import 'package:allaw/provider.dart';
import 'package:allaw/utils/APadding.dart';
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
                PageConProvider.of(context)?.pageCon.jumpToPage(1);
                return false;
            },
            child: Padding(
                padding: aPaddingLTRB(10, 10, 10, 10),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            width: 1,
                            color: Colors.black,
                        ),
                        color: Colors.white,
                    ),
                    padding: aPaddingLTRB(20, 0, 20, 20),
                    child: SingleChildScrollView(
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
                                  padding: aPaddingLTRB(0, 5, 0, 5),
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
                                  "Allaw is a one-stop solution for all your Law School needs. "
                                  "This app provides quick access to all the information as well as study material "
                                  "that law students generally require throughout their legal journey and beyond. "
                                  "From a collection of all the Bare Acts, to the meanings of various Legal Terms/Maxims, and even "
                                  "some Legal Notes to help you study - we have everything you need. "
                                  "With Allaw's dashboard for Legal Updates, you can easily get to know about the latest legal developments "
                                  "in the country, along with new and exciting internship opportunities for you to look forward to.\n\n"
                                  "LexLiaise is an outsourcing legal firm, working to fulfil the everyday legal needs of individuals and companies. "
                                  "It aims to foster awareness among the public about their legal rights and powers, and also help the "
                                  "next generation of lawyers in overcoming the struggles of Law School. Allaw is a progressive"
                                  " step towards achieving this goal.",
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