import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff404040),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: ScreenUtil().setHeight(230),
            ),
            Container(
              height: ScreenUtil().setHeight(250),
              width: ScreenUtil().setWidth(250),
              decoration: aBoxDecorCircle(),
              clipBehavior: Clip.hardEdge,
              child: Image.asset("assets/Logo.jpg"),
            ),
            Text(
              "Your Ally for Law",
              style: TextStyle(
                fontFamily: "Times New Roman",
                fontSize: ScreenUtil().setSp(18),
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(205),
            ),
            Text(
              "by LexLiaise",
              style: TextStyle(
                fontFamily: "Times New Roman",
                fontSize: ScreenUtil().setSp(16),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
