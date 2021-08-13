import 'dart:ui';

import 'package:flutter/cupertino.dart';

BuildContext globalContext;
Canvas globalCanvas;
Size globalSize;
double cameraX = 0;
double cameraY = 0;
double zoom = 1;
bool mouseDragging = false;
DragUpdateDetails dragUpdateDetails;