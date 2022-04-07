import 'dart:io';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class LegalTerms extends StatefulWidget {
    @override
    _LegalTermsState createState() => _LegalTermsState();
}

class _LegalTermsState extends State<LegalTerms>{

    TextEditingController textCon = new TextEditingController();
    late Sheet sheet;
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
            Reference? ref;
            xlsxFile = File('$dir/Legal Terms.xlsx');
            await storage.ref().listAll().then((value) {
                ref = value.items.singleWhere((element) => element.name == "Legal Terms.xlsx");
            });
            await storage.ref(ref!.fullPath).writeToFile(xlsxFile);
        }

        List<int> bytes = xlsxFile.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        sheet = excel.tables["Sheet1"]!;
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
                            padding: aPaddingLTRB(10, 10, 10, 10),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    border: Border.all(
                                        color: Colors.black,
                                    ),
                                ),
                                child: (!loading)?Scrollbar(
                                    child: ListView.builder(
                                        itemCount: sheet.rows.length,

                                        itemBuilder: (context, index) {

                                            bool b = sheet.rows[index][0].toString().toLowerCase().contains(textCon.text.toLowerCase());

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
                                                      padding: aPaddingLTRB(20, 20, 10, 20),
                                                      child: Text(
                                                          sheet.rows[index][0]?.value,
                                                      ),
                                                  ),
                                                  children: [
                                                      Container(
                                                          padding: aPaddingLTRB(10, 0, 10, 10),
                                                          child: Text(
                                                              sheet.rows[index][1]?.value,
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
