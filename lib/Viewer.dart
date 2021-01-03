import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share/share.dart';
import 'package:excel/excel.dart';
import 'package:allaw/advance_pdf_viewer-1.2.1+1/lib/advance_pdf_viewer.dart';

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
    PageController pageCon = new PageController(keepPage: true);
    PageController canvasCon = new PageController();
    File file;

    bool load = false,
            online = true,
            swipeChangePage = true,
            drawing = false,
            zoom = false;

    String error = "",
            dir = "",
            fileName = "",
            imgPath = "", s = "";

    double headingH = 0, subH = 0,
            canvasH = 0, canvasW = 0;

    Reference pdfRef, xlsxRef;

    GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
    GlobalKey _canvasKey = GlobalKey();

    List<String> heading = [];
    List<String> section = [];
    List<int> page = [];
    List<bool> sub = [];

    List<List<Map<String, dynamic>>> strokes = [];
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
        canvasCon.addListener(() => func2());
        initPdf();
        func();
    }

    func() async {
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
            showDialog(
                context: context,
                builder: (_) => WillPopScope(
                    onWillPop: () async {
                        return false;
                    },
                    child: AlertDialog(
                        content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text("Loading..."),
                                CircularProgressIndicator(),
                            ],
                        ),
                    ),
                ),
                barrierDismissible: false,
            );
            func1();
        });
    }

    func1() {
        if(_canvasKey.currentContext == null) {
            Future.delayed(Duration(seconds: 1)).then((value) => func1());
        } else {
            var x = _canvasKey.currentContext.size;
            if((x.height - ScreenUtil().setHeight(50))/x.width > 297/210) {
                setState(() {
                    canvasW = x.width;
                    canvasH = (297/210)*(x.width);
                });
            } else if((x.height - ScreenUtil().setHeight(50))/x.width < 297/210) {
                setState(() {
                    canvasH = (x.height - ScreenUtil().setHeight(50));
                    canvasW = (297/210)*x.width;
                });
            } else {
                setState(() {
                    canvasH = x.height - ScreenUtil().setHeight(50);
                    canvasW = x.width;
                });
            }
            _drawerKey.currentState.openDrawer();
        }
    }

    func2() {
        if(swipeChangePage)
            pageCon.jumpTo(canvasCon.offset);
    }

    func3() {
        if(pdfDocument == null) {
            Future.delayed(Duration(seconds: 1)).then((value) => func3());
        } else {
            for(int i = 0;i<pdfDocument.count;i++){
                strokes.add([]);
            }
            writeJson();
            setState(() {
            });
        }
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
                        load = false;
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
            builder: (_) => WillPopScope(
                onWillPop: () async {
                    return false;
                },
                child: AlertDialog(
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text("Loading..."),
                            CircularProgressIndicator(),
                        ],
                    ),
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
        Navigator.pop(context);
    }

    getFileFromLocal() async {
        File xlsxFile = File(dir + '/' +  fileName + ".xlsx");
        List<int> bytes = await xlsxFile.readAsBytes();

        var excel = Excel.decodeBytes(bytes);
        Sheet sheet = excel.tables[excel.tables.keys.toList()[0]];
        readXlsx(sheet);
        readJson();

        var temp = await PDFDocument.fromFile(File(dir + '/' + fileName + ".pdf"));
        for(int i=0;i<temp.count;i++){
            strokes.add([]);
        }
        setState(() {
            pdfDocument = temp;
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
        //print(excel.tables.keys.toList());
        Sheet sheet = excel.tables[excel.tables.keys.toList()[0]];
        //print(sheet.rows);
        readXlsx(sheet);
    }

    Future<void> readXlsx(Sheet sheet) async {

        heading = [];section = [];page = [];sub = [];
        for(var x in sheet.rows){
            String a = x[0].toString();
            String b = (x[1] != null)?x[1].toString():"";
            int c = x[2].toInt();
            bool d;
            if(x.length > 3) {
                d = (x[3] != null) ? true : false;
            } else
                d = false;
            if(c != null){
                heading.add(a);
                if(b.lastIndexOf(".") != -1)
                    b = b.substring(0, b.lastIndexOf("."));
                section.add(b);
                page.add(c);
                sub.add(d);
            }

            var tp = TextPainter(
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                //maxLines: null,
                text: TextSpan(
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp((d)?10:15),
                    ),
                    text: a,
                ),
            );
            tp.layout(maxWidth: ScreenUtil().setWidth(d?165:175),);
            if(d) {
                subH = (ScreenUtil().setHeight(tp.height + 20)> subH) ? ScreenUtil().setHeight(tp.height + 20): subH;
            } else {
                headingH = (ScreenUtil().setHeight(tp.height + 20)> headingH) ? ScreenUtil().setHeight(tp.height + 20): headingH;
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

    readJson() async {
        if(await File("$dir/annotations.json").exists()) {
            file = new File("$dir/annotations.json");
            Map<String, dynamic> map = jsonDecode(await file.readAsString());
            if(map[fileName] != null) {
                var temp = jsonDecode(file.readAsStringSync());
                if(temp[fileName] != null){
                    for(var page1 in temp[fileName]) {
                        strokes.add([]);
                        for(var stroke in page1) {
                            Map<String, dynamic> tempStroke = {
                                "color": stroke["color"],
                                "width": stroke["width"],
                                "opacity": stroke["opacity"],
                            };
                            List<Offset> coord = [];
                            for(var offset in stroke["offsets"]) {
                                coord.add(Offset(offset[0], offset[1]));
                            }
                            tempStroke["offsets"] = coord;
                            strokes[temp[fileName].indexOf(page1)].add(tempStroke);
                        }
                    }
                }
            } else {
                func3();
            }
        } else {
            file = await File("$dir/annotations.json").create();
            file.writeAsString(
                jsonEncode(
                    {
                        "$fileName": [],
                    },
                ),
            );
            func3();
        }
    }

    writeJson() async {
        List<List<Map<String, dynamic>>> temp = [];
        for(var page in strokes) {
            temp.add([]);
            for(var stroke in page) {
                var tempStroke = {
                    "color": stroke["color"],
                    "width": stroke["width"],
                    "opacity": stroke["opacity"],
                };
                List<List<double>> coord = [];
                for(var offset in stroke["offsets"]) {
                    coord.add([offset.dx, offset.dy]);
                }
                tempStroke["offsets"] = coord;
                temp[strokes.indexOf(page)].add(tempStroke);
            }
        }
        file.writeAsString(jsonEncode({fileName: temp}));
    }

    Future<bool> pls() async {
        bool b = await File('$dir/$fileName.pdf').exists();
        setState(() {
        });
        return b;
    }

    @override
    Widget build(BuildContext context) {

        return WillPopScope(
            onWillPop: () async {
                if(_drawerKey != null)
                    if(_drawerKey.currentState.mounted)
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
                                        fileName,
                                        style: TextStyle(
                                                fontSize: ScreenUtil().setSp(20)
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


                                                    Expanded(
                                                        child: Container(
                                                            //width: ScreenUtil().setWidth(150),
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                                "Title",
                                                                style: TextStyle(
                                                                        fontSize: ScreenUtil().setSp(15)
                                                                ),
                                                            ),
                                                        ),
                                                    ),

                                                    Container(
                                                        width: ScreenUtil().setWidth(1),
                                                        height: ScreenUtil().setHeight(50),
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
                                                            alignment: Alignment.center,
                                                            //color: Colors.blue,
                                                            child: Text(
                                                                "Section no.",
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(10),
                                                                ),
                                                            ),
                                                        ),
                                                    ),

                                                    Container(
                                                        width: ScreenUtil().setWidth(1),
                                                        height: ScreenUtil().setHeight(50),
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
                                                                "Page no.",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(10),
                                                                ),
                                                            ),
                                                        ),
                                                    ),

                                                ],
                                            ),
                                        ),

                                        Container(
                                            height: ScreenUtil().setHeight(700),
                                            child: ListView.builder(
                                                itemCount: heading.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                    String part1 = "", part2 = "";
                                                    if(section[index].contains("-")) {
                                                        part1 = section[index].split("-")[0];
                                                        part2 = section[index].split("-")[1];
                                                    }

                                                    return GestureDetector(
                                                        onTap: () {
                                                            pageCon.jumpToPage(page[index]-1);
                                                            if(!online)
                                                                canvasCon.jumpToPage(page[index]-1);
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
                                                                        //mainAxisAlignment: MainAxisAlignment.s,
                                                                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                        children: [

                                                                            (sub[index]) ? Container(
                                                                                width: ScreenUtil().setWidth(25),
                                                                            ) : Container(),

                                                                            Container(
                                                                                width: ScreenUtil().setWidth((sub[index])?235:260),
                                                                                alignment: Alignment.centerLeft,
                                                                                //color: Colors.blue,
                                                                                padding: EdgeInsets.fromLTRB(
                                                                                    ScreenUtil().setWidth(10),
                                                                                    ScreenUtil().setHeight(5),
                                                                                    ScreenUtil().setWidth(10),
                                                                                    ScreenUtil().setHeight(5),
                                                                                ),
                                                                                child: Text(
                                                                                    heading[index].toString(),
                                                                                    style: TextStyle(
                                                                                        fontSize: ScreenUtil().setSp((sub[index])?10:15),
                                                                                    ),
                                                                                ),
                                                                            ),

                                                                            Expanded(
                                                                                child: Container(
                                                                                    //height: ScreenUtil().setHeight(22),
                                                                                    alignment: Alignment.center,
                                                                                    //color: Colors.blue,
                                                                                    child: Text(
                                                                                        (section[index].contains("-"))?"$part1\n-\n$part2":section[index].toString(),
                                                                                        textAlign: TextAlign.center,
                                                                                        style: TextStyle(
                                                                                            fontSize: ScreenUtil().setSp((sub[index])?10:15),
                                                                                        ),
                                                                                    ),
                                                                                ),
                                                                            ),

                                                                            Container(
                                                                                width: ScreenUtil().setWidth(50),
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
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                                if(drawing || zoom) Container(
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
                                                        child: Icon(
                                                            Icons.navigate_before,
                                                            size: 27,
                                                        ),
                                                    ),
                                                ),

                                                if(drawing || zoom) Container(
                                                ) else GestureDetector(
                                                    onTap: () {
                                                        _drawerKey.currentState.openDrawer();
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
                                                            child: Icon(
                                                                Icons.list,
                                                                color: Colors.black,
                                                                size: 27,
                                                            ),
                                                        ),
                                                    ),
                                                ),

                                                (drawing)?GestureDetector(
                                                    onTap: () {
                                                        setState(() {
                                                            if(strokes.isNotEmpty) {
                                                                strokes[canvasCon.page.toInt()].removeLast();
                                                                writeJson();
                                                            }
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
                                                        child: Icon(
                                                            Icons.undo,
                                                            color: Colors.black,
                                                            size: 27,
                                                        ),
                                                    ),
                                                ):Container(),

                                                /*GestureDetector(
                                                    onTap: (){
                                                        pls().then((value) {
                                                            setState(() {
                                                                online = !value;
                                                            });
                                                        });
                                                    },
                                                    child: Text(online.toString()),
                                                ),*/
                                                if(drawing) Container(
                                                ) else if(zoom)SizedBox(
                                                    width: ScreenUtil().setWidth(220),
                                                ) else SizedBox(
                                                    width: ScreenUtil().setWidth((online)?150:100),
                                                ),

                                                if (online || zoom || !drawing) Container(
                                                ) else GestureDetector(
                                                    onTap: () {
                                                        strokes = [];
                                                        func3();
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
                                                            child: Icon(
                                                                Icons.clear,
                                                                color: Colors.black,
                                                                size: 27,
                                                            ),
                                                        ),
                                                    ),
                                                ),

                                                /*if(drawing) Container(
                                                    width: ,
                                                )*/

                                                if (online || zoom) Container(
                                                ) else GestureDetector(
                                                    onTap: () {
                                                        setState(() {
                                                            drawing = !drawing;
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
                                                        child: Icon(
                                                            (drawing)?Icons.exit_to_app:Icons.border_color,
                                                            color: Colors.black,
                                                            size: 27,
                                                        ),
                                                    ),
                                                ),

                                                if(drawing) SizedBox(
                                                    width: ScreenUtil().setWidth(22.5     ),
                                                ),

                                                if(drawing) Container(
                                                ) else GestureDetector(
                                                    onTap: () {
                                                        if (!zoom) {
                                                            showDialog(
                                                                context: context,
                                                                builder: (_) => WillPopScope(
                                                                    onWillPop: () async {
                                                                        return false;
                                                                    },
                                                                    child: AlertDialog(
                                                                        content: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                                Text("Loading..."),
                                                                                CircularProgressIndicator(),
                                                                            ],
                                                                        ),
                                                                    ),
                                                                ),
                                                                barrierDismissible: false,
                                                            );
                                                            pdfDocument.get(page: pageCon.page.round() + 1).then((value){
                                                                zoom = !zoom;
                                                                s = value.imgPath;
                                                                setState(() {
                                                                });
                                                                Navigator.pop(context);
                                                            });
                                                        } else {
                                                            zoom = !zoom;
                                                            setState(() {
                                                            });
                                                        }
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
                                                            child: Icon(
                                                                (zoom)?Icons.exit_to_app:Icons.zoom_in,
                                                                color: Colors.black,
                                                                size: 27,
                                                            ),
                                                        ),
                                                    ),
                                                ),

                                                if(drawing || zoom) Container(
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
                                                        child: Icon(
                                                            (online)?Icons.get_app:Icons.delete_forever,
                                                            color: Colors.black,
                                                            size: 27,
                                                        ),
                                                    ),
                                                )

                                            ],
                                        ),
                                    ),
                                ),

                                (load)?Expanded(
                                    child: Stack(
                                        children: [
                                            PDFViewer(
                                                key: _canvasKey,
                                                document: pdfDocument,
                                                //scrollDirection: Axis.vertical,
                                                enableSwipeNavigation: !zoom,
                                                controller: pageCon,
                                                lazyLoad: false,
                                                showPicker: false,
                                                pageSnapping: online,
                                                maxScale: 1.0,
                                                onPageChanged: (i){},
                                                navigationBuilder: (context, pageNumber, totalPages, jumpToPage, animateToPage) {
                                                    int x = pageNumber;
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
                                                                            value: strokeColor.value??Colors.black.value,
                                                                            iconSize: 24,
                                                                            elevation: 16,
                                                                            underline: Container(
                                                                                height: 0,
                                                                                //color: Colors.blue,
                                                                            ),
                                                                            onChanged: (int newValue) {
                                                                                setState(() {
                                                                                    strokeColor = Color(newValue);
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
                                                                                    builder: (_) => WillPopScope(
                                                                                        onWillPop: () async {
                                                                                            return false;
                                                                                        },
                                                                                        child: AlertDialog(
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
                                                                                    builder: (_) => WillPopScope(
                                                                                        onWillPop: () async {
                                                                                            return false;
                                                                                        },
                                                                                        child: AlertDialog(
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
                                                                max: totalPages.toDouble(),
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
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                    Opacity(
                                                        opacity: (canvasH == 0)?0:1,
                                                        child: Container(
                                                            height: ScreenUtil().setHeight((zoom)?0:610),
                                                            width: ScreenUtil().setWidth((zoom)?1:411),
                                                            child: PageView.builder(
                                                                itemCount: pdfDocument.count,
                                                                physics: (drawing || zoom)?NeverScrollableScrollPhysics():PageScrollPhysics(),
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
                                                                                        strokes[page]                //List of strokes in the page
                                                                                        [strokes[page].length - 1]   //The current stroke
                                                                                        ["offsets"]                  //The offsets in the current stroke
                                                                                                .add(details.localPosition); //Add the offset to the stroke
                                                                                    });
                                                                                },
                                                                                onPanEnd: (details) {
                                                                                    setState(() {
                                                                                    });
                                                                                    writeJson();
                                                                                },
                                                                                child: Container(
                                                                                    height: ScreenUtil().setHeight(canvasH),
                                                                                    width: ScreenUtil().setWidth(canvasW),
                                                                                    child: CustomPaint(
                                                                                        painter: (page < strokes.length)?Painter(
                                                                                            strokes: strokes[page],
                                                                                        ):Painter(),
                                                                                    ),
                                                                                ),
                                                                            ),
                                                                        );
                                                                    } else {
                                                                        return Center(
                                                                            child: Container(
                                                                                height: ScreenUtil().setHeight(canvasH),
                                                                                width: ScreenUtil().setWidth(canvasW),
                                                                                child: CustomPaint(
                                                                                    painter: (page < strokes.length)?Painter(
                                                                                        strokes: strokes[page],
                                                                                    ):Painter(),
                                                                                ),
                                                                            ),
                                                                        );
                                                                    }
                                                                },
                                                            ),
                                                        ),
                                                    ),
                                                    Container(
                                                        height: ScreenUtil().setHeight(50),
                                                    ),
                                                ],
                                            ),
                                            if(zoom) Container(
                                                height: ScreenUtil().setHeight(660),
                                                width: ScreenUtil().setWidth(411),
                                                padding: EdgeInsets.fromLTRB(
                                                    ScreenUtil().setWidth(0),
                                                    ScreenUtil().setHeight(0),
                                                    ScreenUtil().setWidth(0),
                                                    ScreenUtil().setHeight(45),
                                                ),
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: PDFPage(
                                                        s,
                                                        pageCon.page.round() + 1
                                                ),
                                            ),
                                        ],
                                    ),
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
            ),
        );
    }
}

class Painter extends CustomPainter {
    final List<Map<String, dynamic>> strokes;

    Painter({this.strokes}) : super();


    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
            ..color = Colors.black
            ..isAntiAlias = true
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

        //canvas.drawLine(Offset(100,100), Offset(200,200), paint);
        if(strokes != null){
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

    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
