import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:allaw/utils/APadding.dart';

class TextItem extends StatelessWidget {
  final Function onTap;
  final String text;
  const TextItem({ 
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
          padding: aPaddingLTRB(20, 0 , 0, 0),
          decoration: aBoxDecorBottom(),
          alignment: Alignment.centerLeft,
          height: ScreenUtil().setHeight(60),
          width: double.infinity,
          child: Text(
            text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14),
              ),
          ),
      ),
  );
  }
}