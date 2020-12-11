import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class Viewer extends StatefulWidget {

  final String url;

  @override
  _ViewerState createState() => _ViewerState();

  Viewer({this.url});
}

class _ViewerState extends State<Viewer> {

  PDFDocument pdfFile, offlinePdfFile;
  PageController pageCon = new PageController();
  bool load = false, online = true;
  String url = "", filePath = "", error = "";

  initState() {
    url = widget.url;
    super.initState();
    initPdf();
  }

  initPdf() async {
    String filename = url.substring(url.lastIndexOf("/") + 1);
    String dir = (await getApplicationDocumentsDirectory()).path;
    filePath = '$dir/$filename';
    if (await File(filePath).exists()) {
      getFileFromLocal();
    } else {
      await InternetAddress.lookup("www.google.com").then((value) {
        getFileFromUrl(url);
      }).catchError((e){
        setState(() {
          error = "No internet connection";
        });
      });
    }
  }

  Future downloadPdf() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Loading..."),
            CircularProgressIndicator(),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (await File(filePath).exists()){
      Navigator.pop(context);
      return null;
    }

    try {
      File file = new File(filePath);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      getFileFromLocal();
    } on SocketException catch (e) {
      setState(() {
        error = "No internet connection";
      });
    } catch (e) {
      setState(() {
        error = "An error occured";
      });
    }
    Navigator.pop(context);
  }

  getFileFromUrl(String url) async {
    try {
      PDFDocument doc = await PDFDocument.fromURL(url);
      setState(() {
        pdfFile = doc;
        load = true;
        online = true;
      });
    } on SocketException catch (e) {
      setState(() {
        error = "No internet connection";
      });
    } catch (e) {
      setState(() {
        error = "An error occured";
      });
    }
  }

  getFileFromLocal() async {
    var s = "/data/user/0/com.mobile.allaw/app_flutter/enda.pdf";
    print(s);
    var temp = await PDFDocument.fromFile(File(s));
    setState(() {
      offlinePdfFile = temp;
      load = true;
      online = false;
    });
  }

  deleteLocalPdf() async {
    var file = File(filePath);
    file.delete();
    getFileFromUrl(url);
  }

  Future<bool> pls() async {
    return await File(filePath).exists();
  }

  @override
  Widget build(BuildContext context) {

    if(pdfFile != null)
      print("online = " + pdfFile.count.toString());
    if(offlinePdfFile != null)
      print(offlinePdfFile.count);

    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [

              Container(
                color: Colors.grey,
                height: ScreenUtil().setHeight(50),
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
                            color: Colors.black
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
                            color: Colors.white,
                          ),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          pls().then((value) {
                            setState(() {
                              online = !value;
                            });
                          });
                        },
                        child: Text(online.toString()),
                      ),

                      GestureDetector(
                        onTap: () {
                          downloadPdf();
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
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.download_sharp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          getFileFromLocal();
                          //deleteLocalPdf();
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
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              (load)?Expanded(
                child: (online)?PDFViewer(
                  document: pdfFile,
                  //scrollDirection: Axis.vertical,
                  controller: pageCon,
                  lazyLoad: online,
                  showPicker: false,
                  navigationBuilder: (context, pageNumber, totalPages, jumpToPage, animateToPage) {
                    int x = pageNumber;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black,
                        ),
                        color: Colors.white
                      ),
                      height: ScreenUtil().setHeight(50),
                      child: Slider(
                        value: x.toDouble(),
                        min: 0,
                        max: totalPages.toDouble(),
                        activeColor: Colors.black54,
                        onChanged: (value) {
                          jumpToPage(page: value.toInt());
                        },
                      ),
                    );
                  },
                ):PDFViewer(
                  document: offlinePdfFile,
                  //scrollDirection: Axis.vertical,
                  controller: pageCon,
                  lazyLoad: online,
                  showPicker: false,
                  navigationBuilder: (context, pageNumber, totalPages, jumpToPage, animateToPage) {
                    int x = pageNumber;
                    return Container(
                      decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.black,
                              ),
                              color: Colors.white
                      ),
                      height: ScreenUtil().setHeight(50),
                      child: Slider(
                        value: x.toDouble(),
                        min: 0,
                        max: totalPages.toDouble(),
                        activeColor: Colors.black54,
                        onChanged: (value) {
                          jumpToPage(page: value.toInt());
                        },
                      ),
                    );
                  },
                )
              ):Expanded(
                child: Center(
                  child: (error=="")?CircularProgressIndicator():Text(error),
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
