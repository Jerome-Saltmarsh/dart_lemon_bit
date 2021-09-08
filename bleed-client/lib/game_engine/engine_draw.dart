import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'engine_state.dart';
import 'game_widget.dart';


void drawCircle(double x, double y, double radius, Color color){
  globalPaint.color = color;
  globalCanvas.drawCircle(Offset(x, y), radius, globalPaint);
}

void drawCircleOffset(Offset offset, double radius, Color color){
  globalPaint.color = color;
  globalCanvas.drawCircle(offset, radius, globalPaint);
}

void drawSprite(ui.Image image, int frames, int frame, double x, double y){
  double frameWidth = image.width / frames;
  double frameHeight = image.height as double;
  globalCanvas.drawImageRect(image, Rect.fromLTWH((frame - 1) * frameWidth, 0, frameWidth, frameHeight),
      Rect.fromCenter(center: Offset(x, y), width: frameWidth, height: frameHeight), globalPaint);
}

TextStyle _style = TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold);

void drawText(String text, double x, double y){
  TextSpan span = TextSpan(style: _style, text: text);
  TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
  tp.layout();
  tp.paint(globalCanvas, Offset(x, y));
}
