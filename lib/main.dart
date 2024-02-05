import 'package:allaw/AboutUs.dart';
import 'package:allaw/DocumentList.dart';
import 'package:allaw/HomePage.dart';
import 'package:allaw/LegalTerms.dart';
import 'package:allaw/Request.dart';
import 'package:allaw/widgets/AHomeIcon.dart';
import 'package:allaw/widgets/AIconButton.dart';
import 'package:allaw/widgets/onboarding.dart';
import 'package:allaw/utils/provider.dart';
import 'package:allaw/settings.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
    List<String> s = ["", "Settings", "Bare Acts", "Downloads", "Legal Terms", "About Us", "Request Legal Material", "Legal Queries", "Request Legal Query/Advice"];
    int index = 0;
    bool onboarding = true;
    
    @override
    void initState() {
        super.initState();
        Future.delayed(Duration(seconds: 3))
          .then((value) => setState((){
              onboarding = false;
          }));
    }
    

    showOnboarding() async {
        if(mounted){
            Future.delayed(Duration(seconds: 3))
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
            context,
            designSize: Size(411.4, 866.3),
        );


        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
        ]);

        return Scaffold(
            backgroundColor: Color(0xffF2F2F2),
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Stack(
                  children: [
                    Container(
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
                                        decoration: aBoxDecor15B(rounded: false),
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
                                                            fontSize: (index == 6 || index == 8) 
                                                            ? ScreenUtil().setSp(16)
                                                            : ScreenUtil().setSp(24), 
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

                                                DocumentList(
                                                  type: ListType.BareActs,
                                                ),

                                                // Downloads(),
                                                DocumentList(
                                                  type: ListType.Downloads,
                                                ),

                                                LegalTerms(),

                                                AboutUs(),

                                                Request(
                                                  type: RequestType.Material,
                                                ),
                                                
                                                DocumentList(
                                                  type: ListType.Queries,
                                                ),
                                                
                                                Request(
                                                  type: RequestType.Advice,
                                                ),

                                            ],
                                        ),
                                    ),
                                ),

                                Padding(
                                    padding: aPaddingLTRB(0, 5, 0, 10),
                                    child: Container(
                                        decoration: aBoxDecor15B(rounded: false),
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
                                                  assetName: "assets/font_download.png",
                                                  text: "Legal Terms",
                                                  onTap: () {
                                                      FocusScope.of(context).unfocus();
                                                      pageCon.jumpToPage(4);
                                                  },
                                                ),
                                                
                                                AHomeIcon(
                                                  assetName: "assets/article.png",
                                                  text: "Legal Queries",
                                                  onTap: () {
                                                    FocusScope.of(context).unfocus();
                                                      pageCon.jumpToPage(7);
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
                    
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 700),
                        curve: Curves.easeIn,
                        opacity: onboarding?1:0,
                        child: Onboarding()
                        ),
                    ),
                  ],
                ),
            ),
        );
    }
}