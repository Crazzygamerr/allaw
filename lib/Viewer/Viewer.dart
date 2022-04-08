import 'dart:async';
import 'dart:io';

import 'package:allaw/global/widgets/LoadingDialog.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
class Viewer extends StatefulWidget {
  
  final Reference? pdfReference, xlsxReference;
  final String? fileName;

  @override
  _ViewerState createState() => _ViewerState();

  Viewer({
    this.pdfReference,
    this.xlsxReference,
    this.fileName
  }):assert(fileName != null || (pdfReference != null && xlsxReference != null));
}

class _ViewerState extends State<Viewer> with SingleTickerProviderStateMixin{

  PageController pageCon = new PageController(keepPage: true);
  final Completer<PDFViewController> pdfViewController = Completer<PDFViewController>();
  int currentPage = 0, totalPage = 0;
  
  late File file;
  String url = "";

  bool local = false, 
    load = false,
    online = true,
    drawing = false;

  String error = "",
      dir = "",
      fileName = "",
      imgPath = "", s = "";

  double headingH = 0, subH = 0;

  late Reference pdfRef, xlsxRef;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  List<String> heading = [];
  List<String> section = [];
  List<int> page = [];
  List<bool> sub = [], minimized = [];

  List<List<Map<String, dynamic>>> strokes = [[]];
  Color strokeColor = Colors.black;
  int strokeWidth = 2;
  double strokeOpacity = 0.5;

  static List<int> colorOptions = [
    Colors.limeAccent.value,
    Colors.lightGreenAccent.value,
    Colors.lightBlueAccent.value,
    Colors.pinkAccent.value,
    Colors.black.value,
  ];

  final List<DropdownMenuItem<int>> dropDownItems = List.generate(
    colorOptions.length,
        (index) {
      return DropdownMenuItem(
        value: colorOptions[index],
        child: Container(
          height: ScreenUtil().setHeight(30),
          width: ScreenUtil().setWidth(30),
          decoration: BoxDecoration(
            color: Color(colorOptions[index]),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      );
    },
  );

  initState() {
    super.initState();
    initPdf();
    showLoading();
  }

  showLoading() async {
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      showLoadingDialog(context);
    });
  }

  initPdf() async {
    dir = (await getApplicationDocumentsDirectory()).path;
    local = await File(dir + "/" + (widget.fileName ?? "") + ".pdf").exists();
    if(!local) {
      pdfRef = widget.pdfReference!;
      xlsxRef = widget.xlsxReference!;
      fileName = pdfRef.name.replaceAll(".pdf", "");
      if (await File('$dir/${pdfRef.name}').exists()) {
        getFileFromLocal();
      } else {
        await InternetAddress.lookup("www.google.com").then((value) {
          getFileFromCloud();
          xlsxFromCloud();
        }).catchError((e){
          setState(() {
            load = false;
            error = "No internet connection";
          });
        });
      }
    } else {
      fileName = widget.fileName!;
      getFileFromLocal();
    }

  }

  downloadFiles() async {
    showLoadingDialog(context);

    try {
      File pdfFile = new File(dir + "/" + pdfRef.name);
      File xlsxFile = new File(dir + "/" + xlsxRef.name);
      FirebaseStorage storage = FirebaseStorage.instance;

      await storage.ref(pdfRef.fullPath).writeToFile(pdfFile);
      await storage.ref(xlsxRef.fullPath).writeToFile(xlsxFile);

      getFileFromLocal();
    } on SocketException {
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
  }

  Future<void> getFileFromCloud() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    url = await storage.ref(pdfRef.fullPath).getDownloadURL();
    setState(() {
      load = true;
      online = true;
    });
    Navigator.pop(context);
  }

  getFileFromLocal() async {
    File xlsxFile = File(dir + '/' +  fileName + ".xlsx");
    List<int> bytes = await xlsxFile.readAsBytes();

    var excel = Excel.decodeBytes(bytes);
    Sheet? sheet = excel.tables[excel.tables.keys.toList()[0]];
    readXlsx(sheet!);
    setState(() {
      load = true;
      online = false;
    }); 
    Navigator.pop(context);
  }

  Future<void> xlsxFromCloud() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    File downloadToFile = File('$dir/${xlsxRef.name}');
    await storage.ref(xlsxRef.fullPath).writeToFile(downloadToFile);
    List<int> bytes = downloadToFile.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    Sheet? sheet = excel.tables[excel.tables.keys.toList()[0]];
    readXlsx(sheet!);
  }

  Future<void> readXlsx(Sheet sheet) async {

    heading = [];section = [];page = [];sub = [];minimized = [];
    for(int i=0;i<sheet.rows.length;i++){
      var x = sheet.rows[i];
      String a = x[0].toString();
      String b = (x[1] != null)?x[1].toString():"";
      int c = x[2]?.value.toInt();
      bool d;
      if(x.length > 3) {
        d = (x[3] != null) ? true : false;
      } else
        d = false;
        heading.add(a);
        if(b.lastIndexOf(".") != -1)
          b = b.substring(0, b.lastIndexOf("."));
        section.add(b);
        page.add(c);
        sub.add(d);

      var tp = TextPainter(
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: TextStyle(
            fontSize: ScreenUtil().setSp((d)?12:15),
          ),
          text: a,
        ),
      );
      if(d)
        tp.layout(maxWidth: ScreenUtil().setWidth(160),);
      else if(i == sheet.rows.length-1)
        tp.layout(maxWidth: ScreenUtil().setWidth(150,),);
      else if(sheet.rows[i+1].length > 3)
        tp.layout(maxWidth: ScreenUtil().setWidth(100,),);
      else
        tp.layout(maxWidth: ScreenUtil().setWidth(150,),);
      if(d) {
        subH = (tp.height + 20> subH) ? tp.height + 20: subH;
      } else {
        headingH = (tp.height + 20> headingH) ? tp.height + 20: headingH;
      }
    }
    for(int i=0;i<sub.length;i++){
      if(sub[i]) {
        minimized.add(true);
      } else{
        if(i == sub.length-1)
          minimized.add(false);
        else if(sub[i+1])
          minimized.add(true);
        else
          minimized.add(false);
      }
    }
    setState(() {
    });
  }

  deleteLocalPdf() async {
    File pdfFile = File('$dir/$fileName.pdf');
    File xlsxFile = File('$dir/$fileName.xlsx');

    await pdfFile.delete();
    await xlsxFile.delete();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
          if(_drawerKey.currentState?.mounted ?? true)
            Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Color(0xffF2F2F2),
        drawerEnableOpenDragGesture: false,
        drawer: SafeArea(
          child: Container(
            color: Color(0xffF2F2F2),
            width: ScreenUtil().setWidth(375),
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(0),
              ScreenUtil().setHeight(10),
              ScreenUtil().setWidth(0),
              ScreenUtil().setHeight(0),
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
                    fileName,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                    ),
                  ),
                ),

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
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(2),
                          ScreenUtil().setHeight(0),
                          ScreenUtil().setWidth(2),
                          ScreenUtil().setHeight(0),
                        ),
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
                        padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(5),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setWidth(0),
                          ScreenUtil().setHeight(10),
                        ),
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
                            pageCon.jumpToPage(page[index]-1);
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
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.transparent),
                                    bottom: BorderSide(color: Colors.black),
                                    left: BorderSide(color: Colors.transparent),
                                    right: BorderSide(color: Colors.transparent),
                                  ),
                                ),
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
                                      padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(10),
                                        ScreenUtil().setHeight(5),
                                        ScreenUtil().setWidth(10),
                                        ScreenUtil().setHeight(5),
                                      ),
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
                                        setState(() {
                                        });
                                      },
                                      child: Container(
                                        height: ScreenUtil().setHeight((sub[index])?subH:headingH),
                                        width: ScreenUtil().setWidth(50),
                                        padding: EdgeInsets.fromLTRB(
                                          ScreenUtil().setWidth(10),
                                          ScreenUtil().setHeight(10),
                                          ScreenUtil().setWidth(10),
                                          ScreenUtil().setHeight(10),
                                        ),
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
                                      padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(5),
                                        ScreenUtil().setWidth(0),
                                        ScreenUtil().setHeight(5),
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
                    padding: EdgeInsets.fromLTRB(
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(0),
                      ScreenUtil().setWidth(0),
                      ScreenUtil().setHeight(0),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1,
                          color: Colors.black
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        if(drawing) Container(
                        ) else GestureDetector(
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
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(8),
                              ScreenUtil().setHeight(8),
                              ScreenUtil().setWidth(8),
                              ScreenUtil().setHeight(8),
                            ),
                            child: Image.asset(
                              "assets/navigate_before.png",
                            ),
                          ),
                        ),

                        if(drawing) Container(
                        ) else GestureDetector(
                          onTap: () {
                            _drawerKey.currentState?.openDrawer();
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(10),
                              ScreenUtil().setHeight(0),
                              ScreenUtil().setWidth(10),
                              ScreenUtil().setHeight(0),
                            ),
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
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(8),
                                ScreenUtil().setHeight(8),
                                ScreenUtil().setWidth(8),
                                ScreenUtil().setHeight(8),
                              ),
                              child: Image.asset(
                                "assets/list.png",
                              ),/*Icon(
                                Icons.list,
                                size: 27,
                              ),*/
                            ),
                          ),
                        ),

                        if(drawing) Container(
                          width: ScreenUtil().setWidth(220),
                        ),

                        (drawing)?GestureDetector(
                          onTap: () {
                            setState(() {
                              /* if(strokes.isNotEmpty) {
                                strokes[canvasCon.page!.toInt()].removeLast();
                                writeJson();
                              } */
                            });
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
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(8),
                              ScreenUtil().setHeight(8),
                              ScreenUtil().setWidth(8),
                              ScreenUtil().setHeight(8),
                            ),
                            child: Image.asset(
                              "assets/undo.png",
                              color: Colors.black,
                            ),
                          ),
                        ):Container(),

                        if(drawing) Container(
                        ) else SizedBox(
                          width: ScreenUtil().setWidth((online)?150:90),
                        ),

                        if (online) Container(
                        ) else GestureDetector(
                          onTap: () {
                            setState(() {
                              drawing = !drawing;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(10),
                              ScreenUtil().setHeight(0),
                              ScreenUtil().setWidth(0),
                              ScreenUtil().setHeight(0),
                            ),
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
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(8),
                                ScreenUtil().setHeight(8),
                                ScreenUtil().setWidth(8),
                                ScreenUtil().setHeight(8),
                              ),
                              child: Image.asset(
                                (drawing)?"assets/exit_to_app.png":"assets/border_color.png",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        if (online || !drawing) Container(
                        ) else GestureDetector(
                          onTap: () {
                            /* strokes = [];
                            func3(); */
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(10),
                              ScreenUtil().setHeight(0),
                              ScreenUtil().setWidth(0),
                              ScreenUtil().setHeight(0),
                            ),
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
                              padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(8),
                                ScreenUtil().setHeight(8),
                                ScreenUtil().setWidth(8),
                                ScreenUtil().setHeight(8),
                              ),
                              child: Image.asset(
                                "assets/clear.png",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        if(drawing) Container(
                        ) else GestureDetector(
                          onTap: () {
                            if(online)
                              downloadFiles();
                            else
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
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(8),
                              ScreenUtil().setHeight(8),
                              ScreenUtil().setWidth(8),
                              ScreenUtil().setHeight(8),
                            ),
                            child: Image.asset(
                              (online)?"assets/get_app.png":"assets/delete_forever.png",
                              color: Colors.black,
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ),
                
                /* GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      test = true;
                      strokes[0].add({
                        "color": strokeColor.value,
                        "width": strokeWidth,
                        "opacity": strokeOpacity,
                        "offsets": [details.globalPosition]
                      });
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      strokes[0]    //List of strokes in the page
                      [strokes[0].length - 1]   //The current stroke
                      ["offsets"]      //The offsets in the current stroke
                          .add(details.globalPosition);
                    });
                  },
                  onPanEnd: (details) {
                    //PdfDocument document = PdfDocument(inputBytes: File("/data/user/0/com.lexliaise.allaw/app_flutter/The Indian Contract Act, 1872.pdf").readAsBytesSync());
                    setState(() {
                      test = false;
                      List<Offset> offsets = strokes[0]
                      [strokes[0].length - 1]
                      ["offsets"];
/*             final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
                        [0, 0, 500, 500], 'Introduction',
                        color: PdfColor(255, 0, 0),
                        author: 'John Milton',
                        border: PdfAnnotationBorder(2),
                        lineCaption: false,
                        setAppearance: true,
                        lineIntent: PdfLineIntent.lineDimension);
                      document.pages[0].annotations.add(lineAnnotation); */
                      
                      /* for(int i=0;i<offsets.length-1;i++) {
                        PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
                          [
                            (offsets[i].dx.toInt()), 
                            document.pages[0].size.height.toInt() - offsets[i].dy.toInt(), 
                            offsets[i+1].dx.toInt(), 
                            document.pages[0].size.height.toInt() - offsets[i+1].dy.toInt()
                          ], 
                          "line annotation",
                          opacity: 0.1,
                          border: PdfAnnotationBorder(0),
                          innerColor: PdfColor(255, 0, 0),
                          color: PdfColor(0, 0, 255),
                          setAppearance: true,
                        );
                        //lineAnnotation.
                        document.pages[2].annotations.add(lineAnnotation);
                      } */
                      /* PdfRectangleAnnotation rectangleAnnotation = PdfRectangleAnnotation(
                          Rect.fromPoints(offsets.first, offsets.last),
                          "line annotation",
                          opacity: 0.1,
                          border: PdfAnnotationBorder(0),
                          innerColor: PdfColor(255, 0, 0),
                          color: PdfColor(0, 0, 255),
                          setAppearance: true,
                        );
                        document.pages[4].annotations.add(rectangleAnnotation); */
                        
                      /* PdfPath path = PdfPath();
                      path.pen = PdfPen(
                        PdfColor(0, 0, 250),
                        width: 5, 
                        );
                      path.addPath(
                        //strokes[0][strokes[0].length - 1]["offsets"],
                        [Offset(10, 700), Offset(10, 500), Offset(10, 700), Offset(10, 500)],
                        //List.generate(strokes[0][strokes[0].length - 1]["offsets"].length, (index) => 1)
                        [0, 1, 3, 129],
                      );
                      document.pages[1].graphics.drawPath(
                        path,
                        pen: PdfPen(PdfColor(165, 0, 0, 50), width: 5),
                        );              
                      path.draw(
                        page: document.pages[1], 
                        bounds: Rect.fromLTRB(400, 400, 800, 800));
                      path.addLine(Offset(10, 700), Offset(10, 500));
                      path.addLine(Offset(10, 100), Offset(100, 200));
                      path.addLine(Offset(100, 200), Offset(55, 150));
                      document.pages[0].graphics.drawPath(path);
                      document.pages[0].graphics.drawLine(
                        PdfPen(PdfColor(165, 0, 0, 50), width: 5),
                        Offset(500, 100),
                        Offset(300, 200));
                         */

                      /* File("/data/user/0/com.lexliaise.allaw/app_flutter/The Indian Contract Act, 1872.pdf")
                          .writeAsBytes(document.save(), flush: true);
                      document.dispose(); */
                    });
                    //writeJson();

                  },
                  child: Container(
                  height: ScreenUtil().setHeight(100),
                    color: Colors.red,
                  ),
                ), */
                
                (load)?(local)?Expanded(
                  child: PDF(   
                    enableSwipe: true,
                    swipeHorizontal: true,        
                    onViewCreated: (PDFViewController pdfViewCon) async {
                      pdfViewController.complete(pdfViewCon);
                      currentPage = await pdfViewCon.getCurrentPage() ?? 0;
                      totalPage = await pdfViewCon.getPageCount() ?? 0;
                      setState(() {});
                    },
                  ).fromPath('$dir/$fileName.pdf'),
                ):Expanded(
                  child: PDF(
                    enableSwipe: true,
                    swipeHorizontal: true,        
                    onViewCreated: (PDFViewController pdfViewCon) async {
                      pdfViewController.complete(pdfViewCon);
                      currentPage = await pdfViewCon.getCurrentPage() ?? 0;
                      totalPage = await pdfViewCon.getPageCount() ?? 0;
                      setState(() {});
                    },
                  ).fromUrl(url),
                ):Center(
                  child: CircularProgressIndicator(),
                ),
                
                FutureBuilder<PDFViewController>(
                  future: pdfViewController.future,
                  builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                    if(snapshot.hasData && snapshot.data != null) {
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
                          value: currentPage.toDouble(),
                          min: 0,
                          max: totalPage.toDouble(),
                          activeColor: Colors.black54,
                          onChangeEnd: (value) async {
                            await snapshot.data?.setPage(value.toInt());
                            currentPage = await snapshot.data?.getCurrentPage() ?? 0;
                            setState(() {});
                          },
                          onChanged: (value) async {
                            await snapshot.data?.setPage(value.toInt());
                            currentPage = await snapshot.data?.getCurrentPage() ?? 0;
                            setState(() {});
                          },
                        ),
                      );
                    } else {
                      return Container(
                        height: ScreenUtil().setHeight(50),
                      );
                    }
                  }
                ),
                // (load)?Stack(
/*           								children: [
                    PDFViewer(
                      key: _canvasKey,
                      document: pdfDocument,
                      //scrollDirection: Axis.vertical,
                      controller: pageCon,
                      lazyLoad: false,
                      showPicker: false,
                      maxScale: 1.0,
                      onPageChanged: (i){},
                      navigationBuilder: (context, pageNumber, totalPages, jumpToPage, animateToPage) {
                        int x = pageNumber!;
                        if (drawing) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black,
                                ),
                                color: Colors.white
                            ),
                            height: ScreenUtil().setHeight(50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    ScreenUtil().setWidth(20),
                                    ScreenUtil().setHeight(10),
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10),
                                  ),
                                  child: DropdownButton<int>(
                                    value: strokeColor.value,
                                    iconSize: 24,
                                    elevation: 16,
                                    underline: Container(
                                      height: 0,
                                      //color: Colors.blue,
                                    ),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        if(newValue != null)
                                          strokeColor = Color(newValue);
                                        else
                                          strokeColor = Colors.black;
                                      });
                                    },
                                    items: dropDownItems,
                                  ),
                                ),

                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: StatefulBuilder(
                                              builder: (context, snapshot) {
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: (){
                                                              setState(() {
                                                                snapshot(() {
                                                                  strokeWidth = 1;
                                                                });
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                              ),
                                                              child: Container(
                                                                height: ScreenUtil().setHeight(50),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: Colors.grey.withOpacity(0.2),
                                                                ),
                                                                padding: EdgeInsets.fromLTRB(
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                ),
                                                                child: Center(
                                                                  child: Container(
                                                                    height: 1.0,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: (){
                                                              setState(() {
                                                                snapshot(() {
                                                                  strokeWidth = 5;
                                                                });
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                              ),
                                                              child: Container(
                                                                height: ScreenUtil().setHeight(50),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: Colors.grey.withOpacity(0.2),
                                                                ),
                                                                padding: EdgeInsets.fromLTRB(
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                ),
                                                                child: Center(
                                                                  child: Container(
                                                                    height: 5.0,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: (){
                                                              setState(() {
                                                                snapshot(() {
                                                                  strokeWidth = 10;
                                                                });
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                              ),
                                                              child: Container(
                                                                height: ScreenUtil().setHeight(50),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: Colors.grey.withOpacity(0.2),
                                                                ),
                                                                padding: EdgeInsets.fromLTRB(
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                ),
                                                                child: Center(
                                                                  child: Container(
                                                                    height: 10.0,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: (){
                                                              setState(() {
                                                                snapshot(() {
                                                                  strokeWidth = 15;
                                                                });
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets.fromLTRB(
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                                ScreenUtil().setWidth(10),
                                                                ScreenUtil().setHeight(10),
                                                              ),
                                                              child: Container(
                                                                height: ScreenUtil().setHeight(50),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  color: Colors.grey.withOpacity(0.2),
                                                                ),
                                                                padding: EdgeInsets.fromLTRB(
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                  ScreenUtil().setWidth(20),
                                                                  ScreenUtil().setHeight(0),
                                                                ),
                                                                child: Center(
                                                                  child: Container(
                                                                    height: 15.0,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        ScreenUtil().setWidth(10),
                                        ScreenUtil().setHeight(5),
                                        ScreenUtil().setWidth(10),
                                        ScreenUtil().setHeight(5),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                          ScreenUtil().setWidth(20),
                                          ScreenUtil().setHeight(0),
                                          ScreenUtil().setWidth(20),
                                          ScreenUtil().setHeight(0),
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: strokeWidth.toDouble(),
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    ScreenUtil().setWidth(10),
                                    ScreenUtil().setHeight(10),
                                    ScreenUtil().setWidth(20),
                                    ScreenUtil().setHeight(10),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: StatefulBuilder(
                                              builder: (context, snapshot) {
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              snapshot(() {
                                                                strokeOpacity = 0.2;
                                                              });
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(40),
                                                            width: ScreenUtil().setWidth(40),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              snapshot(() {
                                                                strokeOpacity = 0.4;
                                                              });
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(40),
                                                            width: ScreenUtil().setWidth(40),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.4),
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              snapshot(() {
                                                                strokeOpacity = 0.6;
                                                              });
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(40),
                                                            width: ScreenUtil().setWidth(40),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.6),
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              snapshot(() {
                                                                strokeOpacity = 0.8;
                                                              });
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(40),
                                                            width: ScreenUtil().setWidth(40),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(0.8),
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              snapshot(() {
                                                                strokeOpacity = 1;
                                                              });
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            height: ScreenUtil().setHeight(40),
                                                            width: ScreenUtil().setWidth(40),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black.withOpacity(1),
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: ScreenUtil().setHeight(30),
                                      width: ScreenUtil().setWidth(30),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(strokeOpacity),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          );
                        } else {
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
                              max: totalPages!.toDouble(),
                              activeColor: Colors.black54,
                              onChangeEnd: (value) {
                                swipeChangePage = false;
                                jumpToPage(page: value.toInt());
                                canvasCon.jumpToPage(value.toInt());
                                swipeChangePage = true;
                              },
                              onChanged: (value) {
                              },
                            ),
                          );
                        }
                      },
                    ),

                   if(!online) Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: (canvasH == 0)?0:1,
                          child: Container(
                            height: ScreenUtil().setHeight(610),
                            width: ScreenUtil().setWidth(411),
                            child: PageView.builder(
                              itemCount: pdfDocument.count,
                              physics: (drawing)?NeverScrollableScrollPhysics():PageScrollPhysics(),
                              controller: canvasCon,
                              itemBuilder: (context, page) {
                                if(drawing && canvasCon.page == page) {
                                  return Center(
                                    child: GestureDetector(
                                      onPanStart: (details) {
                                        setState(() {
                                          strokes[page].add({
                                            "color": strokeColor.value,
                                            "width": strokeWidth,
                                            "opacity": strokeOpacity,
                                            "offsets": [details.localPosition]
                                          });
                                        });
                                      },
                                      onPanUpdate: (details) {
                                        setState(() {
                                          strokes[page]    //List of strokes in the page
                                          [strokes[page].length - 1]   //The current stroke
                                          ["offsets"]      //The offsets in the current stroke
                                              .add(details.localPosition); //Add the offset to the stroke
                                        });
                                      },
                                      onPanEnd: (details) {
                                        setState(() {
                                        });
                                        writeJson();
                                      },
                                      child: Container(
                                        height: canvasH,
                                        width: canvasW,
                                        decoration: BoxDecoration(
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: CustomPaint(
                                          painter: (page < strokes.length)?Painter(
                                            strokes: strokes[page],
                                          ):Painter(
                                            strokes: [],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: Container(
                                      height: canvasH,
                                      width: canvasW,
                                      decoration: BoxDecoration(
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      //color: Colors.grey,
                                      child: CustomPaint(
                                        painter: (page < strokes.length)?Painter(
                                          strokes: strokes[page],
                                        ):Painter(
                                          strokes: [],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(45),
                          //color: Colors.red,
                        ),
                      ],
                    ),
                  ], */
/*         ):Expanded(
                  child: Center(
                    child: (error=="")
                        CircularProgressIndicator()
                        :Text(
                      error,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                      ),
                    ),
                  ),
                ), */

                Container(
                  color: Colors.grey,
                  height: ScreenUtil().setHeight(50),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Painter extends CustomPainter {
  final List<Map<String, dynamic>> strokes;

  Painter({
    required this.strokes
  }) : super();


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..isAntiAlias = true
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    //canvas.drawLine(Offset(100,100), Offset(200,200), paint);
      for(int i = 0; i<strokes.length; i++){
        if (strokes[i]["color"] != null) {
          paint.color = Color(strokes[i]["color"]).withOpacity(strokes[i]["opacity"]??1);
        } else {
          paint.color = Colors.black;
        }
        if (strokes[i]["width"] != null) {
          paint.strokeWidth = strokes[i]["width"].toDouble();
        } else {
          paint.strokeWidth = 2;
        }
        if (strokes[i]["color"] == Colors.white.value) {
          paint.blendMode = BlendMode.clear;
          paint.color = Colors.transparent;
        }
        if (strokes[i]["offsets"] != null) {
          for (var j = 1; j<strokes[i]["offsets"].length; j++) {
            //Path path = new Path();
            canvas.drawLine(strokes[i]["offsets"][j-1], strokes[i]["offsets"][j], paint);
            //canvas.
            //canvas.drawPoints(PointMode.polygon, strokes[i]["offsets"], paint);
            //canvas.drawCircle(strokes[i]["offsets"][j-1], strokes[i]["width"].toDouble()/2, paint);
            /*canvas.drawOval(
              Rect.fromCenter(
              center: Offset((strokes[i]["offsets"][j-1].dx + strokes[i]["offsets"][j].dx)/2, (strokes[i]["offsets"][j-1].dy + strokes[i]["offsets"][j].dy)/2),
              width: strokes[i]["width"].toDouble(),
              height: strokes[i]["width"].toDouble()*1.2,
              ),
              paint,
            );*/
            /*path.moveTo(strokes[i]["offsets"][j-1].dx, strokes[i]["offsets"][j-1].dy);
            path.lineTo(strokes[i]["offsets"][j].dx, strokes[i]["offsets"][j].dy);
            canvas.drawPath(path, paint);*/
            /*canvas.drawRect(
              Rect.fromCenter(
                center: Offset((strokes[i]["offsets"][j-1].dx + strokes[i]["offsets"][j].dx)/2, (strokes[i]["offsets"][j-1].dy + strokes[i]["offsets"][j].dy)/2),
                width: strokes[i]["width"].toDouble(),
                height: strokes[i]["width"].toDouble()*1.2,
              ),
              paint,
            );*/
          }
        }
      }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}