import 'dart:ui';

import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:flutter/cupertino.dart';

Size globalSize;
bool mouseDragging = false;
DragUpdateDetails dragUpdateDetails;

Offset get camera => Offset(cameraX, cameraY);

double convertScreenToWorldX(double value) {
  return cameraX + value / zoom;
}
double convertScreenToWorldY(double value) {
  return cameraY + value / zoom;
}
