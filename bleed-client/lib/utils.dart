import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/angle_between.dart';

import 'common/Weapons.dart';
import 'common.dart';
import 'maths.dart';

double getMouseRotation() {
  return angleBetween(game.playerX, game.playerY, mouseWorldX, mouseWorldY);
}

bool get playerAssigned => game.playerId >= 0;

Weapon previousWeapon;

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

int convertAngleToDirection(double angle) {
  if (angle < _eight) {
    return directionUp;
  }
  if (angle < _eight + (_quarter * 1)) {
    return directionUpRight;
  }
  if (angle < _eight + (_quarter * 2)) {
    return directionRight;
  }
  if (angle < _eight + (_quarter * 3)) {
    return directionDownRight;
  }
  if (angle < _eight + (_quarter * 4)) {
    return directionDown;
  }
  if (angle < _eight + (_quarter * 5)) {
    return directionDownLeft;
  }
  if (angle < _eight + (_quarter * 6)) {
    return directionLeft;
  }
  if (angle < _eight + (_quarter * 7)) {
    return directionUpLeft;
  }
  return directionUp;
}

// bool randomBool() {
//   return random.nextDouble() > 0.5;
// }
//
// int randomInt(int min, int max) {
//   return random.nextInt(max - min) + min;
// }
//
// T randomItem<T>(List<T> list) {
//   return list[random.nextInt(list.length)];
// }

Timer periodic(Function function, {int seconds = 0, int ms = 0}) {
  return Timer.periodic(Duration(seconds: seconds, milliseconds: ms), (timer) {
    function();
  });
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


