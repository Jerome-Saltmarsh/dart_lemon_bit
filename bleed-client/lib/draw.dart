import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:bleed_client/classes/InteractableNpc.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/engine/functions/drawCircle.dart';
import 'package:bleed_client/engine/functions/drawText.dart';
import 'package:bleed_client/engine/functions/onScreen.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/functions/drawCanvas.dart';
import 'package:bleed_client/mappers/mapTileToRect.dart';
import 'package:bleed_client/mappers/mapZombieToRect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../images.dart';
import 'classes/Human.dart';
import 'common/Weapons.dart';
import 'common/classes/Vector2.dart';
import 'common/Tile.dart';
import 'rects.dart';
import 'mappers/mapHumanToRect.dart';
import 'state.dart';
import 'state/colours.dart';
import 'state/isWaterAt.dart';
import 'utils.dart';

void drawCharacterCircle(double x, double y, Color color) {
  drawCircle(x, y, 10, color);
}

void drawCharacters() {
  if (images.human == null) return;
  // drawPlayers();
  drawZombies();
  drawInteractableNpcs();
}

void drawInteractableNpcs() {
  render.npcs.rects.clear();
  render.npcs.transforms.clear();

  for (int i = 0; i < compiledGame.totalNpcs; i++) {
    InteractableNpc interactableNpc = compiledGame.interactableNpcs[i];
    render.npcs.transforms.add(
        mapHumanToRSTransform(interactableNpc.x, interactableNpc.y)
    );

    render.npcs.rects.add(
        mapHumanToRect(
            Weapon.HandGun,
            interactableNpc.state,
            interactableNpc.direction,
            interactableNpc.frame
        )
    );

    if (diffOver(interactableNpc.x, mouseWorldX, 50)) continue;
    if (diffOver(interactableNpc.y, mouseWorldY, 50)) continue;
    drawText(compiledGame.interactableNpcs[i].name, interactableNpc.x - charWidth * compiledGame.interactableNpcs[i].name.length,
        interactableNpc.y);
  }

  drawAtlases(images.human, render.npcs.transforms, render.npcs.rects);
}

void drawZombies() {
  render.zombiesTransforms.clear();
  render.zombieRects.clear();

  for (int i = 0; i < compiledGame.totalZombies; i++) {
    Zombie zombie = compiledGame.zombies[i];
    if (!zombie.alive) {
      if (isWaterAt(zombie.x, zombie.y)){
        continue;
      }
    }
    if (!onScreen(zombie.x, zombie.y)){
      continue;
    }

    render.zombiesTransforms.add(
        mapZombieToRSTransform(zombie)
    );
    render.zombieRects.add(
        mapZombieToRect(zombie)
    );
  }

  drawAtlases(images.zombie, render.zombiesTransforms, render.zombieRects);
}

void drawTileList() {
  globalCanvas.drawRawAtlas(
      images.tiles,
      render.tilesRstTransforms,
      render.tilesRects,
      null,
      null,
      null,
      paint
  );
}

void drawAtlases(
    ui.Image image, List<RSTransform> transforms, List<Rect> rects) {
  
  globalCanvas.drawAtlas(
      image, transforms, rects, null, null, null, paint);
}

void renderTiles(List<List<Tile>> tiles) {
  _processTileTransforms(tiles);
  _loadTileRects(tiles);

  List<Rect> rects = render.tileRects;
  List<RSTransform> rsTransform = render.tileTransforms;

  int total = rects.length * 4;
  Float32List rstTransformBuffer = Float32List(total);
  Float32List tileRects = Float32List(total);

  for (int i = 0; i < rects.length; ++i) {
    final int index0 = i * 4;
    final int index1 = index0 + 1;
    final int index2 = index0 + 2;
    final int index3 = index0 + 3;
    final RSTransform rstTransform = rsTransform[i];
    final Rect rect = rects[i];
    rstTransformBuffer[index0] = rstTransform.scos;
    rstTransformBuffer[index1] = rstTransform.ssin;
    rstTransformBuffer[index2] = rstTransform.tx;
    rstTransformBuffer[index3] = rstTransform.ty;
    tileRects[index0] = rect.left;
    tileRects[index1] = rect.top;
    tileRects[index2] = rect.right;
    tileRects[index3] = rect.bottom;
  }

  render.tilesRects = tileRects;
  render.tilesRstTransforms = rstTransformBuffer;
}

void _processTileTransforms(List<List<Tile>> tiles) {
  render.tileTransforms.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      if (!isBlock(tiles[x][y])){
        render.tileTransforms.add(getTileTransform(x, y));
      }
    }
  }
}

void _loadTileRects(List<List<Tile>> tiles) {
  render.tileRects.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      if (!isBlock(tiles[x][y])){
        render.tileRects.add(mapTileToRect(tiles[x][y]));
      }
    }
  }
}

void drawPlayers() {
  render.playersTransforms.clear();
  render.playersRects.clear();
  for (int i = 0; i < compiledGame.totalHumans; i++) {
    Human human = compiledGame.humans[i];
    render.playersTransforms.add(
        mapHumanToRSTransform(human.x, human.y)
    );
    render.playersRects.add(
        mapHumanToRect(human.weapon, human.state, human.direction, human.frame)
    );
  }
  drawAtlases(images.human, render.playersTransforms, render.playersRects);
}

RSTransform mapHumanToRSTransform(double x, double y) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfHumanSpriteFrameWidth,
    anchorY: halfHumanSpriteFrameHeight + 5,
    translateX: x,
    translateY: y,
  );
}

RSTransform mapZombieToRSTransform(Zombie zombie) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfHumanSpriteFrameWidth,
    anchorY: halfHumanSpriteFrameHeight + 5,
    translateX: zombie.x,
    translateY: zombie.y,
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

void drawPaths() {
  setColor(Colors.blue);
  for (List<Vector2> path in render.paths) {
    for (int i = 0; i < path.length - 1; i++) {
      drawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
    }
  }
}

void drawDebugNpcs(List<NpcDebug> values){
  setColor(Colors.yellow);

  for (NpcDebug npc in values) {
    drawLine(npc.x, npc.y, npc.targetX, npc.targetY);
  }
}

void drawPlayerHealth() {
  if (!playerAssigned) return;

  double health = player.health / player.maxHealth;
  double halfMaxHealth = player.maxHealth * 0.5;
  if (health > 0.5) {
    drawCharacterCircle(
        compiledGame.playerX,
        compiledGame.playerY,
        Color.lerp(
            colours.yellow, colours.green, (player.health - halfMaxHealth) / halfMaxHealth));
  } else {
    drawCharacterCircle(compiledGame.playerX, compiledGame.playerY,
        Color.lerp(colours.blood, colours.yellow, player.health / halfMaxHealth));
  }
}

Color get healthColor {
  double health = player.health / player.maxHealth;
  double halfMaxHealth = player.maxHealth * 0.5;
  if (health > 0.5) {
    return Color.lerp(
        colours.orange, colours.green, (player.health - halfMaxHealth) / halfMaxHealth);
  }
  return Color.lerp(colours.blood, colours.orange, player.health / halfMaxHealth);
}

RSTransform getTileTransform(int x, int y) {
  return RSTransform.fromComponents(
      rotation: 0.0,
      scale: 1.0,
      anchorX: halfTileSize,
      anchorY: 48,
      translateX: perspectiveProjectX(x * halfTileSize, y * halfTileSize),
      translateY: perspectiveProjectY(x * halfTileSize, y * halfTileSize) +
          halfTileSize);
}

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}

double projectedToWorldX(double x, double y) {
  return y - x;
}

double projectedToWorldY(double x, double y) {
  return x + y;
}

double get mouseUnprojectPositionX =>
    projectedToWorldX(mouseWorldX, mouseWorldY);

double get mouseUnprojectPositionY =>
    projectedToWorldY(mouseWorldX, mouseWorldY);

int get mouseTileX {
  return mouseUnprojectPositionX ~/ tileSize;
}

int get mouseTileY {
  return mouseUnprojectPositionY ~/ tileSize;
}

Tile getTile(int row, int column){
  if (row < 0) return Tile.Boundary;
  if (column < 0) return Tile.Boundary;
  if (row >= compiledGame.tiles.length) return Tile.Boundary;
  if (column >= compiledGame.tiles[0].length) return Tile.Boundary;
  return compiledGame.tiles[row][column];
}

void drawCircleOutline(
    {int sides = 6, double radius, double x, double y, Color color}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  setColor(color);

  paint.strokeWidth = 3;

  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points.add(Offset(cos(a1) * radius, sin(a1) * radius));
  }
  for (int i = 0; i < points.length - 1; i++) {
    globalCanvas.drawLine(points[i] + z, points[i + 1] + z, paint);
  }
}

void drawTiles() {
  // TODO Optimization: Null checks are expensive
  if (images.tiles == null) return;
  if (compiledGame.tiles == null || compiledGame.tiles.isEmpty) return;
  if (render.tileTransforms.length != render.tileRects.length) return;
  drawTileList();
}

void drawBulletHoles(List<Vector2> bulletHoles) {
  for (Vector2 bulletHole in bulletHoles) {
    if (bulletHole.x == 0) return;
    if (!onScreen(bulletHole.x, bulletHole.y)) continue;
    drawCircle(bulletHole.x, bulletHole.y, 2, Colors.black);
  }
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
