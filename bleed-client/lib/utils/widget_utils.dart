

import 'package:flutter/cupertino.dart';

typedef MouseOverBuilder = Widget Function(BuildContext context, bool mouseOver);

Widget mouseOver({MouseOverBuilder builder}){
  return Builder(builder: (context) {
    bool mouseOver = false;
    return StatefulBuilder(
        builder: (BuildContext cont, StateSetter setState) {
          print("Building mouse over");
          return MouseRegion(
              onEnter: (_) {
                mouseOver = true;
                setState(() {});
              },
              onExit: (_) {
                mouseOver = false;
                setState(() {});
              },
              child: builder(cont, mouseOver));
        });
  });
}