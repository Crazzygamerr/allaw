import 'package:allaw/global/widgets/TextItem.dart';
import 'package:allaw/provider.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_review/app_review.dart';

class Settings extends StatefulWidget {
    @override
    _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: aPaddingLTRB(10, 10, 10, 10),
            child: Container(
                decoration: aBoxDecor15B(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), 
                  child: SingleChildScrollView(
                      child: Column(
                          children: [
                
                              TextItem(
                                text: "About Us",
                                onTap: (){
                                    PageConProvider.of(context)?.pageCon.jumpToPage(5);
                                },
                              ),
                
                              TextItem(
                                text: "How to use?",
                                onTap: (){
                
                                },
                              ),
                
                              TextItem(
                                text: "Request Material",
                                onTap: (){
                                    PageConProvider.of(context)?.pageCon.jumpToPage(6);
                                },
                              ),
                              
                              TextItem(
                                text: "Request Advice",
                                onTap: (){
                                    // PageConProvider.of(context)?.pageCon.jumpToPage(6);
                                },
                              ),
                
                              TextItem(
                                text: "Rate us",
                                onTap: (){
                                    AppReview.requestReview;
                                },
                              ),
                
                              TextItem(
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
            ),
        );
    }
}
