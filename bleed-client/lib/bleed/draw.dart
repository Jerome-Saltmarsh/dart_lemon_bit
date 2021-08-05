import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/enums.dart';
import 'package:flutter_game_engine/bleed/maths.dart';
import 'package:flutter_game_engine/bleed/rects.dart';
import 'package:flutter_game_engine/game_engine/engine_draw.dart';
import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'keys.dart';
import 'images.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void drawCharacterCircle(dynamic value, Color color) {
  if (value == null) return;
  drawCircle(value[x], value[y] + 5, characterRadius, color);
}

void drawCharacters() {
  if (imageHuman == null) return;
  drawPlayers();
  drawNpcs();
}

void drawNpcs() {
  drawList(npcs, npcsTransforms, npcsRects);
}

void drawCharacterList(List<dynamic> characters) {
  globalCanvas.drawAtlas(
      imageHuman,
      characters.map(getCharacterTransform).toList(),
      characters.map(getCharacterSpriteRect).toList(),
      null,
      null,
      null,
      globalPaint);
}

void drawTileList() {
  processTileTransforms();
  if (tileRects.isEmpty) {
    processRects();
  }
  globalCanvas.drawAtlas(
      imageTiles, tileTransforms, tileRects, null, null, null, globalPaint);
}

void processTileTransforms() {
  tileTransforms.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      tileTransforms.add(getTileTransform(x, y));
    }
  }
}

void processRects() {
  tileRects.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      tileRects.add(getTileSpriteRect(tiles[x][y]));
    }
  }
}

void drawPlayers() {
  drawList(players, playersTransforms, playersRects);
}

void drawList(
    List<dynamic> values, List<RSTransform> transforms, List<Rect> rects) {
  for (int i = 0; i < values.length; i++) {
    if (i >= transforms.length) {
      transforms.add(getCharacterTransform(values[i]));
    } else {
      transforms[i] = getCharacterTransform(values[i]);
    }
    if (i >= rects.length) {
      rects.add(getCharacterSpriteRect(values[i]));
    } else {
      rects[i] = getCharacterSpriteRect(values[i]);
    }
  }
  while (transforms.length > values.length) {
    transforms.removeLast();
  }
  while (rects.length > values.length) {
    rects.removeLast();
  }
  globalCanvas.drawAtlas(
      imageHuman, transforms, rects, null, null, null, globalPaint);
}

Rect getHumanWalkingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(rectHumanWalkingUpFrames);
    case directionUpRight:
      return _getFrame(rectHumanWalkingDownLeftFrames);
    case directionRight:
      return _getFrame(rectHumanWalkingLeftFrames);
    case directionDownRight:
      return _getFrame(rectHumanWalkingUpLeftFrames);
    case directionDown:
      return _getFrame(rectHumanWalkingUpFrames);
    case directionDownLeft:
      return _getFrame(rectHumanWalkingDownLeftFrames);
    case directionLeft:
      return _getFrame(rectHumanWalkingLeftFrames);
    case directionUpLeft:
      return _getFrame(rectHumanWalkingUpLeftFrames);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getHumanRunningRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(rectHumanRunningUpFrames);
    case directionUpRight:
      return _getFrame(rectHumanRunningUpRightFrames);
    case directionRight:
      return _getFrame(rectHumanRunningRightFrames);
    case directionDownRight:
      return _getFrame(rectHumanRunningDownRightFrames);
    case directionDown:
      return _getFrame(rectHumanRunningDownFrames);
    case directionDownLeft:
      return _getFrame(rectHumanRunningDownLeftFrames);
    case directionLeft:
      return _getFrame(rectHumanRunningLeftFrames);
    case directionUpLeft:
      return _getFrame(rectHumanRunningUpLeftFrames);
  }
  throw Exception("Could not get character walking sprite rect");
}


Rect getHumanIdleRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rectHumanIdleUp;
    case directionUpRight:
      return rectHumanIdleUpRight;
    case directionRight:
      return rectHumanIdleRight;
    case directionDownRight:
      return rectHumanIdleDownRight;
    case directionDown:
      return rectHumanIdleDown;
    case directionDownLeft:
      return rectHumanIdleDownLeft;
    case directionLeft:
      return rectHumanIdleLeft;
    case directionUpLeft:
      return rectHumanIdleUpLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getHumanDeadRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rectHumanDeadDown;
    case directionUpRight:
      return rectHumanDeadUpRight;
    case directionRight:
      return rectHumanDeadRight;
    case directionDownRight:
      return rectHumanDeadDownRight;
    case directionDown:
      return rectHumanDeadDown;
    case directionDownLeft:
      return rectHumanDeadUpRight;
    case directionLeft:
      return rectHumanDeadRight;
    case directionUpLeft:
      return rectHumanDeadDownRight;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect getHumanAimRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rectHumanAimingUp;
    case directionUpRight:
      return rectHumanAimingUpRight;
    case directionRight:
      return rectHumanAimingRight;
    case directionDownRight:
      return rectHumanAimingDownRight;
    case directionDown:
      return rectHumanAimingDown;
    case directionDownLeft:
      return rectHumanAimingDownLeft;
    case directionLeft:
      return rectHumanAimingLeft;
    case directionUpLeft:
      return rectHumanAimingUpLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect tileRectConcrete = getTileSpriteRectByIndex(0);
Rect tileRectGrass = getTileSpriteRectByIndex(1);

Rect getTileSpriteRectByIndex(int index) {
  return rectByIndex(
      index, tileCanvasWidth.toDouble(), tileCanvasHeight.toDouble());
}

Rect rectByIndex(int index, double frameWidth, double height) {
  return Rect.fromLTWH(index * frameWidth, 0.0, frameWidth, height);
}

Rect getTileSpriteRect(Tile tile) {
  switch (tile) {
    case Tile.Concrete:
      return tileRectConcrete;
    case Tile.Grass:
      return tileRectGrass;
  }
  throw Exception("could not find rect for tile $tile");
}

Rect getCharacterSpriteRect(dynamic character) {
  switch (character[state]) {
    case characterStateIdle:
      return getHumanIdleRect(character);
    case characterStateWalking:
      return getHumanWalkingRect(character);
    case characterStateDead:
      return getHumanDeadRect(character);
    case characterStateAiming:
      return getHumanAimRect(character);
    case characterStateFiring:
      return getHumanFiringRect(character);
    case characterStateStriking:
      return getHumanStrikingRect(character);
    case characterStateRunning:
      return getHumanRunningRect(character);
  }
  throw Exception("Could not get character sprite rect");
}

Rect getHumanFiringRect(character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(rectHumanFiringUpFrames);
    case directionUpRight:
      return _getFrame(rectHumanFiringUpRightFrames);
    case directionRight:
      return _getFrame(rectHumanFiringRightFrames);
    case directionDownRight:
      return _getFrame(rectHumanFiringDownRightFrames);
    case directionDown:
      return _getFrame(rectHumanFiringDownFrames);
    case directionDownLeft:
      return _getFrame(rectHumanFiringDownLeftFrames);
    case directionLeft:
      return _getFrame(rectHumanFiringLeftFrames);
    case directionUpLeft:
      return _getFrame(rectHumanFiringUpLeftFrames);
  }
  throw Exception("could not get firing frame from direction");
}

Rect getHumanStrikingRect(character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(humanStrikingUpFrames);
    case directionUpRight:
      return _getFrame(humanStrikingUpRightFrames);
    case directionRight:
      return _getFrame(humanStrikingRightFrames);
    case directionDownRight:
      return _getFrame(humanStrikingDownRightFrames);
    case directionDown:
      return _getFrame(humanStrikingDownFrames);
    case directionDownLeft:
      return _getFrame(humanStrikingDownLeftFrames);
    case directionLeft:
      return _getFrame(humanStrikingLeftFrames);
    case directionUpLeft:
      return _getFrame(humanStrikingUpLeftFrames);
  }
  throw Exception("could not get firing frame from direction");
}

List<Rect> humanStrikingDownLeftFrames = [
  rectHumanStrikingDownLeft,
  rectHumanIdleDownLeft
];

List<Rect> humanStrikingLeftFrames = [rectHumanStrikingLeft, rectHumanIdleLeft];

List<Rect> humanStrikingUpLeftFrames = [
  rectHumanStrikingUpLeft,
  rectHumanIdleUpLeft
];

List<Rect> humanStrikingUpFrames = [rectHumanStrikingUp, rectHumanIdleUp];

List<Rect> humanStrikingUpRightFrames = [
  rectHumanStrikingUpRight,
  rectHumanIdleUpRight
];

List<Rect> humanStrikingRightFrames = [
  rectHumanStrikingRight,
  rectHumanIdleRight
];

List<Rect> humanStrikingDownRightFrames = [
  rectHumanStrikingDownRight,
  rectHumanIdleDownRight
];

List<Rect> humanStrikingDownFrames = [rectHumanStrikingDown, rectHumanIdleDown];

Rect _getFrame(List<Rect> frames) {
  return frames[drawFrame % frames.length];
}

const int humanSpriteFrames = 73;
const int humanSpriteFrameWidth = 48;
const int humanSpriteFrameHeight = 72;
const int humanSpriteImageWidth = humanSpriteFrames * humanSpriteFrameWidth;
const double halfHumanSpriteFrameWidth = humanSpriteFrameWidth * 0.5;
const double halfHumanSpriteFrameHeight = humanSpriteFrameHeight * 0.5;

Rect rectHumanIdleDownLeft = getHumanSpriteRect(0);
Rect rectHumanIdleLeft = getHumanSpriteRect(1);
Rect rectHumanIdleUpLeft = getHumanSpriteRect(2);
Rect rectHumanIdleUp = getHumanSpriteRect(3);
Rect rectHumanIdleUpRight = rectHumanIdleDownLeft;
Rect rectHumanIdleRight = rectHumanIdleLeft;
Rect rectHumanIdleDownRight = rectHumanIdleUpLeft;
Rect rectHumanIdleDown = rectHumanIdleUp;

Rect rectHumanRunningDownLeft1 = _humanRect(53);
Rect rectHumanRunningDownLeft2 = _humanRect(54);
Rect rectHumanRunningDownLeft3 = _humanRect(55);

Rect rectHumanRunningLeft1 = _humanRect(56);
Rect rectHumanRunningLeft2 = _humanRect(57);
Rect rectHumanRunningLeft3 = _humanRect(58);

Rect rectHumanRunningUpLeft1 = _humanRect(59);
Rect rectHumanRunningUpLeft2 = _humanRect(60);
Rect rectHumanRunningUpLeft3 = _humanRect(61);

Rect rectHumanRunningUp1 = _humanRect(62);
Rect rectHumanRunningUp2 = _humanRect(63);
Rect rectHumanRunningUp3 = _humanRect(64);

Rect rectHumanRunningUpRight1 = _humanRect(65);
Rect rectHumanRunningUpRight2 = _humanRect(66);
Rect rectHumanRunningUpRight3 = _humanRect(67);

Rect rectHumanRunningRight1 = _humanRect(68);
Rect rectHumanRunningRight2 = _humanRect(69);
Rect rectHumanRunningRight3 = _humanRect(70);

Rect rectHumanRunningDownRight1 = _humanRect(71);
Rect rectHumanRunningDownRight2 = _humanRect(72);
Rect rectHumanRunningDownRight3 = _humanRect(73);

Rect rectHumanRunningDown1 = rectHumanRunningUp1;
Rect rectHumanRunningDown2 = rectHumanRunningUp2;
Rect rectHumanRunningDown3 = rectHumanRunningUp3;

Rect rectHumanDeadUpRight = getHumanSpriteRect(16);
Rect rectHumanDeadRight = getHumanSpriteRect(17);
Rect rectHumanDeadDownRight = getHumanSpriteRect(18);
Rect rectHumanDeadDown = getHumanSpriteRect(19);

Rect rectHumanAimingDownLeft = getHumanSpriteRect(20);
Rect rectHumanAimingLeft = getHumanSpriteRect(21);
Rect rectHumanAimingUpLeft = getHumanSpriteRect(22);
Rect rectHumanAimingUp = getHumanSpriteRect(23);
Rect rectHumanAimingUpRight = getHumanSpriteRect(24);
Rect rectHumanAimingRight = getHumanSpriteRect(25);
Rect rectHumanAimingDownRight = getHumanSpriteRect(26);
Rect rectHumanAimingDown = getHumanSpriteRect(27);

Rect rectHumanFiringDownLeft = getHumanSpriteRect(28);
Rect rectHumanFiringLeft = getHumanSpriteRect(29);
Rect rectHumanFiringUpLeft = getHumanSpriteRect(30);
Rect rectHumanFiringUp = getHumanSpriteRect(31);
Rect rectHumanFiringUpRight = getHumanSpriteRect(32);
Rect rectHumanFiringRight = getHumanSpriteRect(33);
Rect rectHumanFiringDownRight = getHumanSpriteRect(34);
Rect rectHumanFiringDown = getHumanSpriteRect(35);

Rect rectHumanStrikingDownLeft = getHumanSpriteRect(36);
Rect rectHumanStrikingLeft = getHumanSpriteRect(37);
Rect rectHumanStrikingUpLeft = getHumanSpriteRect(38);
Rect rectHumanStrikingUp = getHumanSpriteRect(39);
Rect rectHumanStrikingUpRight = getHumanSpriteRect(40);
Rect rectHumanStrikingRight = getHumanSpriteRect(41);
Rect rectHumanStrikingDownRight = getHumanSpriteRect(42);
Rect rectHumanStrikingDown = getHumanSpriteRect(43);

Rect rectHumanBlastDownLeft = getHumanSpriteRect(44);
Rect rectHumanBlastLeft = getHumanSpriteRect(45);
Rect rectHumanBlastUpLeft = getHumanSpriteRect(46);
Rect rectHumanBlastUp = getHumanSpriteRect(47);
Rect rectHumanBlastUpRight = getHumanSpriteRect(48);
Rect rectHumanBlastRight = getHumanSpriteRect(49);
Rect rectHumanBlastDownRight = getHumanSpriteRect(50);
Rect rectHumanBlastDown = getHumanSpriteRect(51);

List<Rect> rectHumanFiringDownLeftFrames = [
  rectHumanBlastDownLeft,
  rectHumanFiringDownLeft,
  rectHumanAimingDownLeft,
];

List<Rect> rectHumanFiringLeftFrames = [
  rectHumanBlastLeft,
  rectHumanFiringLeft,
  rectHumanAimingLeft,
];

List<Rect> rectHumanFiringUpLeftFrames = [
  rectHumanBlastUpLeft,
  rectHumanFiringUpLeft,
  rectHumanAimingUpLeft,
];

List<Rect> rectHumanFiringUpFrames = [
  rectHumanBlastUp,
  rectHumanFiringUp,
  rectHumanAimingUp,
];

List<Rect> rectHumanFiringUpRightFrames = [
  rectHumanBlastUpRight,
  rectHumanFiringUpRight,
  rectHumanAimingUpRight,
];

List<Rect> rectHumanFiringRightFrames = [
  rectHumanBlastRight,
  rectHumanFiringRight,
  rectHumanAimingRight,
];

List<Rect> rectHumanFiringDownRightFrames = [
  rectHumanBlastDownRight,
  rectHumanFiringDownRight,
  rectHumanAimingDownRight,
];

List<Rect> rectHumanFiringDownFrames = [
  rectHumanBlastDown,
  rectHumanFiringDown,
  rectHumanAimingDown,
];

List<Rect> rectHumanWalkingDownLeftFrames = [
  getHumanSpriteRect(4),
  getHumanSpriteRect(5),
  getHumanSpriteRect(6),
];

List<Rect> rectHumanWalkingLeftFrames = [
  getHumanSpriteRect(7),
  getHumanSpriteRect(8),
  getHumanSpriteRect(9),
];

List<Rect> rectHumanWalkingUpLeftFrames = [
  getHumanSpriteRect(10),
  getHumanSpriteRect(11),
  getHumanSpriteRect(12),
];

List<Rect> rectHumanWalkingUpFrames = [
  getHumanSpriteRect(13),
  getHumanSpriteRect(14),
  getHumanSpriteRect(15)
];

// RUNNING

List<Rect> rectHumanRunningDownLeftFrames = [
  rectHumanRunningDownLeft1,
  rectHumanRunningDownLeft2,
  rectHumanRunningDownLeft3,
];

List<Rect> rectHumanRunningLeftFrames = [
  rectHumanRunningLeft1,
  rectHumanRunningLeft2,
  rectHumanRunningLeft3,
];

List<Rect> rectHumanRunningUpLeftFrames = [
  rectHumanRunningUpLeft1,
  rectHumanRunningUpLeft2,
  rectHumanRunningUpLeft3,
];

List<Rect> rectHumanRunningUpFrames = [
  rectHumanRunningUp1,
  rectHumanRunningUp2,
  rectHumanRunningUp3,
];

List<Rect> rectHumanRunningUpRightFrames = [
  rectHumanRunningUpRight1,
  rectHumanRunningUpRight2,
  rectHumanRunningUpRight3,
];

List<Rect> rectHumanRunningRightFrames = [
  rectHumanRunningRight1,
  rectHumanRunningRight2,
  rectHumanRunningRight3,
];

List<Rect> rectHumanRunningDownRightFrames = [
  rectHumanRunningDownRight1,
  rectHumanRunningDownRight2,
  rectHumanRunningDownRight3,
];

List<Rect> rectHumanRunningDownFrames = [
  rectHumanRunningDown1,
  rectHumanRunningDown2,
  rectHumanRunningDown3,
];

Rect getHumanSpriteRect(int index) {
  return Rect.fromLTWH((index * humanSpriteFrameWidth).toDouble(), 0.0,
      humanSpriteFrameWidth.toDouble(), humanSpriteFrameHeight.toDouble());
}

Rect _humanRect(int index){
  return getHumanSpriteRect(index - 1);
}

RSTransform getCharacterTransform(dynamic character) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfHumanSpriteFrameWidth,
    anchorY: halfHumanSpriteFrameHeight - 5,
    translateX: character[x] - cameraX,
    translateY: character[y] - cameraY,
  );
}

RSTransform rsTransform({double x, double y, double anchorX, double anchorY, double scale = 1}){
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: scale,
    anchorX: anchorX,
    anchorY: anchorY,
    translateX: x - cameraX,
    translateY: y - cameraY,
  );
}

void drawPlayerHealth() {
  if (!playerAssigned) return;

  double health = playerHealth / playerMaxHealth;
  double halfMaxHealth = playerMaxHealth * 0.5;
  if (health > 0.5) {
    drawCharacterCircle(
        player,
        Color.lerp(Colors.yellow, Colors.green,
            (playerHealth - halfMaxHealth) / halfMaxHealth));
  } else {
    drawCharacterCircle(player,
        Color.lerp(Colors.red, Colors.yellow, playerHealth / halfMaxHealth));
  }
}

RSTransform getTileTransform(int x, int y) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfTileSize,
    anchorY: 74,
    translateX: (-y * halfTileSize) + (x * halfTileSize) - cameraX,
    translateY: (y * halfTileSize) + (x * halfTileSize) - cameraY,
  );
}

void drawCircleOutline(
    {int sides = 16, double radius, double x, double y, Color color}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  setColor(color);
  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points.add(Offset(cos(a1) * radius - cameraX, sin(a1) * radius - cameraY));
  }
  for (int i = 0; i < points.length - 1; i++) {
    globalCanvas.drawLine(points[i] + z, points[i + 1] + z, globalPaint);
  }
}

void drawMouse() {
  if (!mouseAvailable) return;
  drawCircleOutline(
      radius: 5, x: mousePosX + cameraX, y: mousePosY + cameraY, color: white);
}

void drawTiles() {
  if (tileGrass01 == null) return;
  if (imageTiles == null) return;
  if (tiles == null || tiles.isEmpty) return;
  drawTileList();
}

void drawTile(int x, int y) {
  drawGrassTile((tileCanvasWidth * (tilesX - x).toDouble()),
      (tileCanvasHeight * x).toDouble());
}

void drawGrassTile(double x, double y) {
  drawImage(tileGrass01, x, y);
}

void setColor(Color value) {
  globalPaint.color = value;
}

void drawBulletRange() {
  if (!playerAssigned) return;
  dynamic player = getPlayerCharacter();
  drawCircleOutline(
      radius: bulletRange, x: player[x], y: player[y], color: white);
}

void drawBlood() {
  for (int i = 0; i < blood.length; i += 2) {
    drawCircle(blood[i], blood[i + 1], 2, Colors.red);
  }
}

void drawBulletHoles(){
  for(int i = 0; i < bulletHoles.length; i += 2){
    drawCircle(bulletHoles[i], bulletHoles[i + 1], 2, Colors.black);
  }
}

void drawParticles() {
  for (int i = 0; i < particles.length; i += 4) {
    switch(ParticleType.values[particles[i + 2].toInt()]){
      case ParticleType.Shell:
        drawCircle(particles[i], particles[i + 1], 1.33, Colors.white);
        break;
      case ParticleType.Blood:
        drawCircle(particles[i], particles[i + 1], 2, Colors.red);
        break;
      case ParticleType.Head:
        drawCircle(particles[i], particles[i + 1], 5, Colors.white);
        break;
      case ParticleType.Arm:
        double rotation = particles[i + 3];
        double length = 5;
        double handX = particles[i] + velX(rotation, length);
        double handY = particles[i + 1] + velY(rotation, length);
        drawLine3(particles[i], particles[i + 1], handX, handY);
        drawCircle(handX, handY, 2, Colors.white);
        break;
      case ParticleType.Organ:
        drawCircle(particles[i], particles[i + 1], 2, Colors.white);
        break;
    }
  }
}
