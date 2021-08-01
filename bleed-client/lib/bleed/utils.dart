import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_maths.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'constants.dart';
import 'keys.dart';
import 'resources.dart';
import 'state.dart';

void playShotgunAudio() {
  shotgunFireAudio.play();
}

void playPistolAudio() {
  if (pistolFireAudio == null) return;
  pistolFireAudio.play();
}

double getMouseRotation() {
  return round(getRadionsBetween(playerScreenPositionX(), playerScreenPositionY(), mousePosX, mousePosY));
}
double playerScreenPositionX() {
  dynamic player = getPlayerCharacter();
  return player[posX] - cameraX;
}

double playerScreenPositionY() {
  if (!playerAssigned) return null;
  dynamic player = getPlayerCharacter();
  return player[posY] - cameraY;
}

dynamic getPlayerCharacter() {
  return playerCharacter;
}

bool get playerAssigned =>     playerCharacter != null;

bool isNpc(dynamic character) {
  return character[keyType] == typeNpc;
}

bool isHuman(dynamic character) {
  return character[keyType] == typeHuman;
}

bool isDead(dynamic character) {
  return getState(character) == characterStateDead;
}


void drawLine(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), globalPaint);
}

Offset offset(double x, double y){
  return Offset(x - cameraX, y - cameraY);
}

void drawLineFrom(dynamic object, double x, double y) {
  drawLine(object[posX], object[posY], x, y);
}

void drawLineRotation(dynamic object, double rotation, double distance) {
  drawLine(
      object[posX],
      object[posY],
      object[posX] + rotationToPosX(rotation, distance),
      object[posY] + rotationToPosY(rotation, distance)
  );
}

void drawLineBetween(dynamic a, dynamic b) {
  drawLineFrom(a, b[posX], b[posY]);
}

void drawLineNpcDestination(dynamic npc) {
  drawLineFrom(npc, npc[keyDestinationX], npc[keyDestinationY]);
}

dynamic rotationToPosX(double rotation, double distance) {
  return -cos(rotation + (pi * 0.5)) * distance;
}

dynamic rotationToPosY(double rotation, double distance) {
  return -sin(rotation + (pi * 0.5)) * distance;
}

bool idsMatch(dynamic a, dynamic b){
  return a[indexId] == b[indexId];
}

int getState(dynamic character){
  return character[state];
}

int getDirection(dynamic character){
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

get playerCharacter {
  if (playerId == idNotConnected) return null;
  return players.firstWhere((element) => element[4] == playerId, orElse: () {
    return null;
  });
}