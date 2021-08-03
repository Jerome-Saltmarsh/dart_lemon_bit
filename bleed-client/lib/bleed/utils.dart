import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_maths.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'constants.dart';
import 'keys.dart';
import 'state.dart';

double getMouseRotation() {
  return round(getRadionsBetween(playerScreenPositionX(), playerScreenPositionY(), mousePosX, mousePosY));
}

double playerScreenPositionX() {
  return player[x] - cameraX;
}

double playerScreenPositionY() {
  return player[y] - cameraY;
}

dynamic getPlayerCharacter() {
  if (playerId == idNotConnected) return null;
  return players.firstWhere((element) => element[4] == playerId, orElse: () {
    return null;
  });
}

bool get playerAssigned => player != null;
double get playerX => player[x];
double get playerY => player[y];

bool isDead(dynamic character) {
  return getState(character) == characterStateDead;
}

void drawLine(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), globalPaint);
}

Offset offset(double x, double y) {
  return Offset(x - cameraX, y - cameraY);
}

void drawLineFrom(dynamic object, double x, double y) {
  drawLine(object[x], object[y], x, y);
}

void drawLineRotation(dynamic object, double rotation, double distance) {
  drawLine(
      object[x],
      object[y],
      object[x] + rotationToPosX(rotation, distance),
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

