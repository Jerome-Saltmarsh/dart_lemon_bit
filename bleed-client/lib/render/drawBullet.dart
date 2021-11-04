

import 'package:bleed_client/engine/render/drawCircle.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:flutter/material.dart';

void drawBullet(double x, double y){
  if (inDarkness(x, y)) return;
  drawCircle(x, y, 2, Colors.white);
}