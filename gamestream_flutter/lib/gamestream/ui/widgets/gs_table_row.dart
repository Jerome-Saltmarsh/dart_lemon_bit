

import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildTableRow(String text, dynamic value) {
  if (value == null || value == 0) {
    return nothing;
  }

  final textColor = Colors.white.withOpacity(0.8);
  final textSize = 22;
  return Container(
    margin: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildText(text, color: textColor, size: textSize),
        Container(
            width: 70,
            alignment: Alignment.centerRight,
            color: Colors.white12,
            padding: const EdgeInsets.all(4),
            child: buildText(value is int ? value.toInt() : value, color: textColor, size: textSize)),
      ],
    ),
  );
}

