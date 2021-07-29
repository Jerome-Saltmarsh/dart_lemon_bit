import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_maths.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
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
  return getRadionsBetween(playerScreenPositionX(), playerScreenPositionY(), mousePosX, mousePosY);
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
