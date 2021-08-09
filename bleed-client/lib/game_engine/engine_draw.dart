import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'engine_state.dart';
import 'game_widget.dart';

void drawImage(ui.Image image, double x, double y, {double rotation = 0, double anchorX = 0.5, double anchorY = 0.5, double scale = 1.0}){
  globalCanvas.drawAtlas(
      image,
      <RSTransform>[
        RSTransform.fromComponents(
          rotation: rotation,
          scale: scale,
          anchorX: image.width * anchorX,
          anchorY: image.height * anchorY,
          translateX: x - cameraX,
          translateY: y - cameraY,
        )
      ],
      [
        Rect.fromLTWH(
            0, 0, image.width as double, image.height as double)
      ],
      null,
      BlendMode.color,
      null,
      globalPaint);
}

void drawCircle(double x, double y, double radius, Color color){
  globalPaint.color = color;
  globalCanvas.drawCircle(Offset(x, y), radius, globalPaint);
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
