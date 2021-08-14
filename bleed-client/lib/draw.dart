import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

import 'common.dart';
import '../images.dart';
import 'enums.dart';
import 'keys.dart';
import 'rects.dart';
import 'state.dart';
import 'utils.dart';

void drawCharacterCircle(double x, double y, Color color) {
  drawCircle(x, y, 10, color);
}

void drawCharacters() {
  if (imageCharacter == null) return;
  drawPlayers();
  drawNpcs();
}

void drawNpcs() {
  npcs.sort((a, b) {
    if (a[y] < b[y]) return -1;
    return 1;
  });
  drawList(npcs, npcsTransforms, npcsRects);
}

void drawCharacterList(List<dynamic> characters) {
  globalCanvas.drawAtlas(
      imageCharacter,
      characters.map(getCharacterTransform).toList(),
      characters.map(getCharacterSpriteRect).toList(),
      null,
      null,
      null,
      globalPaint);
}

void drawTileList() {
  if (tileTransforms.isEmpty) {
    processTileTransforms();
  }
  if (tileRects.isEmpty) {
    loadTileRects();
  }
  drawAtlases(imageTiles, tileTransforms, tileRects);
}

void drawAtlases(
    ui.Image image, List<RSTransform> transforms, List<Rect> rects) {
  globalCanvas.drawAtlas(image, transforms, rects, null, null, null, globalPaint);
}

void processTileTransforms() {
  tileTransforms.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      tileTransforms.add(getTileTransform(x, y));
    }
  }
}

void loadTileRects() {
  tileRects.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      tileRects.add(getTileSpriteRect(tiles[x][y]));
    }
  }
}

void drawPlayers() {
  players.sort((a, b) {
    if (a[y] < b[y]) return -1;
    return 1;
  });
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

  drawAtlases(imageCharacter, transforms, rects);
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

Rect getHumanReloadingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(rectsHumanReloadingUp);
    case directionUpRight:
      return _getFrame(rectsHumanReloadingUpRight);
    case directionRight:
      return _getFrame(rectsHumanReloadingRight);
    case directionDownRight:
      return _getFrame(rectsHumanReloadingDownRight);
    case directionDown:
      return _getFrame(rectsHumanReloadingDown);
    case directionDownLeft:
      return _getFrame(rectsHumanReloadingDownLeft);
    case directionLeft:
      return _getFrame(rectsHumanReloadingLeft);
    case directionUpLeft:
      return _getFrame(rectsHumanReloadingUpLeft);
  }
  throw Exception("Could not get character reloading sprite rect");
}

List<int> characterRunningUp = [12, 51, 55];

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
    case characterStateReloading:
      return getHumanReloadingRect(character);
    case characterStateChangingWeapon:
      return getHumanReloadingRect(character);
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

const int humanSpriteFrames = 89;
const int humanSpriteFrameWidth = 36;
const int humanSpriteFrameHeight = 35;
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

// Reloading

List<Rect> rectsHumanReloadingDownLeft = humanRects([74, 74, 74, 75, 75, 75]);
List<Rect> rectsHumanReloadingLeft = humanRects([76, 76, 76, 77, 77, 77]);
List<Rect> rectsHumanReloadingUpLeft = humanRects([78, 78, 78, 79, 79, 79]);
List<Rect> rectsHumanReloadingUp = humanRects([80, 80, 80, 81, 81, 81]);
List<Rect> rectsHumanReloadingUpRight = humanRects([82, 82, 82, 83, 83, 83]);
List<Rect> rectsHumanReloadingRight = humanRects([84, 84, 84, 85, 85, 85]);
List<Rect> rectsHumanReloadingDownRight = humanRects([86, 86, 86, 87, 87, 87]);
List<Rect> rectsHumanReloadingDown = humanRects([88, 88, 88, 89, 89, 89]);

// List<Rect> rectHumanReloadingFrames

List<Rect> humanRects(List<int> indexes) {
  List<Rect> rects = [];
  for (int i in indexes) {
    rects.add(getHumanSpriteRect(i - 1));
  }
  return rects;
}

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

Rect _humanRect(int index) {
  return getHumanSpriteRect(index - 1);
}

RSTransform getCharacterTransform(dynamic character) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfHumanSpriteFrameWidth,
    anchorY: halfHumanSpriteFrameHeight + 5,
    translateX: character[x],
    translateY: character[y],
  );
}

RSTransform rsTransform(
    {double x, double y, double anchorX, double anchorY, double scale = 1}) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: scale,
    anchorX: anchorX,
    anchorY: anchorY,
    translateX: x,
    translateY: y,
  );
}

void drawPlayerHealth() {
  if (!playerAssigned) return;

  double health = playerHealth / playerMaxHealth;
  double halfMaxHealth = playerMaxHealth * 0.5;
  if (health > 0.5) {
    drawCharacterCircle(
        playerX,
        playerY,
        Color.lerp(Colors.yellow, Colors.green,
            (playerHealth - halfMaxHealth) / halfMaxHealth));
  } else {
    drawCharacterCircle(playerX, playerY,
        Color.lerp(Colors.red, Colors.yellow, playerHealth / halfMaxHealth));
  }
}

RSTransform getTileTransform(int x, int y) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfTileSize,
    anchorY: 36,
    translateX: (-y * halfTileSize) + (x * halfTileSize),
    translateY: (y * halfTileSize) + (x * halfTileSize) + tileCanvasWidth,
  );
}

void drawCircleOutline(
    {int sides = 6, double radius, double x, double y, Color color}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  setColor(color);
  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points.add(Offset(cos(a1) * radius, sin(a1) * radius));
  }
  for (int i = 0; i < points.length - 1; i++) {
    globalCanvas.drawLine(points[i] + z, points[i + 1] + z, globalPaint);
  }
}

void drawMouse() {
  if (!mouseAvailable) return;
  drawCircleOutline(radius: 5, x: mouseWorldX, y: mouseWorldY, color: white);
}

void drawTiles() {
  if (imageTiles == null) return;
  if (tiles == null || tiles.isEmpty) return;
  drawTileList();
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

void drawBulletHoles() {
  for (int i = 0; i < bulletHoles.length; i += 2) {
    drawCircle(bulletHoles[i], bulletHoles[i + 1], 2, Colors.black);
  }
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
