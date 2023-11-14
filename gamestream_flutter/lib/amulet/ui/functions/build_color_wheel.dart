import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildColorWheel({
  required List<Color> colors,
  Function (Color color)? onPickColor,
  Function (int index)? onPickIndex,
  int? currentIndex,
  double width = 50.0,
}) => Column(
  children: colors.map((color) {
    final active = colors.indexOf(color) == currentIndex;
    final sizedWidth = active ? (width * goldenRatio_1381) : width;
    return onPressed(
      action: () {
        if (onPickColor != null){
          onPickColor(color);
        }
        if (onPickIndex != null){
          onPickIndex(colors.indexOf(color));
        }
      },
      child: AnimatedContainer(
        curve: Curves.easeInOutQuad,
        key: ValueKey(color.value),
        duration: const Duration(milliseconds: 120),
        color: color,
        width: sizedWidth,
        height: sizedWidth * goldenRatio_0618,
        alignment: Alignment.center,
      ),
    );
  }).toList(growable: false),
);

