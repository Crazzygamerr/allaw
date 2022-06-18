import 'package:allaw/utils/ABoxDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ASearchWidget extends StatelessWidget {
  final Function onChanged;
  const ASearchWidget({ 
    Key? key,
    required this.onChanged,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aBoxDecor50W(),
      child: TextFormField(
          style: TextStyle(
            fontSize: ScreenUtil().setSp(20)
          ),
          onChanged: (s) {
              onChanged(s);
          },
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.black,
                size: 23,
              ),
              contentPadding: EdgeInsets.all(10),
              focusColor: Colors.white,
              hoverColor: Colors.white,
              fillColor: Colors.white,
              hintText: "Search",
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.2)
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.2)
                ),
                borderRadius: BorderRadius.circular(50),
              ),
          ),
      ),
  );
  }
}