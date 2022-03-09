import 'package:flutter/material.dart';

class PageConProvider extends InheritedWidget{

    final Widget child;
    final PageController pageCon;

    PageConProvider({
        required this.child,
        required this.pageCon,
    }) : super(child: child);

    @override
    bool updateShouldNotify(InheritedWidget oldWidget) {
        return true;
    }

    static PageConProvider? of(BuildContext context){
        return context.dependOnInheritedWidgetOfExactType();
    }

}