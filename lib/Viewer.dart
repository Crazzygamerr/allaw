import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:share/share.dart';
import 'package:excel/excel.dart';

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
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  List<String> chapter = [];
  List<String> heading = [];
  List<String> section = [];
  List<int> page = [];
  List<bool> sub = [];

  initState() {
    url = widget.url;
    super.initState();
    initPdf();
  }

  initPdf() async {
    String filename = url.substring(url.lastIndexOf("/") + 1);
    String dir = (await getApplicationDocumentsDirectory()).path;
    filePath = '$dir/$filename';
    downloadFileExample();
    xlsxFromUrl();
    /*if (await File(filePath).exists()) {
      getFileFromLocal();
    } else {
      await InternetAddress.lookup("www.google.com").then((value) {
        getFileFromUrl(url);
      }).catchError((e){
        setState(() {
          error = "No internet connection";
        });
      });
    }*/
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
        error = e.message;
      });
    }
  }

  Future<void> downloadFileExample() async {
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    Directory appDocDir = await getApplicationDocumentsDirectory();

    var res = await storage.ref().listAll();
    File downloadToFile = File('${appDocDir.path}/${res.items[0].name}');

    storage.ref(res.items[0].fullPath).writeToFile(downloadToFile);

    PDFDocument doc = await PDFDocument.fromFile(downloadToFile);
    setState(() {
      pdfFile = doc;
      load = true;
      online = true;
    });
  }

  getFileFromLocal() async {
    var s = "/data/user/0/com.lexliaise.allaw/app_flutter/enda.pdf";
    print(s);
    var temp = await PDFDocument.fromFile(File(s));
    setState(() {
      offlinePdfFile = temp;
      load = true;
      online = false;
    });
  }

  Future<void> readXlsx() async {

    /*ByteData data = await rootBundle.load("assets/test.xlsx");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    //print(excel.tables["Sheet1"].rows);
    Sheet sheet = excel.tables["Sheet1"];
    for(var x in sheet.rows){
      String a = x[0].toString().trim();
      double b = x[1].toInt();
      bool c = (x[2] != null)?x[2]:false;
      if(a != null && b != null && c != null){
        heading.add(a);
        page.add(b);
        sub.add(c);
      }
    }*/

  }

  Future<void> xlsxFromUrl() async {
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
    Directory appDocDir = await getApplicationDocumentsDirectory();

    var res = await storage.ref().listAll();
    File downloadToFile = File('${appDocDir.path}/${res.items[0].name}');

    await storage.ref(res.items[1].fullPath).writeToFile(downloadToFile);

    List<int> bytes = await downloadToFile.readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    print(excel.tables["Sheet1"].rows);
    Sheet sheet = excel.tables["Sheet1"];
    for(var x in sheet.rows){
      String a = x[0].toString().trim();
      String b = x[1].toString();
      String c = x[2].toString();
      int d = x[3].toInt();
      bool e = (x[4] != null)?true:false;
      if(d != null){
        chapter.add(a);
        heading.add(b);
        section.add(c);
        page.add(d);
        sub.add(e);
      }
    }
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
      key: _drawerKey,
      backgroundColor: Color(0xffF2F2F2),
      drawerEnableOpenDragGesture: false,
      drawer: SafeArea(
        child: Container(
          color: Color(0xffF2F2F2),
          width: ScreenUtil().setWidth(350),
          padding: EdgeInsets.fromLTRB(
            ScreenUtil().setWidth(0),
            ScreenUtil().setHeight(10),
            ScreenUtil().setWidth(0),
            ScreenUtil().setHeight(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(10),
                ),
                child: Text(
                  "Table of contents:",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(25)
                  ),
                ),
              ),

              Container(
                height: ScreenUtil().setHeight(750),
                child: ListView.builder(
                  itemCount: heading.length,
                  itemBuilder: (context, index) {

                    var tp = TextPainter(
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                      //maxLines: null,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp((sub[index])?10:15),
                        ),
                        text: heading[index],
                      ),
                    );
                    tp.layout(maxWidth: ScreenUtil().setWidth((sub[index])?165:175),);

                    return GestureDetector(
                      onTap: () {
                        pageCon.jumpToPage(page[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: ScreenUtil().setWidth(330),
                        color: (index%2 == 0)?Colors.grey:Colors.transparent,
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.s,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            (sub[index]) ? Container(
                              width: ScreenUtil().setWidth(25),
                            ) : Container(),

                            Container(
                              width: ScreenUtil().setWidth((sub[index])?75:100),
                              alignment: Alignment.centerLeft,
                              //color: Colors.blue,
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setHeight(10),
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setHeight(10),
                              ),
                              child: Text(
                                chapter[index] + " - ",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp((sub[index])?10:15),
                                ),
                              ),
                            ),

                            Container(
                              width: ScreenUtil().setWidth(165),
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setHeight(10),
                                ScreenUtil().setWidth(0),
                                ScreenUtil().setHeight(10),
                              ),
                              //height: ScreenUtil().setHeight((sub[index])?15:20),
                              //color: Colors.green,
                              child: Text(
                                heading[index],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp((sub[index])?10:15)
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(
                                height: tp.height + ScreenUtil().setHeight(22),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: Colors.transparent),
                                          bottom: BorderSide(color: Colors.transparent),
                                          left: BorderSide(color: Colors.black),
                                          right: BorderSide(color: Colors.black),
                                        )
                                ),
                                child: Text(
                                  section[index],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp((sub[index])?10:15),
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: ScreenUtil().setWidth(40),
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(10),
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(10),
                              ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
                        onTap: () {
                          _drawerKey.currentState.openDrawer();
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
                            Icons.menu,
                            color: Colors.black,
                          ),
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
                          Share.shareFiles([filePath]);
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
                            Icons.open_in_new,
                            color: Colors.black,
                          ),
                        ),
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
                          //getFileFromLocal();
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
