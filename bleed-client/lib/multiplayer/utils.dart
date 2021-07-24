import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_maths.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'multiplayer_resources.dart';
import 'state.dart';

void playShotgunAudio() {
  shotgunFireAudio.play();
}

void playPistolAudio() {
  if (pistolFireAudio == null) return;
  pistolFireAudio.play();
}

double playerScreenPositionX() {
  dynamic player = getPlayerCharacter();
  return posX(player) - cameraX;
}

double playerScreenPositionY() {
  if (!playerAssigned) return null;
  dynamic player = getPlayerCharacter();
  return posY(player) - cameraY;
}

double getMouseRotation() {
  dynamic player = getPlayerCharacter();
  double playerScreenPositionX = posX(player) - cameraX;
  double playerScreenPositionY = posY(player) - cameraY;
  return getRadionsBetween(
      playerScreenPositionX, playerScreenPositionY, mousePosX, mousePosY);
}

dynamic getPlayerCharacter() {
  return characters.firstWhere((element) => element[indexId] == id,
      orElse: () => null);
}

bool get playerAssigned =>
    characters.any((element) => element[indexId] == id);

bool isNpc(dynamic character) {
  return character[keyType] == typeNpc;
}

bool isHuman(dynamic character) {
  return character[keyType] == typeHuman;
}

bool isDead(dynamic character) {
  return getState(character) == characterStateDead;
}

List<dynamic> getNpcs() {
  return characters.where(isNpc).toList();
}

void drawLine(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), globalPaint);
}

Offset offset(double x, double y){
  return Offset(x - cameraX, y - cameraY);
}

void drawLineFrom(dynamic object, double x, double y) {
  drawLine(posX(object), posY(object), x, y);
}

void drawLineRotation(dynamic object, double rotation, double distance) {
  drawLine(
      posX(object),
      posY(object),
      posX(object) + rotationToPosX(rotation, distance),
      posY(object) + rotationToPosY(rotation, distance)
  );
}

void drawLineBetween(dynamic a, dynamic b) {
  drawLineFrom(a, posX(b), posY(b));
}

void drawLineNpcDestination(dynamic npc) {
  drawLineFrom(npc, npc[keyDestinationX], npc[keyDestinationY]);
}

void drawLineNpcTarget(dynamic npc) {
  drawLineBetween(npc, npcTarget(npc));
}

void drawNpcDebugLines(dynamic npc) {
  if (npc[keyNpcTargetId] != null) {
    drawLineNpcTarget(npc);
  } else if (npc[keyDestinationX] != null) {
    drawLineNpcDestination(npc);
  }
}

dynamic npcTarget(dynamic character) {
  return findCharacterById(character[keyNpcTargetId]);
}

dynamic findCharacterById(int id) {
  return characters.firstWhere((element) => element[indexId] == id,
      orElse: () {
    return null;
  });
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
  return character[indexState];
}

int getDirection(dynamic character){
  return character[indexDirection];
}

double posX(dynamic value) {
  return value[indexPosX];
}

double posY(dynamic value) {
  return value[indexPosY];
}