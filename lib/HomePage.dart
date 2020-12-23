import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    PageController pageController = new PageController(viewportFraction: 0.8, keepPage: true);

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
                        fontWeight: FontWeight.bold,

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
                              //physics: NeverScrollableScrollPhysics(),
                              //pageSnapping: false,
                              children: [

                                  TwitterFeed(0),

                                  TwitterFeed(1),

                                  TwitterFeed(2),

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

class TwitterFeed extends StatefulWidget {

  final int i;

  @override
  _TwitterFeedState createState() => _TwitterFeedState();

  TwitterFeed(this.i);
}

class _TwitterFeedState extends State<TwitterFeed> with AutomaticKeepAliveClientMixin {

    List<String> s = [
        r"""<a class="twitter-timeline" href="https://twitter.com/Lawctopus?ref_src=twsrc%5Etfw">Tweets by Lawctopus</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
        r"""<a class="twitter-timeline" href="https://twitter.com/LiveLawIndia?ref_src=twsrc%5Etfw">Tweets by LiveLawIndia</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
        r"""<a class="twitter-timeline" href="https://twitter.com/LegallyIndia?ref_src=twsrc%5Etfw">Tweets by LegallyIndia</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>""",
    ];

    bool loading = true;

  @override
  Widget build(BuildContext context) {
      super.build(context);
      return Padding(
          padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(5),
              0,
              ScreenUtil().setWidth(5),
              0,
          ),
          child: Container(
              child: Stack(
                  children: [
                      /*WebViewPlus(
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (controller) {
                              controller.loadString(s[widget.i]);
                          },
                          onPageFinished: (url) {
                              setState(() {
                                  loading = false;
                              });
                          },
                          navigationDelegate: (navigation) {
                              return NavigationDecision.prevent;
                          },
                      ),*/

                      (loading)?Container(
                          color: Colors.white,
                          child: Center(
                              child: CircularProgressIndicator(),
                          ),
                      ):Container(),

                  ],
              ),
          ),
      );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

