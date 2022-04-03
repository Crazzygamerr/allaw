import 'dart:io';

import 'package:allaw/Viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

class Downloads extends StatefulWidget {
    @override
    _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads>{

    List<String> downloads = [];
    TextEditingController textCon = new TextEditingController();

    @override
    void initState() {
        super.initState();
        getDocs();
    }

    getDocs() async {
        downloads = [];
        String s = (await getApplicationDocumentsDirectory()).path;
        var x = Directory(s).listSync();
        for(var p in x){
            if(p.path.contains(".pdf")){
                downloads.add(
                    p.path.substring(
                        p.path.lastIndexOf("/") + 1,)
                            .replaceAll(".pdf", ""),);
            }
        }
        setState(() {
        });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            child: Column(
                children: [

                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                        ),
                        child: TextFormField(
                            controller: textCon,
                            style: TextStyle(
                                    fontSize: ScreenUtil().setSp(20)
                            ),
                            onChanged: (s) {
                                setState(() {
                                });
                            },
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                    size: 23,
                                ),
                                contentPadding: EdgeInsets.all(10),
                                focusColor: Colors.white,
                                hoverColor: Colors.white,
                                fillColor: Colors.white,
                                hintText: "Search",
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black
                                            .withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(50),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black
                                            .withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(50),
                                ),
                            ),
                        ),
                    ),

                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(10),
                                ScreenUtil().setWidth(10),
                                ScreenUtil().setHeight(10),
                            ),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    border: Border.all(
                                            color: Colors.black
                                    ),
                                ),
                                child: (downloads.length != 0)?ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Scrollbar(
                                        child: ListView.builder(
                                            itemCount: downloads.length,

                                            itemBuilder: (context, index) {

                                                bool b = downloads[index].toLowerCase().contains(textCon.text.toLowerCase());

                                                return (b)?GestureDetector(
                                                    onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            new MaterialPageRoute(
                                                                builder: (context) => Viewer(
                                                                    local: true,
                                                                    fileName: downloads[index],
                                                                ),
                                                            ),
                                                        ).then((value) {
                                                            getDocs();
                                                        });
                                                    },
                                                    child: Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            ScreenUtil().setWidth(20),
                                                            ScreenUtil().setHeight(20),
                                                            ScreenUtil().setWidth(10),
                                                            ScreenUtil().setHeight(20),
                                                        ),
                                                        decoration: BoxDecoration(
                                                            border: Border(
                                                                top: BorderSide(color: Colors.transparent),
                                                                bottom: BorderSide(color: Colors.black),
                                                                left: BorderSide(color: Colors.transparent),
                                                                right: BorderSide(color: Colors.transparent),
                                                            ),
                                                        ),
                                                        child: Text(
                                                            downloads[index],
                                                        ),
                                                    ),
                                                ):Container();
                                            },
                                        ),
                                    ),
                                ) : Center(
                                    child: Text(
                                            "No downloads!"
                                    ),
                                ),
                            ),
                        ),
                    ),

                ],
            ),
        );
    }

}