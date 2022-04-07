import 'dart:convert';
import 'dart:io';

import 'package:allaw/AboutUs.dart';
import 'package:allaw/HomePage.dart';
import 'package:allaw/global/widgets/AHomeIcon.dart';
import 'package:allaw/global/widgets/AIconButton.dart';
import 'package:allaw/global/widgets/onboarding.dart';
import 'package:allaw/provider.dart';
import 'package:allaw/settings.dart';
import 'package:allaw/Request.dart';
import 'package:allaw/utils/APadding.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:allaw/BareActs.dart';
import 'package:allaw/Downloads.dart';
import 'package:allaw/LegalTerms.dart';

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
class MyHomePage extends StatefulWidget {

    @override
    _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    PageController pageCon = new PageController();
    List<String> s = ["", "Settings", "Bare Acts", "Downloads", "Legal Terms", "About Us", "Request Material"];
    int index = 0;
    bool onboarding = true;
    
    @override
    void initState() {
        super.initState();
        showOnboarding();
    }

    showOnboarding() async {
        if(mounted){
            Future.delayed(Duration(seconds: 1))
                    .then((value) => setState((){
                        onboarding = false;
                    }));
        } else {
            Future.delayed(Duration(milliseconds: 500))
                    .then((value) => showOnboarding());
        }
    }

    @override
    Widget build(BuildContext context) {
        ScreenUtil.init(
            BoxConstraints(maxWidth: 411.4, maxHeight: 866.3),
            context: context,
            designSize: Size(411.4, 866.3),
        );


        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
        ]);

        if(onboarding) return Onboarding();
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
                                padding: aPaddingLTRB(0, 10, 0, 10),
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

                                            AIconButton(
                                              assetName: "assets/home.png", 
                                              onTap: () {
                                                FocusScope.of(context).unfocus();
                                                pageCon.jumpToPage(0);
                                              },
                                            ),

                                            Container(
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

                                            AIconButton(
                                              assetName: "assets/settings.png", 
                                              onTap: () {
                                                FocusScope.of(context).unfocus();
                                                pageCon.jumpToPage(1);
                                              },
                                            ),
                                        ],
                                    ),
                                ),
                            ),

                            Expanded(
                                child: PageConProvider(
                                    pageCon: pageCon,
                                    child: PageView(
                                        controller: pageCon,
                                        onPageChanged: (page) {
                                            setState(() {
                                                if(page<s.length)
                                                    index = page;
                                            });
                                        },
                                        physics: NeverScrollableScrollPhysics(),
                                        children: [

                                            HomePage(),

                                            Settings(),

                                            BareActs(),

                                            Downloads(),

                                            LegalTerms(),

                                            AboutUs(),

                                            Request(),

                                        ],
                                    ),
                                ),
                            ),

                            Padding(
                                padding: aPaddingLTRB(0, 5, 0, 10),
                                child: Container(
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

                                            AHomeIcon(
                                              assetName: "assets/library_books.png", 
                                              text: "Bare Acts",
                                              onTap: () {
                                                FocusScope.of(context).unfocus();
                                                pageCon.jumpToPage(2);
                                              },
                                            ),
                                            
                                            AHomeIcon(
                                              assetName: "assets/article.png",
                                              text: "Legal Notes",
                                              onTap: () {

                                              },
                                            ),
                                            
                                            AHomeIcon(
                                              assetName: "assets/font_download.png",
                                              text: "Legal Terms",
                                              onTap: () {
                                                  FocusScope.of(context).unfocus();
                                                  pageCon.jumpToPage(4);
                                              },
                                            ),
                                            
                                            AHomeIcon(
                                              assetName: "assets/archive.png",
                                              text: "Downloads",
                                              onTap: () {
                                                  FocusScope.of(context).unfocus();
                                                  pageCon.jumpToPage(3);
                                              },
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