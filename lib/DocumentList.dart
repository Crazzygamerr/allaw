import 'dart:io';

import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:allaw/utils/ViewerConfig.dart';
import 'package:allaw/utils/provider.dart';
import 'package:allaw/widgets/ASearch.dart';
import 'package:allaw/widgets/LoadingDialog.dart';
import 'package:allaw/widgets/TextItem.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

enum ListType {
  BareActs,
  Downloads,
  Queries
}

class DocumentList extends StatefulWidget {
  final ListType type;
  
  @override
  _DocumentListState createState() => _DocumentListState();
  
  DocumentList({
    Key? key,
    required this.type
  }) : super(key: key);
}

class _DocumentListState extends State<DocumentList>{

    List<String> documents = [];
    List<Reference> pdfReference = [];
    bool loading = true;
    String dir = "", searchTerm = "";

    @override
    void initState() {
        super.initState();
        PdftronFlutter.initialize();
        if(widget.type == ListType.Downloads){
            getDownloads();
        } else {
            getDocuments();
        }
    }

    getDocuments() async {
        documents = []; pdfReference = []; 
        FirebaseStorage storage = FirebaseStorage.instance;
        
        ListResult res;
        if(widget.type == ListType.BareActs){
          res = await storage.ref().child("Acts").listAll();
        } else {
          res = await storage.ref().child("Queries").listAll();
        }
        
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

    @override
    Widget build(BuildContext context) {
        return Container(
            child: Column(
                children: [

                    ASearchWidget(
                      onChanged: (String s) {
                        setState(() {
                          searchTerm = s;
                        });
                      }
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

                                                bool b = documents[index].toLowerCase().contains(searchTerm.toLowerCase());

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
                                                        
                                                        var documentLoadedCancel = startDocumentLoadedListener(
                                                          (path) async {
                                                            await PdftronFlutter.openOutlineList();
                                                            
                                                          });
                                                        
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
                    
                    (widget.type == ListType.Queries) ?
                      GestureDetector(
                        onTap: () {
                          PageConProvider.of(context)?.pageCon.jumpToPage(8);
                        },
                        child: Container(
                            decoration: aBoxDecor15B(),
                            margin: aPaddingLTRB(10, 0, 10, 10),
                            padding: aPaddingLTRB(10, 10, 10, 10),
                            width: double.infinity,
                            alignment: Alignment.center,
                            
                            child: Text(
                              "Request Advice",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(14),
                                ),
                            ),
                        ),
                      ) : Container(),

                ],
            ),
        );
    }

/*@override
  bool get wantKeepAlive => true;*/
}
