import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    PageController pageController = new PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            children: [

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
                            fontSize: ScreenUtil().setSp(12.8),
                        ),
                    ),
                ),

                Text(
                    "Your Ally for Law",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                            fontFamily: "Times New Roman",
                            fontSize: ScreenUtil().setSp(18),
                            fontWeight: FontWeight.bold
                    ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(5),
                      ),
                    child: Container(
                          //height: ScreenUtil().setHeight(300),
                          /*decoration: BoxDecoration(
                              border: Border.all(
                                      width: 1,
                                      color: Colors.black
                              ),
                              color: Colors.white,
                          ),*/
                          child: PageView(
                              controller: pageController,
                              pageSnapping: false,
                              children: [

                                  Container(

                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                                  width: 1,
                                                  color: Colors.black
                                          ),
                                          color: Colors.white,
                                      ),
                                      child: Center(
                                          child: Text("Feed1"),
                                      ),
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                                  width: 1,
                                                  color: Colors.black
                                          ),
                                          color: Colors.white,
                                      ),
                                      child: Center(
                                          child: Text("Feed3"),
                                      ),
                                  ),

                              ],

                          ),
                      ),
                  ),
                ),

                Padding(
                    padding: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(5),
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(10),
                    ),
                    child: Container(
                        height: ScreenUtil().setHeight(50),
                        decoration: BoxDecoration(
                            border: Border.all(
                                    width: 1,
                                    color: Colors.black
                            ),
                            color: Colors.white,
                        ),
                        //child: Text(ScreenUtil().screenWidth.toString()),
                    ),
                ),

            ],
        ),
    );
  }
}
