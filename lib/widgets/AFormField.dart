import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ValidatorType {
  email,
  text,
  none
}

class AFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String fieldText, hintText;
  final ValidatorType validatorType;
  
  const AFormField({ 
    Key? key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    required this.fieldText,
    required this.hintText,
    this.validatorType = ValidatorType.none,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: aPaddingLTRB(10, 0, 0, 0),
            child: Text(
              fieldText,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(14),
              ),
            ),
          ),
          Form(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.start,
              focusNode: focusNode,
              onEditingComplete: () async {
                focusNode.unfocus();
                nextFocusNode?.requestFocus();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // no error message when in focus
                errorStyle: focusNode.hasFocus ? TextStyle() : null,
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: aPaddingLTRB(10, 10, 10, 10),
                hintText: hintText,
              ),
            ),
          ),
        ],
    ),
    );
  }
}