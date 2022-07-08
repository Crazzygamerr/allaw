import 'dart:convert';
import 'package:allaw/widgets/AFormField.dart';
import 'package:allaw/widgets/LoadingDialog.dart';
import 'package:allaw/utils/provider.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

enum RequestType {
  Material,
  Advice
}

class Request extends StatefulWidget {
  final RequestType type;
  
  @override
  _RequestState createState() => _RequestState();
  
  Request({
    Key? key,
    required this.type
  }) : super(key: key);
}

class _RequestState extends State<Request> {

    final _formKey1 = GlobalKey<FormState>();

    TextEditingController textCon1 = new TextEditingController(),  textCon2 = new TextEditingController(), textCon3 = new TextEditingController();
    FocusNode node1 = new FocusNode(), node2 = new FocusNode(), node3 = new FocusNode();

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
                PageConProvider.of(context)?.pageCon.jumpToPage(1);
                return false;
            },
            child: Padding(
                padding: aPaddingLTRB(10, 10, 10, 10),
                child: Container(
                    decoration: aBoxDecor15B(),
                    padding: aPaddingLTRB(10, 20, 10, 10),
                    child: Form(
                      key: _formKey1,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                    
                              Column(
                                children: [
                                  Container(
                                      child: Text(
                                          "Can't find a particular Act or Legal Term you are looking for, "
                                                  "let us know down below and we will add them immediately.",
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(13),
                                          ),
                                      ),
                                  ),
                    
                                  SizedBox(
                                      height: ScreenUtil().setHeight(30),
                                  ),
                    
                                  (widget.type == RequestType.Material) ? Container(
                                    height: ScreenUtil().setHeight(95),
                                    child: Row(
                                        children: [
                                            Container(
                                                width: ScreenUtil().setWidth(250),
                                                child: AFormField(
                                                  controller: textCon1,
                                                  focusNode: node1,
                                                  nextFocusNode: node2,
                                                  fieldText: "Name of Act/Legal Term*",
                                                  hintText: "Enter the name of the Act/Legal Term",
                                                  errorText: "Name cannot be empty",
                                                ),
                                            ),
                    
                                            SizedBox(
                                                width: ScreenUtil().setWidth(20),
                                            ),
                    
                                            Container(
                                                width: ScreenUtil().setWidth(90),
                                                child: AFormField(
                                                  controller: textCon2,
                                                  focusNode: node2,
                                                  nextFocusNode: node3,
                                                  fieldText: "Year",
                                                  hintText: "Year",
                                                  isNumber: true,
                                                ),
                                            ),
                    
                                        ],
                                    ),
                                  ) : AFormField(
                                    controller: textCon1, 
                                    focusNode: node1, 
                                    nextFocusNode: node3,
                                    fieldText: "Your Legal Query/Advice*", 
                                    hintText: "Enter your legal query/advice here",
                                    errorText: "Query cannot be empty",
                                    
                                    isMultiline: true,
                                  ),
                    
                                  SizedBox(
                                    height: ScreenUtil().setHeight(widget.type == RequestType.Material ? 0 : 25),
                                  ),
                                  
                                  AFormField(
                                    controller: textCon3, 
                                    focusNode: node3,
                                    fieldText: "Your Email Address" + (widget.type == RequestType.Advice ? "*" : ""),
                                    hintText: "Enter your email address",
                                    errorText: (widget.type == RequestType.Advice ? "Please enter a valid email address" : ""),
                                  ),
                    
                                  SizedBox(
                                      height: ScreenUtil().setHeight(25),
                                  ),
                                  
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                              ),
                                          ),
                                      ),
                                      onPressed: () {
                                          requestAct();
                                      },
                                      child: Padding(
                                          padding: aPaddingLTRB(10, 10, 10, 10),
                                          child: Text(
                                              "Submit",
                                              style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: ScreenUtil().setSp(14)
                                              ),
                                          ),
                                      ),
                                  ),
                                ],
                              ),
                    
                              Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: aPaddingLTRB(10, 140, 0, 0),
                                  child: Text(
                                      "* - The field is mandatory",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(11),
                                          color: Colors.red,
                                      ),
                                  ),
                              ),
                    
                          ],
                      ),
                    ),
                ),
            ),
        );
    }

    void requestAct() async {
        if (
          (widget.type == RequestType.Material && textCon1.text != "")
          || (widget.type == RequestType.Advice && textCon1.text != "" 
          && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(textCon3.text))
          ) {
          var body = {
            "email": textCon3.text,
          };
          if (widget.type == RequestType.Material) {
            body["functionName"] = "acts";
            body["name"] = textCon1.text;
            body["year"] = textCon2.text;
          } else {
            body["functionName"] = "advice";
            body["query"] = textCon1.text;
          }
          
          String URL = "https://script.google.com/macros/s/AKfycbx30nXWKUQCwn8mLqeSa7iC2JjZr7OT01tTBmCZg3j0eFeODh9gs3u9aQ/exec";
          FocusScope.of(context).unfocus();
          showLoadingDialog(context);
          try {
            await http.post(
              Uri.parse(URL), 
              body: body,
            ).then((response) async {
              if (response.statusCode == 302) {
                  String url = response.headers['location']!;
                  await http.get(Uri.parse(url)).then((response) {
                      Navigator.pop(context);
                      String s = (jsonDecode(response.body)['status'] == "SUCCESS")?"Success":"Error!";
                      if(jsonDecode(response.body)['status'] == "SUCCESS"){
                          textCon1.text = "";
                          textCon2.text = "";
                          textCon3.text = "";
                      }
                      showResposeDialog(context, s, response);
                  });
              } else {
                  Navigator.pop(context);
                  String s = (jsonDecode(response.body)['status'] == "SUCCESS")?"Success":"Error!";
                  if(jsonDecode(response.body)['status'] == "SUCCESS"){
                      textCon1.text = "";
                      textCon2.text = "";
                      textCon3.text = "";
                  }
                  showResposeDialog(context, s, response);
              }
            });
          } catch (e) {
              Navigator.pop(context);
              //TODO: Handle errors
              showLoadingDialog(
                context, 
                isError: true,
              );
          }  
        } else {
          _formKey1.currentState?.validate();
        }
    }

}
