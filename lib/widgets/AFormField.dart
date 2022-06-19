import 'package:allaw/utils/APadding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String fieldText, hintText, errorText;
  final bool isNumber, isMultiline;
  
  const AFormField({ 
    Key? key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    required this.fieldText,
    required this.hintText,
    this.errorText = "",
    this.isNumber = false,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  build(BuildContext context) {
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
          TextFormField(
            controller: controller,
            textAlign: TextAlign.start,
            focusNode: focusNode,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLines: isMultiline ? 6 : 1,
            keyboardType: isMultiline ? TextInputType.multiline : (isNumber ? TextInputType.number : TextInputType.text),
            onEditingComplete: () async {
              focusNode.unfocus();
              nextFocusNode?.requestFocus();
            },
            validator: (String? value) {
              if(errorText != "" && value == "") {
                return errorText;
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: aPaddingLTRB(10, 10, 10, 10),
              hintText: hintText,
            ),
          ),
        ],
    ),
    );
  }
}