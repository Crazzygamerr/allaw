import 'dart:io';
import 'package:allaw/global/widgets/TextItem.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:allaw/utils/ViewerConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class Downloads extends StatefulWidget {
    @override
    _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads>{

    List<String> downloads = [];
    TextEditingController textCon = new TextEditingController();
    String dir = "";

    @override
    void initState() {
        super.initState();
        getDocs();
    }

    getDocs() async {
        downloads = [];
        dir = (await getApplicationDocumentsDirectory()).path;
        var x = Directory(dir).listSync();
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
                                decoration: aBoxDecor15B(),
                                child: (downloads.length != 0)?ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Scrollbar(
                                        child: ListView.builder(
                                            itemCount: downloads.length,

                                            itemBuilder: (context, index) {

                                                bool b = downloads[index].toLowerCase().contains(textCon.text.toLowerCase());

                                                return (b)?TextItem(
                                                  text: downloads[index],
                                                  dir: dir,
                                                  getDocs: getDocs,
                                                  onTap: () {
                                                      /* Navigator.push(
                                                          context,
                                                          new MaterialPageRoute(
                                                              builder: (context) => Viewer(
                                                                  fileName: downloads[index],
                                                              ),
                                                          ),
                                                      ).then((value) {
                                                          getDocs();
                                                      }); */
                                                      
                                                      PdftronFlutter.openDocument(dir + "/" + (downloads[index]) + ".pdf", config: getConfig());
                                                  },
                                                ):Container();
                                            },
                                        ),
                                    ),
                                ) : Center(
                                    child: Text(
                                      "No downloads!",
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