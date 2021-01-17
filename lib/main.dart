import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:allaw/AboutUs.dart';
import 'package:allaw/HomePage.dart';
import 'package:allaw/provider.dart';
import 'package:allaw/settings.dart';
import 'package:allaw/Request.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:allaw/BareActs.dart';
import 'package:allaw/Downloads.dart';
import 'package:allaw/LegalTerms.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseAuth auth = FirebaseAuth.instance;
    if(auth.currentUser == null)      //////////////////////////////////////Anonymous signin here!
        auth.signInAnonymously();
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Allaw',
            theme: ThemeData(fontFamily: 'SF Pro'),
            debugShowCheckedModeBanner: false,
            home: MyHomePage(),
        );
    }
}
// PDF Viewer icon
class MyHomePage extends StatefulWidget {

    @override
    _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    PageController pageCon = new PageController();
    List<String> s = ["", "Settings", "Bare Acts", "Downloads", "Legal Terms", "About Us", "Request an Act"];
    int index = 0;
    List<Offset> offsets = [];
    bool onboarding = true;
    @override
    void initState() {
        super.initState();
        func1();
    }

    func1() async {
        if(mounted){
            Future.delayed(Duration(seconds: 1)).then((value) => setState((){onboarding = false;}));
        } else {
            Future.delayed(Duration(milliseconds: 50)).then((value) => setState((){func1();}));
        }
    }

    @override
    Widget build(BuildContext context) {
        ScreenUtil.init(context,
                designSize: Size(411.4, 866.3), allowFontScaling: true);

        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
        ]);
        if(onboarding) return Scaffold(
            backgroundColor: Color(0xff404040),
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        SizedBox(
                            height: ScreenUtil().setHeight(230),
                        ),
                        Container(
                            height: ScreenUtil().setHeight(250),
                            width: ScreenUtil().setWidth(250),
                            decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset("assets/Logo.jpg"),
                        ),
                        Text(
                            "Your Ally for Law",
                            style: TextStyle(
                                fontFamily: "Times New Roman",
                                fontSize: ScreenUtil().setSp(18),
                                color: Colors.white,
                            ),
                        ),
                        SizedBox(
                            height: ScreenUtil().setHeight(205),
                        ),
                        Text(
                            "by LexLiaise",
                            style: TextStyle(
                                fontFamily: "Times New Roman",
                                fontSize: ScreenUtil().setSp(16),
                                color: Colors.white,
                            ),
                        ),
                    ],
                ),
            ),
        );
        else return Scaffold(
            backgroundColor: Color(0xffF2F2F2),
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                            GestureDetector(
                                onTap: () {
                                },
                                child: Container(
                                    color: Colors.grey,
                                    height: ScreenUtil().setHeight(50),
                                ),
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
                                            color: Colors.black,
                                        ),
                                        color: Colors.white,
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [

                                            GestureDetector(
                                                onTap: () {
                                                    FocusScope.of(context).unfocus();
                                                    pageCon.jumpToPage(0);
                                                },
                                                child: Container(
                                                    width: ScreenUtil().setWidth(50),
                                                    height: ScreenUtil().setHeight(50),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.black,
                                                        ),
                                                    ),
                                                    padding: EdgeInsets.fromLTRB(
                                                        ScreenUtil().setWidth(8),
                                                        ScreenUtil().setHeight(8),
                                                        ScreenUtil().setWidth(8),
                                                        ScreenUtil().setHeight(8),
                                                    ),
                                                    child: Image.asset(
                                                        "assets/home.png",
                                                    ),
                                                ),
                                            ),

                                            Container(
                                                //color: Colors.blue,
                                                width: ScreenUtil().setWidth(290),  //275 before---------------------
                                                child: Text(
                                                    s[index],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil().setSp(24),
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                            ),

                                            GestureDetector(
                                                onTap: () {
                                                    FocusScope.of(context).unfocus();
                                                    pageCon.jumpToPage(1);
                                                },
                                                child: Container(
                                                    width: ScreenUtil().setWidth(50),
                                                    height: ScreenUtil().setHeight(50),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.black,
                                                        ),
                                                    ),
                                                    padding: EdgeInsets.fromLTRB(
                                                        ScreenUtil().setWidth(8),
                                                        ScreenUtil().setHeight(8),
                                                        ScreenUtil().setWidth(8),
                                                        ScreenUtil().setHeight(8),
                                                    ),
                                                    child: Image.asset(
                                                        "assets/settings.png",
                                                    ),/*Icon(
                                                        Icons.settings,
                                                        size: 27,
                                                    ),*/
                                                ),
                                            ),

                                        ],
                                    ),
                                ),
                            ),

                            Expanded(
                                child: pageConProvider(
                                    pageCon: pageCon,
                                    child: PageView(
                                        controller: pageCon,
                                        onPageChanged: (page) {
                                            setState(() {
                                                if(page<s.length)
                                                    index = page;
                                            });
                                        },
                                        //physics: NeverScrollableScrollPhysics(),
                                        children: [

                                            HomePage(),

                                            Settings(),

                                            BareActs(),

                                            Downloads(),

                                            LegalTerms(),

                                            AboutUs(),

                                            Request(),

                                            /*Container(
                                              color: Colors.blue,
                                              child: GestureDetector(
                                                  onTap: () {
                                                      test();
                                                  },
                                                  onPanStart: (details) {
                                                      print("Start: " + details.localPosition.toString());
                                                      setState(() {
                                                        offsets.add(details.localPosition);
                                                      });
                                                      //offsets.add(offset);
                                                  },
                                                  onPanUpdate: (details) {
                                                      print("Update: " + details.localPosition.toString());
                                                      setState(() {
                                                          offsets.add(details.localPosition);
                                                      });
                                                  },
                                                  onPanEnd: (details) {
                                                      setState(() {
                                                          offsets.add(null);
                                                      });
                                                  },
                                                  child: CustomPaint(
                                                      painter: TestPaint(offsets: offsets),
                                                  ),
                                              ),
                                          ),*/

                                        ],
                                    ),
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
                                    //height: ScreenUtil().setHeight(50),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.black,
                                        ),
                                        color: Colors.white,
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [

                                            GestureDetector(
                                                onTap: () {
                                                    FocusScope.of(context).unfocus();
                                                    pageCon.jumpToPage(2);
                                                },
                                                child: Container(
                                                    width: ScreenUtil().setWidth(100),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.black,
                                                        ),
                                                    ),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Image.asset(
                                                                "assets/library_books.png",
                                                                width: ScreenUtil().setWidth(20),
                                                                height: ScreenUtil().setHeight(20),
                                                            ),
                                                            Text(
                                                                "Bare Acts",
                                                                style: TextStyle(
                                                                        fontSize: ScreenUtil().setSp(14)
                                                                ),
                                                                /*style: TextStyle(
                                                                    fontFamily: "SF Pro",
                                                                    fontStyle: FontStyle.normal,
                                                                ),*/
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            GestureDetector(
                                                onTap: () {

                                                },
                                                child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                        Container(
                                                            width: ScreenUtil().setWidth(100),
                                                            //height: ScreenUtil().setHeight(75),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(15),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: Colors.black,
                                                                ),
                                                                //color: Colors.grey,
                                                            ),
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                    Image.asset(
                                                                        "assets/article.png",
                                                                        width: ScreenUtil().setWidth(20),
                                                                        height: ScreenUtil().setHeight(20),
                                                                    ),
                                                                    Text(
                                                                        "Legal Notes",
                                                                        style: TextStyle(
                                                                            fontSize: ScreenUtil().setSp(14)
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                        Transform.rotate(
                                                            angle: -3.14*1/10,
                                                            child: Opacity(
                                                                opacity: 1,
                                                                child: Container(
                                                                    width: ScreenUtil().setWidth(98),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey,
                                                                        borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(11),
                                                                            //bottomRight: Radius.circular(5),
                                                                            bottomLeft: Radius.circular(11),
                                                                        ),
                                                                    ),
                                                                    alignment: Alignment.center,
                                                                    child: Text(
                                                                        "Coming soon",
                                                                        style: TextStyle(
                                                                            //color: Colors.white
                                                                            fontSize: ScreenUtil().setSp(10),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                    FocusScope.of(context).unfocus();
                                                    pageCon.jumpToPage(4);
                                                },
                                                child: Container(
                                                    width: ScreenUtil().setWidth(100),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.black,
                                                        ),
                                                    ),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Image.asset(
                                                                "assets/font_download.png",
                                                                width: ScreenUtil().setWidth(20),
                                                                height: ScreenUtil().setHeight(20),
                                                            ),
                                                            Text(
                                                                "Legal Terms",
                                                                style: TextStyle(
                                                                        fontSize: ScreenUtil().setSp(14)
                                                                ),
                                                                /*style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 12,
                                                                ),*/
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                    FocusScope.of(context).unfocus();
                                                    pageCon.jumpToPage(3);
                                                },
                                                child: Container(
                                                    width: ScreenUtil().setWidth(100),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.black,
                                                        ),
                                                    ),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Image.asset(
                                                                "assets/archive.png",
                                                                width: ScreenUtil().setWidth(20),
                                                                height: ScreenUtil().setHeight(20),
                                                            ),
                                                            Text(
                                                                "Downloads",
                                                                style: TextStyle(
                                                                        fontSize: ScreenUtil().setSp(14)
                                                                ),
                                                            ),
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

    test() async {
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = new File("$dir/test.json");
        Map<String, dynamic> json = {};
        json['one more'] = [1, 2, 3, 4, 5];
        file.writeAsString(jsonEncode(json));
        var x = await file.readAsString();
        print(x);
    }

}

class TestPaint extends CustomPainter {
    final offsets;

    TestPaint({this.offsets}) : super();


    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
            ..color = Colors.black
            ..isAntiAlias = true
            ..strokeWidth = 2;

        //canvas.drawLine(Offset(100,100), Offset(200,200), paint);
        if(offsets != null){
            //canvas.drawPoints(PointMode.polygon, offsets, paint);
            for(int i=1; i<offsets.length; i++){
                if(offsets[i] == null || offsets[i-1] == null)
                    continue;
                canvas.drawLine(offsets[i-1], offsets[i], paint);
            }
        }

    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
