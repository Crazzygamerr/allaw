import 'package:allaw/utils/ABoxDecoration.dart';
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
    return Container(
      width: ScreenUtil().setWidth(50),
      height: ScreenUtil().setHeight(50),
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
              child: Padding(
                padding: aPaddingLTRB(10, 10, 10, 10),
                child: Image.asset(
                      assetName,
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}