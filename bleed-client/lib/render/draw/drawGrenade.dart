
import 'package:bleed_client/draw.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';

void drawGrenade(double x, double y, double z){
  double size = 4;
  double shift = shiftScale(z);
  drawCircle(x, y, size / shift, Colors.black45);
  drawCircle(x, y + shiftHeight(z), shift * size, Colors.white);
}