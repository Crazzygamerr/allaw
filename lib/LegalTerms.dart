import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class LegalTerms extends StatefulWidget {
    @override
    _LegalTermsState createState() => _LegalTermsState();
}

class _LegalTermsState extends State<LegalTerms>{

    TextEditingController textCon = new TextEditingController();
    Sheet sheet;
    bool loading = true;

    @override
    void initState() {
        super.initState();
        getDocs();
    }

    getDocs() async {
        String dir = (await getApplicationDocumentsDirectory()).path;
        File xlsxFile;
        if(await File('$dir/Legal Terms.xlsx').exists()) {

            xlsxFile = File('$dir/Legal Terms.xlsx');

        } else {

            FirebaseStorage storage = FirebaseStorage.instance;
            Reference ref;
            xlsxFile = File('$dir/Legal Terms.xlsx');
            await storage.ref().listAll().then((value) {
                ref = value.items.singleWhere((element) => element.name == "Legal Terms.xlsx");
            });
            await storage.ref(ref.fullPath).writeToFile(xlsxFile);

        }

        List<int> bytes = xlsxFile.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        sheet = excel.tables["Sheet1"];
        setState(() {
            loading = false;
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
                                    border: Border.all(
                                        color: Colors.black,
                                    ),
                                ),
                                child: (!loading)?Scrollbar(
                                    child: ListView.builder(
                                        itemCount: sheet.rows.length,

                                        itemBuilder: (context, index) {

                                            bool b = sheet.rows[index][0].toLowerCase().contains(textCon.text.toLowerCase());

                                            return (b)?Container(
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        top: BorderSide(color: Colors.transparent),
                                                        bottom: BorderSide(color: Colors.black),
                                                        left: BorderSide(color: Colors.transparent),
                                                        right: BorderSide(color: Colors.transparent),
                                                    ),
                                                ),
                                              child: ExpansionTile(
                                                  title: Container(
                                                      padding: EdgeInsets.fromLTRB(
                                                          ScreenUtil().setWidth(20),
                                                          ScreenUtil().setHeight(20),
                                                          ScreenUtil().setWidth(10),
                                                          ScreenUtil().setHeight(20),
                                                      ),
                                                      child: Text(
                                                          sheet.rows[index][0],
                                                      ),
                                                  ),
                                                  children: [
                                                      Container(
                                                          padding: EdgeInsets.fromLTRB(
                                                              ScreenUtil().setWidth(10),
                                                              ScreenUtil().setHeight(0),
                                                              ScreenUtil().setWidth(10),
                                                              ScreenUtil().setHeight(10),
                                                          ),
                                                          child: Text(
                                                              sheet.rows[index][1],
                                                          ),
                                                      ),
                                                  ],
                                                  //isExpanded:
                                              ),
                                            ):Container();
                                        },
                                    ),
                                ) : Center(
                                    child: CircularProgressIndicator(),
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

}
