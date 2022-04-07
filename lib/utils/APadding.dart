import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

EdgeInsets aPaddingLTRB(double left, double top, double right, double bottom) {
  return EdgeInsets.fromLTRB(
    ScreenUtil().setWidth(left),
    ScreenUtil().setHeight(top),
    ScreenUtil().setWidth(right),
    ScreenUtil().setHeight(bottom),
  );
}


EdgeInsets aPaddingAll(double value) {
  return EdgeInsets.all(ScreenUtil().setWidth(value));
}