import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/pi2.dart';

double getMouseRotation() {
  return angleBetween(game.player.x, game.player.y, mouseWorldX, mouseWorldY);
}

bool get playerAssigned => game.playerId >= 0;

void drawLine(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), paint);
}

void drawLine3(double x1, double y1, double x2, double y2) {
}

void drawCustomLine(double x1, double y1, double x2, double y2, Paint paint) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), paint);
}

Offset offset(double x, double y) {
  return Offset(x, y);
}

dynamic rotationToPosX(double rotation, double distance) {
  return -cos(rotation + (pi * 0.5)) * distance;
}

dynamic rotationToPosY(double rotation, double distance) {
  return -sin(rotation + (pi * 0.5)) * distance;
}

double round(double value, {int decimals = 1}) {
  return double.parse(value.toStringAsFixed(decimals));
}

const double _eight = pi / 8.0;
const double _quarter = pi / 4.0;

Direction convertAngleToDirection(double angle) {
  angle = angle % pi2;
  if (angle < _eight) {
    return Direction.Up;
  }
  if (angle < _eight + (_quarter * 1)) {
    return Direction.UpRight;
  }
  if (angle < _eight + (_quarter * 2)) {
    return Direction.Right;
  }
  if (angle < _eight + (_quarter * 3)) {
    return Direction.DownRight;
  }
  if (angle < _eight + (_quarter * 4)) {
    return Direction.Down;
  }
  if (angle < _eight + (_quarter * 5)) {
    return Direction.DownLeft;
  }
  if (angle < _eight + (_quarter * 6)) {
    return Direction.Left;
  }
  if (angle < _eight + (_quarter * 7)) {
    return Direction.UpLeft;
  }
  return Direction.Up;
}

repeat(Function function, int times, int milliseconds) {
  for (int i = 0; i < times; i++) {
    Future.delayed(Duration(milliseconds: milliseconds * i), function);
  }
}

void cameraCenter(double x, double y) {
  camera.x = x - (screenCenterX / zoom);
  camera.y = y - (screenCenterY / zoom);
}


