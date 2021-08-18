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

void drawSprite(ui.Image image, int frames, int frame, double x, double y, {double scale = 1.0}){
  double frameWidth = image.width / frames;
  double frameHeight = image.height as double;
  globalCanvas.drawImageRect(image, Rect.fromLTWH(frame * frameWidth, 0, frameWidth, frameHeight),
      Rect.fromCenter(center: Offset(x - cameraX, y - cameraY), width: frameWidth * scale, height: frameHeight * scale), globalPaint);
}

void drawText(String text, double x, double y, Color color){
  TextSpan span = new TextSpan(style: new TextStyle(color: color), text: text);
  TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
  tp.layout();
  tp.paint(globalCanvas, new Offset(x - cameraX, y - cameraY));
}
