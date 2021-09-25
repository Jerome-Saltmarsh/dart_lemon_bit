import 'package:flutter/cupertino.dart';

typedef MouseOverBuilder = Widget Function(
    BuildContext context, bool mouseOver);

Widget mouseOver(
    {MouseOverBuilder builder, Function onEnter, Function onExit}) {
  return Builder(builder: (context) {
    bool mouseOver = false;
    return StatefulBuilder(builder: (BuildContext cont, StateSetter setState) {
      print("Building mouse over");
      return MouseRegion(
          onEnter: (_) {
            if (onEnter != null) onEnter();
            mouseOver = true;
            setState(() {});
          },
          onExit: (_) {
            if (onExit != null) onExit();
            mouseOver = false;
            setState(() {});
          },
          child: builder(cont, mouseOver));
    });
  });
}
