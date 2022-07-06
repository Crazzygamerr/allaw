import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AHomeIcon extends StatelessWidget {
  final Function onTap;
  final String assetName;
  final String text;
  const AHomeIcon({ 
    Key? key,
    required this.onTap,
    required this.assetName,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(100),
      decoration: aBoxDecor15B(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.black38,
          ),
          child: Material(
            child: InkWell(
              onTap: () => onTap(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    assetName,
                    width: ScreenUtil().setWidth(20),
                    height: ScreenUtil().setHeight(20),
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(13)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}