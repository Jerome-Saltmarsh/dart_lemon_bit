

import 'package:bleed_client/getters/inDarkness.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';

void drawBullet(double x, double y){
  if (inDarkness(x, y)) return;
  drawCircle(x, y, 2, Colors.white);
}