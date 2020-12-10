import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class Viewer extends StatefulWidget {

  final String url, filePath;

  @override
  _ViewerState createState() => _ViewerState();

  Viewer({this.url, this.filePath});
}

class _ViewerState extends State<Viewer> {

  PDFDocument pdfFile;
  PageController pageCon = new PageController();
  bool load = false;
  String url = "";

  initState() {
    url = widget.url;
    super.initState();
    getFileFromUrl(url).then((value) {
      setState(() {
        pdfFile = value;
        load = true;
      });
    });

  }

  Future<PDFDocument> getFileFromUrl(String url) async {

    PDFDocument doc = await PDFDocument.fromURL(url);
    return doc;

  }

  Future downloadPdf() async {

    String filename = url.substring(url.lastIndexOf("/") + 1);
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(filename);
    print(dir);
    if (await File('$dir/$filename').exists())
      return null;

    File file = new File("$dir/$filename");
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    await file.writeAsBytes(bytes);

  }

  /*fromLocal() async {
    var temp = await PDFDocument.fromFile(File("/data/user/0/com.mobile.allaw/app_flutter/quiz1ans.pdf"));
    setState(() {
      pdfFile = temp;
      load = true;
    });
  }*/

  deleteLocal() async {
    var file = File("/data/user/0/com.mobile.allaw/app_flutter/quiz1ans.pdf");
    file.delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("New doc"),
        actions: [
          GestureDetector(
            onTap: () {
              downloadPdf();
            },
            child: Container(
              width: ScreenUtil().setWidth(60),
              color: Colors.white,
              child: Icon(
                Icons.download_sharp,
                color: Colors.black,
              ),
            ),
          ),
          /*GestureDetector(
            onTap: () {
              fromLocal();
            },
            child: Container(
              width: ScreenUtil().setWidth(40),
              color: Colors.white,
              child: Icon(
                Icons.refresh,
                color: Colors.black,
              ),
            ),
          ),*/
          GestureDetector(
            onTap: () {
              deleteLocal();
            },
            child: Container(
              width: ScreenUtil().setWidth(60),
              color: Colors.white,
              child: Icon(
                Icons.delete,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: load?PDFViewer(
          document: pdfFile,
          //scrollDirection: Axis.vertical,
          controller: pageCon,
        ):Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
