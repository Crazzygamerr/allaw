import 'dart:convert';

import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:allaw/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
    @override
    _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    PageController pageController = new PageController(viewportFraction: 0.8, keepPage: true);
    String quote = "", author = "";

    List<Color> colorOptions = [
        Colors.limeAccent.withOpacity(0.2),
        Colors.lightGreenAccent.withOpacity(0.2),
        Colors.lightBlueAccent.withOpacity(0.2),
        Colors.pinkAccent.withOpacity(0.2),
    ];

    fetchQuote() async {
        final response = await http.get(Uri.parse("https://www.quotepub.com/api/widget/?type=rand&limit=1"));
        if(response.statusCode == 200) {
            var responseJson = json.decode(response.body);
            setState(() {
              quote = responseJson[0]["quote_body"];
              author = responseJson[0]["quote_author"];
            });
        }
    }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // depend on inherited widget so that didChangeDependencies is called again
    // when the inherited widget changes to fetch quote
    var p = PageConProvider.of(context)?.pageCon;
    
    fetchQuote();
  }

  @override
    Widget build(BuildContext context) {
        colorOptions.shuffle();
        return Container(
            child: Column(
                children: [

                    Container(
                        height: ScreenUtil().setHeight(120),
                        width: ScreenUtil().setWidth(120),
                        decoration: aBoxDecorCircle(),
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

                    Expanded(
                        child: Padding(
                            padding: aPaddingLTRB(10, 10, 10, 5),
                            child: Container(
                                child: PageView(
                                    controller: pageController,
                                    children: [
                                        TwitterFeed(0),
                                        TwitterFeed(1),
                                        TwitterFeed(2),
                                        TwitterFeed(3)
                                    ],

                                ),
                            ),
                        ),
                    ),

                    Padding(
                            padding: aPaddingLTRB(10, 5, 10, 5),
                            child: Container(
                                padding: aPaddingLTRB(1, 1, 1, 1),
                                height: ScreenUtil().setHeight(55),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    color: colorOptions[0],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: SingleChildScrollView(
                                        child: (quote == "") 
                                        ? Center(
                                          child: Container(
                                            padding: aPaddingLTRB(10, 10, 10, 10),
                                            child: CircularProgressIndicator(),
                                          ),
                                        ) 
                                        : Column(
                                            children: [
                                                Container(
                                                    width: ScreenUtil().setWidth(380),
                                                    child: Text(
                                                        quote,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize: ScreenUtil().setSp(12.5),
                                                        ),
                                                    ),
                                                ),
                                                Container(
                                                    width: ScreenUtil().setWidth(380),
                                                    child: Text(
                                                        " - " + author,
                                                        textAlign: TextAlign.end,
                                                        style: TextStyle(
                                                            fontSize: ScreenUtil().setSp(12.5),

                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ),
                        ),

                ],
            ),
        );
    }

}

class TwitterFeed extends StatefulWidget {

    final int i;

    @override
    _TwitterFeedState createState() => _TwitterFeedState();

    TwitterFeed(this.i);
}

class _TwitterFeedState extends State<TwitterFeed> with AutomaticKeepAliveClientMixin {

    List<String> s = [
        r"""<a class="twitter-timeline" href="https://twitter.com/barandbench?ref_src=twsrc%5Etfw">Tweets by BarAndBench</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
        r"""<a class="twitter-timeline" href="https://twitter.com/LiveLawIndia?ref_src=twsrc%5Etfw">Tweets by LiveLawIndia</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
        r"""<a class="twitter-timeline" href="https://twitter.com/Lawctopus?ref_src=twsrc%5Etfw">Tweets by Lawctopus</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
        r"""<a class="twitter-timeline" href="https://twitter.com/LegallyIndia?ref_src=twsrc%5Etfw">Tweets by LegallyIndia</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
    ];

    bool loading = true;

    @override
    Widget build(BuildContext context) {
        super.build(context);
        return Padding(
            padding: aPaddingLTRB(5, 0, 5, 0),
            child: Container(
                padding: aPaddingLTRB(1, 1, 1, 1),
                decoration: aBoxDecor15B(),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                        children: [
                            // WebViewPlus(
                            //     javascriptMode: JavascriptMode.unrestricted,
                            //     onWebViewCreated: (controller) {
                            //         controller.loadString(s[widget.i]);
                            //     },
                            //     onPageFinished: (url) {
                            //         setState(() {
                            //             loading = false;
                            //         });
                            //     },
                            //     navigationDelegate: (navigation) {
                            //         return NavigationDecision.prevent;
                            //     },
                            // ),
                            

                            (loading)?Container(
                                color: Colors.white,
                                child: Center(
                                    child: CircularProgressIndicator(),
                                ),
                            ):Container(),

                        ],
                    ),
                ),
            ),
        );
    }

    @override
    bool get wantKeepAlive => true;
}

