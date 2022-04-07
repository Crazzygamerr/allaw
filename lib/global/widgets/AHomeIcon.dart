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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    width: 1,
                    color: Colors.black,
                ),
            ),
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