import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'engine_state.dart';
import 'game_widget.dart';
import 'global_paint.dart';

void drawCircle(double x, double y, double radius, Color color) {
  drawCircleOffset(Offset(x, y), radius, color);
}

void drawCircleOffset(Offset offset, double radius, Color color) {
  // TODO Optimize
  paint.color = color;
  globalCanvas.drawCircle(offset, radius, paint);
}

void drawSprite(ui.Image image, int frames, int frame, double x, double y) {
  double frameWidth = image.width / frames;
  double frameHeight = image.height as double;
  globalCanvas.drawImageRect(image,
      Rect.fromLTWH((frame - 1) * frameWidth, 0, frameWidth, frameHeight),
      Rect.fromCenter(
          center: Offset(x, y), width: frameWidth, height: frameHeight),
      paint);
}

TextStyle _style = TextStyle(
    color: white, fontSize: 20, fontWeight: FontWeight.normal);

TextSpan _span = TextSpan(style: _style, text: "");

TextPainter _textPainter = TextPainter(
    text: _span,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr
);

void drawText(String text, double x, double y, {Canvas canvas}) {
  _textPainter.text = TextSpan(style: _style, text: text);
  _textPainter.layout();
  _textPainter.paint(canvas ?? globalCanvas, Offset(x, y));
}

