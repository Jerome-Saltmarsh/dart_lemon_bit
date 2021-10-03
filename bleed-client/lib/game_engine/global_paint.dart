import 'dart:ui';

import 'package:flutter/material.dart';

final Paint globalPaint = Paint()
  ..color = Colors.white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 1;

void setColorBlue(){
  setColor(Colors.blue);
}

void setColorRed(){
  setColor(Colors.blue);
}

void setColorWhite(){
  setColor(Colors.white);
}

void setStrokeWidth(double value){
  globalPaint.strokeWidth = value;
}

void setColor(Color value) {
  if (globalPaint.color == value) return;
  globalPaint.color = value;
}