import 'package:flutter/material.dart';

BoxDecoration aBoxDecor15B() {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    border: Border.all(
      color: Colors.black,
      width: 1,
    ),
    color: Colors.white,
  );
}

BoxDecoration aBoxDecor50W() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    color: Colors.white,
  );
}

BoxDecoration aBoxDecorCircle() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20)
  );
}

BoxDecoration aBoxDecorBottom() {
  return BoxDecoration(
    border: Border(
      top: BorderSide(color: Colors.transparent),
      bottom: BorderSide(color: Colors.black),
      left: BorderSide(color: Colors.transparent),
      right: BorderSide(color: Colors.transparent),
    ),
  );
}