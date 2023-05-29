import 'package:flutter/material.dart';



typedef MouseOverBuilder = Widget Function(bool mouseOver);
typedef HoverBuilder = Widget Function(bool hovering);

Widget onHover(HoverBuilder builder, {
  Function? onEnter,
  Function? onExit
}) {
  return Builder(builder: (context) {
    bool mouseOver = false;
    return StatefulBuilder(builder: (BuildContext cont, StateSetter setState) {
      return MouseRegion(
          onEnter: (_) {
            if (onEnter != null) onEnter();
            setState(() {
              mouseOver = true;
            });
          },
          onExit: (_) {
            if (onExit != null) onExit();
            setState(() {
              mouseOver = false;
            });
          },
          child: builder(mouseOver));
    });
  });
}
