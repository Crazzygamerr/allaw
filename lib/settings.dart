import 'package:allaw/global/widgets/SettingsItem.dart';
import 'package:allaw/provider.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:app_review/app_review.dart';

class Settings extends StatefulWidget {
    @override
    _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: aPaddingAll(10),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    border: Border.all(
                        width: 1,
                        color: Colors.black,
                    ),
                    color: Colors.white,
                ),
                child: SingleChildScrollView(
                    child: Column(
                        children: [

                            SettingsItem(
                              text: "About Us",
                              onTap: (){
                                  PageConProvider.of(context)?.pageCon.jumpToPage(5);
                              },
                            ),

                            SettingsItem(
                              text: "How to use?",
                              onTap: (){

                              },
                            ),

                            SettingsItem(
                              text: "Request Material",
                              onTap: (){
                                  PageConProvider.of(context)?.pageCon.jumpToPage(6);
                              },
                            ),

                            SettingsItem(
                              text: "Rate us",
                              onTap: (){
                                  AppReview.requestReview;
                              },
                            ),

                            SettingsItem(
                              text: "Share the app",
                              onTap: (){
                                  Share.share("ALLAW by LexLiaise - Your Ally For Law\n"
                                          "A one stop solutions for all the Legal needs.");
                              },
                            ),

                        ],
                    ),
                ),
            ),
        );
    }
}
