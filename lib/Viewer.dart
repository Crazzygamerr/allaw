import 'dart:io';

import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share/share.dart';
import 'package:excel/excel.dart';

class Viewer extends StatefulWidget {

  final Reference pdfReference, xlsxReference;
  final bool local;
  final String fileName;

  @override
  _ViewerState createState() => _ViewerState();

  Viewer({this.pdfReference, this.xlsxReference, this.local, this.fileName});
}

class _ViewerState extends State<Viewer> {

  PDFDocument pdfDocument;
  PageController pageCon = new PageController();

  bool load = false, online = true;
  String error = "", dir = "", fileName = "";
  double headingH = 0, subH = 0;

  Reference pdfRef, xlsxRef;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  List<String> chapter = [];
  List<String> heading = [];
  List<String> section = [];
  List<int> page = [];
  List<bool> sub = [];

  initState() {
    super.initState();
    initPdf();
  }

  initPdf() async {
    dir = (await getApplicationDocumentsDirectory()).path;
    if(!widget.local) {
      pdfRef = widget.pdfReference;
      xlsxRef = widget.xlsxReference;
      fileName = pdfRef.name.replaceAll(".pdf", "");
      if (await File('$dir/${pdfRef.name}').exists()) {
        getFileFromLocal();
      } else {
        await InternetAddress.lookup("www.google.com").then((value) {
          getFileFromCloud();
          xlsxFromCloud();
        }).catchError((e){
          setState(() {
            error = "No internet connection";
          });
        });
      }
    } else {
      fileName = widget.fileName;
      getFileFromLocal();
    }



  }

  downloadFiles() async {
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

    try {
      File pdfFile = new File(dir + "/" + pdfRef.name);
      File xlsxFile = new File(dir + "/" + xlsxRef.name);
      FirebaseStorage storage = FirebaseStorage.instance;

      await storage.ref(pdfRef.fullPath).writeToFile(pdfFile);
      await storage.ref(xlsxRef.fullPath).writeToFile(xlsxFile);

      getFileFromLocal();
    } on SocketException catch (e) {
      setState(() {
        load = false;
        error = "No internet connection";
      });
    } catch (e) {
      setState(() {
        load = false;
        error = "An error occured";
      });
    }
    Navigator.pop(context);
  }

  Future<void> getFileFromCloud() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String url = await storage.ref(pdfRef.fullPath).getDownloadURL();
    PDFDocument doc = await PDFDocument.fromURL(url);

    setState(() {
      pdfDocument = doc;
      load = true;
      online = true;
    });
  }

  getFileFromLocal() async {
    File xlsxFile = File(dir + '/' +  fileName + ".xlsx");
    List<int> bytes = await xlsxFile.readAsBytes();

    var excel = Excel.decodeBytes(bytes);
    Sheet sheet = excel.tables["Sheet1"];
    readXlsx(sheet);

    var temp = await PDFDocument.fromFile(File(dir + '/' + fileName + ".pdf"));
    setState(() {
      pdfDocument = temp;
      load = true;
      online = false;
    });
  }

  Future<void> xlsxFromCloud() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    File downloadToFile = File('$dir/${xlsxRef.name}');
    await storage.ref(xlsxRef.fullPath).writeToFile(downloadToFile);
    List<int> bytes = downloadToFile.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    Sheet sheet = excel.tables["Sheet1"];
    readXlsx(sheet);
  }

  Future<void> readXlsx(Sheet sheet) async {

    chapter = [];heading = [];section = [];page = [];sub = [];

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

      var tp = TextPainter(
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        //maxLines: null,
        text: TextSpan(
          style: TextStyle(
            fontSize: ScreenUtil().setSp((e)?10:15),
          ),
          text: b,
        ),
      );
      tp.layout(maxWidth: ScreenUtil().setWidth(e?165:175),);
      if(e) {
        subH = (ScreenUtil().setHeight(tp.height + 25)> subH) ? ScreenUtil().setHeight(tp.height + 25): subH;
      } else {
        headingH = (ScreenUtil().setHeight(tp.height + 25)> headingH) ? ScreenUtil().setHeight(tp.height + 25): headingH;
      }
    }
    setState(() {
    });
  }

  deleteLocalPdf() async {
    File pdfFile = File('$dir/$fileName}.pdf');
    File xlsxFile = File('$dir/$fileName}.xlsx');

    await pdfFile.delete();
    await xlsxFile.delete();

    getFileFromCloud();
    xlsxFromCloud();
  }

  Future<bool> pls() async {
    bool b = await File('$dir/$fileName}.pdf').exists();
    return b;
  }

  @override
  Widget build(BuildContext context) {

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

              GestureDetector(
                onTap: () {
                  pls();
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(10),
                    ScreenUtil().setHeight(0),
                    ScreenUtil().setWidth(0),
                    ScreenUtil().setHeight(10),
                  ),
                  child: Text(
                    fileName,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20)
                    ),
                  ),
                ),
              ),

              Column(
                children: [

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.transparent),
                        bottom: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.transparent),
                        right: BorderSide(color: Colors.transparent),
                      ),
                      color: Colors.grey,
                    ),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.s,
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Container(
                          width: ScreenUtil().setWidth(97),
                          //color: Colors.blue,
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(0),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setWidth(0),
                            ScreenUtil().setHeight(10),
                          ),
                          child: Text(
                            "Chapter no.",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(15),
                            ),
                          ),
                        ),

                        Container(
                          width: ScreenUtil().setWidth(165),
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(0),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setWidth(0),
                            ScreenUtil().setHeight(10),
                          ),
                          //height: ScreenUtil().setHeight((sub[index])?15:20),
                          //color: Colors.green,
                          child: Text(
                            "Title",
                            style: TextStyle(
                                    fontSize: ScreenUtil().setSp(15)
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(2),
                            ScreenUtil().setHeight(0),
                            ScreenUtil().setWidth(0),
                            ScreenUtil().setHeight(0),
                          ),
                          child: Text(
                            "Section",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(10),
                            ),
                          ),
                        ),

                        Container(
                          width: ScreenUtil().setWidth(44),
                          padding: EdgeInsets.fromLTRB(
                            ScreenUtil().setWidth(14),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setWidth(5),
                            ScreenUtil().setHeight(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Page no.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(10),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  ListView.builder(
                    itemCount: heading.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {

                      return GestureDetector(
                        onTap: () {
                          pageCon.jumpToPage(page[index]);
                          Navigator.pop(context);
                        },
                        child: Stack(
                          children: [

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(97),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(1),
                                  height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(167),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(1),
                                  height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(43),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(1),
                                  height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                  color: Colors.black,
                                ),
                              ],
                            ),

                            Container(
                              width: ScreenUtil().setWidth(350),
                              height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.transparent),
                                  bottom: BorderSide(color: Colors.black),
                                  left: BorderSide(color: Colors.transparent),
                                  right: BorderSide(color: Colors.transparent),
                                ),
                              ),
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
                                      chapter[index].toString() + " - ",
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
                                      heading[index].toString(),
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp((sub[index])?10:15)
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      //height: ScreenUtil().setHeight(22),
                                      alignment: Alignment.center,
                                      child: Text(
                                        section[index].toString(),
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
                          ],
                        ),
                      );
                    },
                  ),
                ],
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
                          Share.shareFiles(['$dir/$fileName}.pdf']);
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
                          downloadFiles();
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
                          deleteLocalPdf();
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
                child: PDFViewer(
                  document: pdfDocument,
                  //scrollDirection: Axis.vertical,
                  controller: pageCon,
                  lazyLoad: false,
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
