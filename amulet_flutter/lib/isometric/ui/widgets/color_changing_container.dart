


import 'dart:async';

import 'package:flutter/material.dart';

class ColorChangingContainer extends StatefulWidget {

  final double size;
  final Widget child;
  final Color colorA;
  final Color colorB;

  const ColorChangingContainer({
    super.key,
    required this.size,
    required this.child,
    this.colorA = Colors.white,
    this.colorB = Colors.transparent,
  });

  @override
  _ColorChangingContainerState createState() => _ColorChangingContainerState();
}

class _ColorChangingContainerState extends State<ColorChangingContainer> {
  Timer? timer;
  late Color color;

  @override
  void initState() {
    super.initState();
    color = widget.colorA;
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(toggleColor);
    });
  }

  void toggleColor() {
    this.color = color == widget.colorA ? widget.colorB : widget.colorA;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: widget.size,
        height: widget.size,
        color: color,
        alignment: Alignment.center,
        child: widget.child,
      );
}