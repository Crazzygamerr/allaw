import 'dart:io';

import 'package:allaw/global/widgets/LoadingDialog.dart';
import 'package:allaw/global/widgets/TextItem.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:allaw/utils/ViewerConfig.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

enum ListType {
  BareActs,
  Downloads,
  Notes
}

class DocumentList extends StatefulWidget {
  final ListType type;
  
  @override
  _DocumentListState createState() => _DocumentListState();
  
  DocumentList({
    Key? key,
    this.type = ListType.BareActs
  }) : super(key: key);
}

class _DocumentListState extends State<DocumentList>{

    List<String> documents = [];
    List<Reference> pdfReference = [];
    bool loading = true;
    String dir = "";
    TextEditingController textCon = new TextEditingController();

    @override
    void initState() {
        super.initState();
        PdftronFlutter.initialize();
        if(widget.type == ListType.BareActs){
            getBareActs();
        } else if(widget.type == ListType.Downloads){
            getDownloads();
        } else if(widget.type == ListType.Notes){
            getNotes();
        }
    }

    getBareActs() async {
        documents = []; pdfReference = []; 
        FirebaseStorage storage = FirebaseStorage.instance;
        ListResult res = await storage.ref().listAll();
        for(Reference ref in res.items) {
            if(ref.name.contains(".pdf")) {
                String s = ref.name.replaceAll(".pdf", "");
                documents.add(s);
                pdfReference.add(ref);
            } 
        }
        
        if(this.mounted) {
          setState(() {
            loading = false;
          });
        }
        
        dir = (await getApplicationDocumentsDirectory()).path;
    }
    
    getDownloads() async {
        documents = [];
        dir = (await getApplicationDocumentsDirectory()).path;
        var x = Directory(dir).listSync();
        for(var p in x){
            if(p.path.contains(".pdf")){
                documents.add(
                    p.path.substring(p.path.lastIndexOf("/") + 1).replaceAll(".pdf", "")
                );
            }
        }
        
        if(this.mounted) {
          setState(() {
            loading = false;
          });
        }
    }
    
    getNotes() async {
      documents = []; pdfReference = []; 
        FirebaseStorage storage = FirebaseStorage.instance;
        ListResult res = await storage.ref().listAll();
        for(Reference ref in res.items) {
            if(ref.name.contains(".pdf")) {
                String s = ref.name.replaceAll(".pdf", "");
                documents.add(s);
                pdfReference.add(ref);
            } 
        }
        
        if(this.mounted) {
          setState(() {
            loading = false;
          });
        }
        
        dir = (await getApplicationDocumentsDirectory()).path;
    }

    @override
    Widget build(BuildContext context) {
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
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.2)
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.2)
                                    ),
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
                                            itemCount: documents.length,

                                            itemBuilder: (context, index) {

                                                bool b = documents[index].toLowerCase().contains(textCon.text.toLowerCase());

                                                return (b) ? TextItem(
                                                    text: documents[index],
                                                    getDocs: (widget.type == ListType.Downloads) ? getDownloads : (){},
                                                    dir: (widget.type == ListType.Downloads) ? dir : "",
                                                    onTap: () async {
                                                        
                                                        bool local = await File(dir + "/" + (documents[index]) + ".pdf").exists();
                                                        if(!local) {
                                                          File pdfFile = new File(dir + "/" + (documents[index]) + ".pdf");
                                                          FirebaseStorage storage = FirebaseStorage.instance;
                                                          showLoadingDialog(context);
                                                          await storage.ref(pdfReference[index].fullPath).writeToFile(pdfFile);
                                                          Navigator.pop(context);
                                                        }
                                                        
                                                        if(widget.type == ListType.BareActs) {
                                                          var documentLoadedCancel = startDocumentLoadedListener(
                                                            (path) async {
                                                              await PdftronFlutter.openOutlineList();
                                                            });
                                                        }
                                                        
                                                        PdftronFlutter.openDocument(dir + "/" + (documents[index]) + ".pdf", config: getConfig());
                                                        
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
