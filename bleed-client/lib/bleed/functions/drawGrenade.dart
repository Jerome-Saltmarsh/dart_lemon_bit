
import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/draw.dart';
import 'package:flutter_game_engine/game_engine/engine_draw.dart';

void drawGrenade(double x, double y, double z){
  double size = 4;
  double shift = shiftScale(z);
  drawCircle(x, y, size / shift, Colors.black45);
  drawCircle(x, y + shiftHeight(z), shift * size, Colors.white);
}