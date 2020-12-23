import 'package:allaw/Viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BareActs extends StatefulWidget {
  @override
  _BareActsState createState() => _BareActsState();
}

class _BareActsState extends State<BareActs>{

  List<String> bareActs = [];
  List<Reference> pdfReference = [], xlsxReference = [];
  TextEditingController textCon = new TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getDocs();
  }

  getDocs() async {
      bareActs = []; pdfReference = []; xlsxReference = [];
      FirebaseStorage storage = FirebaseStorage.instance;
      ListResult res = await storage.ref().listAll();
      List<String> excel = [];
      List<Reference> excelRef = [];
      for(Reference ref in res.items) {
          if(ref.name.contains(".pdf")) {
              String s = ref.name.replaceAll(".pdf", "");
              bareActs.add(s);
              pdfReference.add(ref);
          } else if(ref.name.contains('.xlsx')) {
              excel.add(ref.name);
              excelRef.add(ref);
          }
      }
      for(String s in bareActs) {
          int x = excel.indexOf(s + '.xlsx');
          xlsxReference.add(excelRef.elementAt(x));
      }
      setState(() {
          loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
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
                                  color: Colors.black
                              ),
                          ),
                          child: (!loading)?Scrollbar(
                            child: ListView.builder(
                                itemCount: bareActs.length,

                                itemBuilder: (context, index) {

                                    bool b = bareActs[index].toLowerCase().contains(textCon.text.toLowerCase());

                                    return (b)?GestureDetector(
                                      onTap: () {
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) => Viewer(
                                                      pdfReference: pdfReference[index],
                                                      xlsxReference: xlsxReference[index],
                                                      local: false,
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
                                          child: Text(
                                              bareActs[index],
                                          ),
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

  /*@override
  bool get wantKeepAlive => true;*/
}
