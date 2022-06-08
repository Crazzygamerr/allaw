import 'package:allaw/Viewer/Viewer.dart';
import 'package:allaw/global/widgets/LoadingDialog.dart';
import 'package:allaw/global/widgets/TextItem.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class BareActs extends StatefulWidget {
    @override
    _BareActsState createState() => _BareActsState();
}
//TODO:  remove 1, 5, 7, 8, 9, 11, 12, 13 buttons from the viewer
//TODO: share and delete button
//TODO: Change annotation heading, and remove extra colors and fonts
//TODO: try to get the outline button seperate

class _BareActsState extends State<BareActs>{

    List<String> bareActs = [];
    List<Reference> pdfReference = [], xlsxReference = [];
    TextEditingController textCon = new TextEditingController();
    bool loading = true;
    String dir = "";

    @override
    void initState() {
        super.initState();
        PdftronFlutter.initialize();
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
        if(this.mounted)
          setState(() {
            loading = false;
          });
        
        dir = (await getApplicationDocumentsDirectory()).path;
    }

    @override
    Widget build(BuildContext context) {
        //super.build(context);
        return Container(
            child: Column(
                children: [

                    Container(
                        decoration: aBoxDecor50W(),
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
                                contentPadding: aPaddingLTRB(10, 10, 10, 10),
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
                                decoration: aBoxDecor15B(),
                                child: (!loading)?ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Scrollbar(
                                        child: ListView.builder(
                                            itemCount: bareActs.length,

                                            itemBuilder: (context, index) {

                                                bool b = bareActs[index].toLowerCase().contains(textCon.text.toLowerCase());

                                                return (b)?TextItem(
                                                  text: bareActs[index],
                                                    onTap: () async {
                                                        /* Navigator.push(
                                                            context,
                                                            new MaterialPageRoute(
                                                                builder: (context) => Viewer(
                                                                    pdfReference: pdfReference[index],
                                                                    xlsxReference: xlsxReference[index],
                                                                ),
                                                            ),
                                                        ).then((value) {
                                                            getDocs();
                                                        }); */
                                                        
                                                        
                                                        bool local = await File(dir + "/" + (bareActs[index]) + ".pdf").exists();
                                                        if(!local) {
                                                          File pdfFile = new File(dir + "/" + (bareActs[index]) + ".pdf");
                                                          FirebaseStorage storage = FirebaseStorage.instance;
                                                          showLoadingDialog(context);
                                                          await storage.ref(pdfReference[index].fullPath).writeToFile(pdfFile);
                                                          Navigator.pop(context);
                                                        }
                                                        
                                                        Config config = new Config();
                                                        
                                                        config.annotationToolbars = [
                                                          DefaultToolbars.view,
                                                          DefaultToolbars.annotate,
                                                        ];
                                                        
                                                        config.disabledElements = [
                                                          Buttons.printButton,
                                                          Buttons.saveCopyButton,
                                                          Buttons.editPagesButton,
                                                          Buttons.shareButton,
                                                          Buttons.viewLayersButton,
                                                          //Buttons.viewControlsButton,
                                                        ];
                                                        
                                                        config.bottomToolbar = [
                                                          Buttons.viewControlsButton,
                                                          Buttons.searchButton,
                                                          Buttons.listsButton,
                                                          Buttons.outlineListButton,
                                                        ];
                                                        
                                                        config.disabledTools = [
                                                          Tools.annotationSmartPen,
                                                          Tools.annotationCreateFreeHand,
                                                          Tools.annotationCreateTextStrikeout,
                                                          Tools.annotationCreateTextSquiggly,
                                                          Tools.annotationCreateSticky,
                                                          Tools.annotationCreateCallout,
                                                          Tools.multiSelect,
                                                          Tools.annotationLasso,
                                                          Tools.annotationEdit
                                                        ];
                                                        
                                                        config.annotationToolbarAlignment = ToolbarAlignment.Start;               
                                                        config.outlineListEditingEnabled = false;
                                                        
                                                        var documentLoadedCancel = startDocumentLoadedListener((path) async
                                                          {
                                                            await PdftronFlutter.openOutlineList();
                                                          });
                                                        
                                                        PdftronFlutter.openDocument(dir + "/" + (bareActs[index]) + ".pdf", config: config);
                                                        
                                                    }, 
                                                ):Container();
                                            },
                                        ),
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
