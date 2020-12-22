import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:allaw/HomePage.dart';
import 'package:allaw/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excel/excel.dart';
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
    List<String> s = ["", "Settings", "Bare Acts", "Downloads", "Legal Terms"];
    int index = 0;
    List<Offset> offsets = [];

    Future<void> readXlsx() async {

        ByteData data = await rootBundle.load("assets/test.xlsx");
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        var excel = Excel.decodeBytes(bytes);
        print(excel.tables["Sheet1"].rows);

    }

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

                            GestureDetector(
                                onTap: () {
                                    readXlsx();
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
                                                    child: Icon(
                                                        Icons.home,
                                                        size: 20,
                                                    ),
                                                ),
                                            ),

                                            Container(
                                                //color: Colors.blue,
                                                width: ScreenUtil().setWidth(200),  //275 before---------------------
                                                child: Text(
                                                    s[index],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: "Times New Roman",
                                                        fontSize: ScreenUtil().setSp(24),
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                            ),

                                            GestureDetector(
                                                onTap: () {
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
                                                    child: Icon(
                                                        Icons.settings,
                                                        size: 20,
                                                    ),
                                                ),
                                            ),

                                        ],
                                    ),
                                ),
                            ),

                            Expanded(
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
                                                            Icon(
                                                                Icons.library_books,
                                                                size: 20,
                                                            ),
                                                            Text(
                                                                "Bare Acts",
                                                                /*style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(15)
                                                                ),*/
                                                            ),
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
                                                            color: Colors.black,
                                                        ),
                                                        //color: Colors.grey,
                                                    ),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Icon(
                                                                Icons.article,
                                                                //color: Colors.white,
                                                                size: 20,
                                                            ),
                                                            Text(
                                                                "Legal Notes",
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
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
                                                            Icon(
                                                                Icons.font_download,
                                                                size: 20,
                                                            ),
                                                            Text("Legal Terms"),
                                                        ],
                                                    ),
                                                ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
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
                                                            Icon(
                                                                Icons.archive,
                                                                size: 20,
                                                            ),
                                                            Text("Downloads"),
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
