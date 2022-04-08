import 'dart:convert';

import 'package:allaw/global/widgets/LoadingDialog.dart';
import 'package:allaw/provider.dart';
import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class Request extends StatefulWidget {
    @override
    _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {

    final _formKey1 = GlobalKey<FormState>();

    TextEditingController textCon1 = new TextEditingController();
    TextEditingController textCon2 = new TextEditingController();
    TextEditingController textCon3 = new TextEditingController();

    FocusNode node1 = new FocusNode();
    FocusNode node2 = new FocusNode();
    FocusNode node3 = new FocusNode();

    bool isWriting1 = false,isWriting2 = false,isWriting3 = false;

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
                    child: SingleChildScrollView(
                        child: Column(
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

                                Container(
                                    height: ScreenUtil().setHeight(95),
                                    child: Row(
                                        children: [
                                            Container(
                                                width: ScreenUtil().setWidth(250),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Padding(
                                                            padding: aPaddingLTRB(10, 0, 0, 0),
                                                            child: Text(
                                                                "Name of Act/Legal Term*",
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(14),
                                                                ),
                                                            ),
                                                        ),
                                                        Form(
                                                            key: _formKey1,
                                                            child: TextFormField(
                                                                controller: textCon1,
                                                                textAlign: TextAlign.start,
                                                                focusNode: node1,
                                                                onChanged: (String s) {
                                                                    isWriting1 = true;
                                                                    _formKey1.currentState?.validate();
                                                                },
                                                                onEditingComplete: () async {
                                                                    if (textCon1.text.trim() != "") {
                                                                        node1.unfocus();
                                                                        node2.requestFocus();
                                                                    } else {
                                                                        isWriting1 = false;
                                                                        _formKey1.currentState?.validate();
                                                                    }
                                                                },
                                                                validator: (value){
                                                                    if(isWriting1)
                                                                        return null;
                                                                    else
                                                                        return "Name cannot be empty";
                                                                },
                                                                decoration: InputDecoration(border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                    contentPadding: aPaddingLTRB(10, 10, 10, 10),
                                                                    hintText: "Enter the name of the Act/Legal Term",
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),

                                            SizedBox(
                                                width: ScreenUtil().setWidth(20),
                                            ),

                                            Container(
                                                width: ScreenUtil().setWidth(90),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Padding(
                                                            padding: aPaddingLTRB(10, 0, 0, 0),
                                                            child: Text(
                                                                "Year",
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil().setSp(14),
                                                                ),
                                                            ),
                                                        ),
                                                        Form(
                                                            child: TextFormField(
                                                                controller: textCon2,
                                                                textAlign: TextAlign.start,
                                                                focusNode: node2,
                                                                keyboardType: TextInputType.number,
                                                                onChanged: (String s) {
                                                                    isWriting2 = true;
                                                                },
                                                                onEditingComplete: () async {
                                                                    node2.unfocus();
                                                                    node3.requestFocus();
                                                                },
                                                                validator: (value){
                                                                    if(isWriting2)
                                                                        return null;
                                                                    else
                                                                        return "Year cannot be empty";
                                                                },
                                                                decoration: InputDecoration(border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                    contentPadding: aPaddingLTRB(10, 10, 10, 10),
                                                                    hintText: "Year",
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),

                                        ],
                                    ),
                                ),

                                SizedBox(
                                    height: ScreenUtil().setHeight(0),
                                ),

                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Container(
                                            padding: aPaddingLTRB(10, 0, 0, 0),
                                            child: Text(
                                                "Your Email address",
                                                style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(14),
                                                ),
                                            ),
                                        ),
                                        Form(
                                            child: TextFormField(
                                                controller: textCon3,
                                                textAlign: TextAlign.start,
                                                focusNode: node3,
                                                onChanged: (String s) {
                                                    isWriting3 = true;
                                                },
                                                onEditingComplete: () async {
                                                    node3.unfocus();
                                                },
                                                decoration: InputDecoration(border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                ),
                                                    contentPadding: aPaddingLTRB(10, 10, 10, 10),
                                                    hintText: "Enter your email id",
                                                ),
                                            ),
                                        ),
                                    ],
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

                                Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    padding: aPaddingLTRB(10, 10, 0, 0),
                                    child: Text(
                                        "* - The field is mandatory",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(14),
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
        if (textCon1.text.trim() == "") {
            isWriting1 = false;
            _formKey1.currentState?.validate();
        } else {
            String URL = "https://script.google.com/macros/s/AKfycbx30nXWKUQCwn8mLqeSa7iC2JjZr7OT01tTBmCZg3j0eFeODh9gs3u9aQ/exec";
            FocusScope.of(context).unfocus();
            showLoadingDialog(context);
            try {
                await http.post(Uri.parse(URL), body: {
                    "name": textCon1.text,
                    "year": textCon2.text,
                    "email": textCon3.text,
                }).then((response) async {
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
                showLoadingDialog(
                  context, 
                  isError: true,
                );
            }
        }
    }

}
