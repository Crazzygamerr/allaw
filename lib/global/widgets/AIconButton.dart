import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIconButton extends StatelessWidget {
  final String assetName;
  final Function onTap;
  const AIconButton({
      Key? key,
      required this.assetName,
      required this.onTap,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
          width: ScreenUtil().setWidth(50),
          height: ScreenUtil().setHeight(50),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  width: 1,
                  color: Colors.black,
              ),
          ),
          padding: aPaddingLTRB(8, 8, 8, 8),
          child: Image.asset(
              assetName,
          ),
      ),
  );
  }
}