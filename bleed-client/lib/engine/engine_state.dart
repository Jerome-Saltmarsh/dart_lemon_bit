import 'dart:ui';

import 'package:flutter/cupertino.dart';

Canvas globalCanvas;
Size globalSize;
double cameraX = 0;
double cameraY = 0;
double zoom = 1;
bool mouseDragging = false;
DragUpdateDetails dragUpdateDetails;

Offset get camera => Offset(cameraX, cameraY);

double convertScreenToWorldX(double value) {
  return cameraX + value / zoom;
}
double convertScreenToWorldY(double value) {
  return cameraY + value / zoom;
}
