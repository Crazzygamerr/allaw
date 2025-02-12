import 'dart:io';

import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:share_plus/share_plus.dart';

class TextItem extends StatelessWidget {
  final Function onTap;
  final String text, dir;
  final Function? getDocs;
  const TextItem({ 
    Key? key,
    required this.onTap,
    required this.text,
    this.dir = "",
    this.getDocs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aBoxDecorBottom(),
      alignment: Alignment.centerLeft,
      height: ScreenUtil().setHeight(60),
      width: double.infinity,
      child: Theme(
        data: ThemeData(
          splashColor: Colors.black38,
        ),
        child: Material(
          child: InkWell(
            onTap: () => onTap(),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(20),
                  ),
                  Expanded(
                    child: Text(
                      text,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                        ),
                    ),
                  ),
                  
                  Row(
                    children: [
                      (dir != "") ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Theme(
                          data: ThemeData(
                            splashColor: Colors.black38,
                          ),
                          child: Material(
                            child: InkWell(
                              child: IconButton(
                                onPressed: (() {
                                  Share.shareFiles([dir + "/" + (text) + ".pdf"]);
                                }), 
                                icon: Icon(Icons.share),
                                ),
                            ),
                          ),
                        ),
                      ) : Container(),
                        
                       (dir != "") ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                         child: Theme(
                          data: ThemeData(
                            splashColor: Colors.black38,
                          ),              
                           child: Material(
                             child: InkWell(
                               child: IconButton(
                                onPressed: (() {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                        title: Text("Are you sure you want to delete the file?"),
                                        content: Text("Changes will be lost."),
                                        actions: [
                                            TextButton(
                                                child: Text("No"),
                                                onPressed: (){
                                                    Navigator.pop(context);
                                                },
                                            ),
                                            TextButton(
                                                child: Text("Yes"),
                                                onPressed: (){
                                                    Navigator.pop(context);
                                                    File(dir + "/" + (text) + ".pdf").delete();
                                                    getDocs!();
                                                },
                                            )
                                        ],
                                    ),
                                  );
                                }), 
                                icon: Icon(Icons.delete),
                                ),
                             ),
                           ),
                         ),
                       ) : Container(),
                    ],
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}