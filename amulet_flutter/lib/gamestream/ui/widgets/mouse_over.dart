import 'package:flutter/material.dart';

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
            onEnter?.call();
            setState(() {
              mouseOver = true;
            });
          },
          onExit: (_) {
            onExit?.call();
            setState(() {
              mouseOver = false;
            });
          },
          child: builder(mouseOver));
    });
  }
}


class AdvancedMouseOver extends StatelessWidget {

  final Widget Function(bool mouseOver, dynamic event) builder;
  final Function? onEnter;
  final Function? onExit;

  AdvancedMouseOver({required this.builder, this.onEnter, this.onExit});

  @override
  Widget build(BuildContext context)  {
    var mouseOver = false;
    var event;
    return StatefulBuilder(builder: (BuildContext cont, StateSetter setState) {
      return MouseRegion(
          onEnter: (_) {
            onEnter?.call();
            setState(() {
              event = _;
              mouseOver = true;
            });
          },
          onExit: (_) {
            onExit?.call();
            setState(() {
              event = _;
              mouseOver = false;
            });
          },
          child: builder(mouseOver, event));
    });
  }
}
