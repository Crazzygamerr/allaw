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
    return GestureDetector(
        onTap: () => onTap(),
        child: Container(
            width: ScreenUtil().setWidth(100),
            decoration: aBoxDecor15B(),
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
                                fontSize: ScreenUtil().setSp(14)
                        ),
                    ),
                ],
            ),
        ),
    );
  }
}