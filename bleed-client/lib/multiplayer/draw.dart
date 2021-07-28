import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'keys.dart';
import 'multiplayer_resources.dart';
import 'state.dart';
import 'utils.dart';

void drawCharacter(dynamic character) {
  int totalFrames = 1;
  int startFrame = 0;

  switch (getState(character)) {
    case characterStateIdle:
      totalFrames = 1;
      switch (getDirection(character)) {
        case directionUp:
          startFrame = 3;
          break;
        case directionUpRight:
          startFrame = 0;
          break;
        case directionRight:
          startFrame = 1;
          break;
        case directionDownRight:
          startFrame = 2;
          break;
        case directionDown:
          startFrame = 3;
          break;
        case directionDownLeft:
          startFrame = 0;
          break;
        case directionLeft:
          startFrame = 1;
          break;
        case directionUpLeft:
          startFrame = 2;
          break;
      }
      break;
    case characterStateWalking:
      totalFrames = 3;
      switch (getDirection(character)) {
        case directionUp:
          startFrame = 13;
          break;
        case directionUpRight:
          startFrame = 4;
          break;
        case directionRight:
          startFrame = 7;
          break;
        case directionDownRight:
          startFrame = 10;
          break;
        case directionDown:
          startFrame = 13;
          break;
        case directionDownLeft:
          startFrame = 4;
          break;
        case directionLeft:
          startFrame = 7;
          break;
        case directionUpLeft:
          startFrame = 10;
          break;
      }
      break;
    case characterStateDead:
      switch (getDirection(character)) {
        case directionUp:
          startFrame = 19;
          break;
        case directionUpRight:
          startFrame = 16;
          break;
        case directionRight:
          startFrame = 17;
          break;
        case directionDownRight:
          startFrame = 19;
          break;
        case directionDown:
          startFrame = 19;
          break;
        case directionDownLeft:
          startFrame = 16;
          break;
        case directionLeft:
          startFrame = 17;
          break;
        case directionUpLeft:
          startFrame = 19;
          break;
      }
      break;
    case characterStateAiming:
      startFrame = getAimingSprite(character[direction]);
      break;
    case characterStateFiring:
      startFrame = getFiringSprite(character[direction]);
      break;
  }

  int spriteFrame = (drawFrame % totalFrames) + startFrame;
  int frameCount = 36;

  // drawCharacterCircle(
  //     character, character[keyCharacterId] == id ? Colors.blue : Colors.red);

  drawSprite(spriteTemplate, frameCount, spriteFrame, character[posX],
      character[posY]);

  // drawText(character[keyPlayerName], posX(character),
  //     posY(character), Colors.white);
}

int getAimingSprite(int direction) {
  switch (direction) {
    case directionUp:
      return 23;
    case directionUpRight:
      return 24;
    case directionRight:
      return 25;
    case directionDownRight:
      return 26;
    case directionDown:
      return 27;
    case directionDownLeft:
      return 20;
    case directionLeft:
      return 21;
    case directionUpLeft:
      return 22;
  }
  return 23;
}

int getFiringSprite(int direction) {
  switch (direction) {
    case directionUp:
      return 31;
    case directionUpRight:
      return 32;
    case directionRight:
      return 33;
    case directionDownRight:
      return 34;
    case directionDown:
      return 35;
    case directionDownLeft:
      return 28;
    case directionLeft:
      return 29;
    case directionUpLeft:
      return 30;
  }
  return 31;
}

void drawCharacterCircle(dynamic value, Color color) {
  drawCircle(value[posX], value[posY], characterRadius, color);
}


void drawCharacters() {
  if (spriteTemplate == null) return;
  players.sort((a, b) => a[posY] > b[posY] ? 1 : -1);
  players.where(isDead).forEach((drawCharacter));
  players.where(isAlive).forEach((drawCharacter));
  npcs.sort((a, b) => a[posY] > b[posY] ? 1 : -1);
  npcs.where(isDead).forEach((drawCharacter));
  npcs.where(isAlive).forEach((drawCharacter));
}


void drawCircleOutline(
    {int sides = 16, double radius, double x, double y, Color color}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  setColor(color);
  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points
        .add(Offset(cos(a1) * radius - cameraX, sin(a1) * radius - cameraY));
  }
  for (int i = 0; i < points.length - 1; i++) {
    canvas.drawLine(points[i] + z, points[i + 1] + z, globalPaint);
  }
}

void drawBullets() {
  bullets.forEach((bullet) {
    drawCircle(bullet['x'], bullet['y'], 2, white);
  });
}

void drawTiles() {
  if (tileGrass01 == null) return;

  double size = tileGrass01.width * 1.0;
  double sizeH = size * 0.5;

  int tiles = 5;

  for (int x = 0; x < tiles; x++) {
    drawGrassTile((sizeH * (5 - x)), (sizeH * x));
  }

  return;

  double d = 250;
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 0));
  drawGrassTile(d + (sizeH * 2), d + (sizeH * 1));
  drawGrassTile(d + (sizeH * 1), d + (sizeH * 2));
  drawGrassTile(d + (sizeH * 0), d + (sizeH * 3));

  drawGrassTile(d + (sizeH * 4), d + (sizeH * 1));
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 2));
  drawGrassTile(d + (sizeH * 2), d + (sizeH * 3));
  drawGrassTile(d + (sizeH * 1), d + (sizeH * 4));

  drawGrassTile(d + (sizeH * 5), d + (sizeH * 2));
  drawGrassTile(d + (sizeH * 4), d + (sizeH * 3));
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 4));
  drawGrassTile(d + (sizeH * 2), d + (sizeH * 5));

  drawGrassTile(d + (sizeH * 6), d + (sizeH * 3));
  drawGrassTile(d + (sizeH * 5), d + (sizeH * 4));
  drawGrassTile(d + (sizeH * 4), d + (sizeH * 5));
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 6));
}

void drawGrassTile(double x, double y) {
  drawImage(tileGrass01, x, y);
}


void setColor(Color value) {
  globalPaint.color = value;
}
