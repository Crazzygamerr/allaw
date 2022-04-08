import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';


class ADrawer extends StatelessWidget {
  final String fileName;
  
  final List<String> heading, section;
  final List<int> page;
  final List<bool> sub, minimized;
  final double headingH, subH;
  
  final PDFViewController? pdfViewController;
  final Function setState, setSlider;
  
  const ADrawer({ 
    Key? key,
    required this.fileName,
    required this.heading,
    required this.section,
    required this.page,
    required this.sub,
    required this.minimized,
    required this.pdfViewController,
    required this.headingH,
    required this.subH,  
    required this.setState,
    required this.setSlider,
   }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color(0xffF2F2F2),
        width: ScreenUtil().setWidth(375),
        padding: aPaddingLTRB(0, 10, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: aPaddingLTRB(10, 0, 0, 10),
              child: Text(
                fileName,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20),
                ),
              ),
            ),

            Container(
              width: double.infinity,
              decoration: aBoxDecorBottom(grey: true),
              child: Row(
                children: [

                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Title",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(15),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: ScreenUtil().setWidth(1),
                    height: ScreenUtil().setHeight(70),
                    color: Colors.black,
                  ),

                  Padding(
                    padding: aPaddingLTRB(2, 0, 2, 0),
                    child: Container(
                      width: ScreenUtil().setWidth(59),
                      alignment: Alignment.center,
                      child: Text(
                        "Section No.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(15),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: ScreenUtil().setWidth(1),
                    height: ScreenUtil().setHeight(70),
                    color: Colors.black,
                  ),

                  Padding(
                    padding: aPaddingLTRB(5, 10, 0, 10),
                    child: Container(
                      width: ScreenUtil().setWidth(44),
                      alignment: Alignment.center,
                      child: Text(
                        "Page No.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(15),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: heading.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String part1 = "", part2 = "";
                  if(section[index].contains("-")) {
                    part1 = section[index].split("-")[0];
                    part2 = section[index].split("-")[1];
                  }

                  if(sub[index] && minimized[index])
                    return Container();
                  else
                    return GestureDetector(
                      onTap: () {
                        pdfViewController?.setPage(page[index]-1);
                        setSlider();
                        Navigator.pop(context);
                      },
                      child: Stack(
                        children: [
                
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: ScreenUtil().setWidth(260),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(1),
                                height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(63),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(1),
                                height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                color: Colors.black,
                              ),
                            ],
                          ),
                
                          Container(
                            width: ScreenUtil().setWidth(375),
                            height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                            decoration: aBoxDecorBottom(),
                            child: Row(
                              children: [
                
                                (sub[index]) ? Container(
                                  width: ScreenUtil().setWidth(15),
                                ) : Container(),
                
                                Container(
                                  width: ScreenUtil().setWidth(
                                    (sub[index])
                                        ? 245
                                        : (!sub[index])
                                        ? 210
                                        :260,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: aPaddingLTRB(10, 5, 10, 5),
                                  child: Text(
                                    heading[index].toString(),
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp((sub[index])?12:15),
                                    ),
                                  ),
                                ),
                
                                (!sub[index]) ? GestureDetector(
                                  onTap: () {
                                    for(int i=index+1;i<minimized.length;i++){
                                      if(!sub[i])
                                        break;
                                      else
                                        minimized[i] = !minimized[i];
                                    }
                                    setState();
                                  },
                                  child: Container(
                                    height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                    width: ScreenUtil().setWidth(50),
                                    padding: aPaddingLTRB(10, 10, 10, 10),
                                    child: Image.asset(
                                      (minimized[index+1])?"assets/expand_more.png":"assets/expand_less.png",
                                    ),
                                  ),
                                ) : Container(),
                
                                Container(
                                  width: ScreenUtil().setWidth(63),
                                  alignment: Alignment.center,
                                  //color: (sub[index] && minimized[index])?Colors.green:Colors.white,
                                  child: Text(
                                    (section[index].contains("-"))?"$part1\n-\n$part2":section[index].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp((sub[index])?10:15),
                                    ),
                                  ),
                                ),
                
                                Container(
                                  width: ScreenUtil().setWidth(45),
                                  padding: aPaddingLTRB(0, 5, 0, 5),
                                  alignment: Alignment.center,
                                  child: Text(
                                    page[index].toString(),
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp((sub[index])?10:15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}