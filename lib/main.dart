import 'package:allaw/HomePage.dart';
import 'package:allaw/Viewer.dart';
import 'package:allaw/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allaw',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  PageController pageCon = new PageController();

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context,
            designSize: Size(411.4, 866.3), allowFontScaling: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Container(
                color: Colors.grey,
                height: ScreenUtil().setHeight(50),
              ),

              Container(
                height: ScreenUtil().setHeight(70),
                padding: EdgeInsets.fromLTRB(
                  0,
                  ScreenUtil().setHeight(10),
                  0,
                  ScreenUtil().setHeight(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                            width: 1,
                            color: Colors.black
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => Viewer(
                                url: "https://pdfhost.io/v/qcqMs3bsC_The_Limitation_Act_1963_HLpdf.pdf",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: ScreenUtil().setWidth(50),
                          height: ScreenUtil().setHeight(50),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              width: 1,
                              color: Colors.black
                            )
                          ),
                          child: Icon(Icons.home),
                        ),
                      ),
                      /*GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => Viewer(
                                url: "https://www.cgs.iitk.ac.in/user/hk/csd101/2020/exams/enda.pdf",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: ScreenUtil().setWidth(50),
                          height: ScreenUtil().setHeight(50),
                          decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                  )
                          ),
                          child: Icon(Icons.home),
                        ),
                      ),*/

                      Container(
                        //color: Colors.blue,
                        width: ScreenUtil().setWidth(200),  //275 before---------------------
                        child: Text(
                          "Test",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Times New Roman",
                            fontSize: ScreenUtil().setSp(24),
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          width: ScreenUtil().setWidth(50),
                          height: ScreenUtil().setHeight(50),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                    width: 1,
                                    color: Colors.black
                            )
                          ),
                          child: Icon(Icons.settings),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: pageCon,
                  //physics: NeverScrollableScrollPhysics(),
                  children: [

                    HomePage(),

                    Settings(),

                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  ScreenUtil().setHeight(5),
                  0,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          width: ScreenUtil().setWidth(100),
                          decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                  )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.library_books),
                              Text("Bare Acts")
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          width: ScreenUtil().setWidth(100),
                          decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                  )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article),
                              Text("Legal Notes")
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          width: ScreenUtil().setWidth(100),
                          decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                  )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.font_download),
                              Text("Legal Terms")
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          width: ScreenUtil().setWidth(100),
                          decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                  )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.archive),
                              Text("Downloads")
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              Container(
                color: Colors.grey,
                height: ScreenUtil().setHeight(50),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
