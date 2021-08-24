import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_maths.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

import 'common.dart';
import 'constants.dart';
import 'enums/Weapons.dart';
import 'instances/game.dart';
import 'keys.dart';
import 'maths.dart';

double getMouseRotation() {
  return getRadiansBetween(
      game.playerX, game.playerY, mouseWorldX, mouseWorldY);
}

double playerScreenPositionX() {
  return game.playerX - cameraX;
}

double playerScreenPositionY() {
  return game.playerY - cameraY;
}

// dynamic getPlayerCharacter() {
//   if (game.playerId == idNotConnected) return null;
//   return game.players.firstWhere((element) => element[4] == game.playerId,
//       orElse: () {
//     return null;
//   });
// }

bool get playerAssigned => game.playerId >= 0;

Weapon previousWeapon;

bool isDead(dynamic character) {
  return getState(character) == characterStateDead;
}

void drawLine(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), globalPaint);
}

void drawLine2(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), paint2);
}

void drawLine3(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), paint3);
}

void drawCustomLine(double x1, double y1, double x2, double y2, Paint paint) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), paint);
}

Offset offset(double x, double y) {
  return Offset(x, y);
}

void drawLineFrom(dynamic object, double x, double y) {
  drawLine(object[x], object[y], x, y);
}

void drawLineRotation(dynamic object, double rotation, double distance) {
  drawLine(object[x], object[y], object[x] + rotationToPosX(rotation, distance),
      object[y] + rotationToPosY(rotation, distance));
}

void drawLineBetween(dynamic a, dynamic b) {
  drawLineFrom(a, b[x], b[y]);
}

dynamic rotationToPosX(double rotation, double distance) {
  return -cos(rotation + (pi * 0.5)) * distance;
}

dynamic rotationToPosY(double rotation, double distance) {
  return -sin(rotation + (pi * 0.5)) * distance;
}

int getState(dynamic character) {
  return character[state];
}

int getDirection(dynamic character) {
  return character[direction];
}

bool isAlive(dynamic character) {
  return getState(character) != characterStateDead;
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

bool randomBool() {
  return random.nextDouble() > 0.5;
}

int randomInt(int min, int max) {
  return random.nextInt(max - min) + min;
}

T randomItem<T>(List<T> list) {
  return list[random.nextInt(list.length)];
}

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
  cameraX = x - (screenCenterX / zoom);
  cameraY = y - (screenCenterY / zoom);
}

void setHandgunRounds(int value) {
  if (game.handgunRounds == value) return;
  game.handgunRounds = value;
  // TODO only redraw ammo box
  redrawUI();
}

