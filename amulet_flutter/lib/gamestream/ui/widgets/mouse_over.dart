import 'package:flutter/material.dart';

Offset? mouseOverEnterPosition;
Offset? mouseOverExitPosition;

class MouseOver extends StatelessWidget {

  final Widget Function(bool mouseOver) builder;
  final Function? onEnter;
  final Function? onExit;

  MouseOver({required this.builder, this.onEnter, this.onExit});

  @override
  Widget build(BuildContext context)  {
    var mouseOver = false;
    return StatefulBuilder(builder: (BuildContext cont, StateSetter setState) {
      return MouseRegion(
          onEnter: (_) {
            mouseOverEnterPosition = _.position;
            onEnter?.call();
            setState(() {
              mouseOver = true;
            });
          },
          onExit: (_) {
            mouseOverExitPosition = _.position;
            onExit?.call();
            setState(() {
              mouseOver = false;
            });
          },
          child: builder(mouseOver));
    });
  }
}


