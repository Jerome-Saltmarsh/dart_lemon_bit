import 'dart:ui';

import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/textPainter.dart';
import 'package:bleed_client/engine/state/textStyle.dart';
import 'package:flutter/painting.dart';

void drawText(String text, double x, double y, {Canvas canvas, TextStyle style}) {
  textPainter.text = TextSpan(style: style ?? textStyle, text: text);
  textPainter.layout();
  textPainter.paint(canvas ?? globalCanvas, Offset(x, y));
}

