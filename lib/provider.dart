import 'package:flutter/material.dart';

class pageConProvider extends InheritedWidget{

    final Widget child;
    final PageController pageCon;

    pageConProvider({this.child, this.pageCon,});

    @override
    bool updateShouldNotify(InheritedWidget oldWidget) {
        return true;
    }

    static pageConProvider of(BuildContext context){
        return context.dependOnInheritedWidgetOfExactType();
    }

}