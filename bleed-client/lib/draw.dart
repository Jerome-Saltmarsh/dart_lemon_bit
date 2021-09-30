import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/mappers/mapTileToRect.dart';
import 'package:bleed_client/mappers/mapZombieToRect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../images.dart';
import 'common/classes/Vector2.dart';
import 'common/Tile.dart';
import 'functions/drawParticle.dart';
import 'keys.dart';
import 'rects.dart';
import 'mappers/mapHumanToRect.dart';
import 'state.dart';
import 'utils.dart';

void drawCharacterCircle(double x, double y, Color color) {
  drawCircle(x, y, 10, color);
}

void drawCharacters() {
  if (images.imageCharacter == null) return;
  drawPlayers();
  drawNpcs();
}

void drawNpcs() {
  render.npcsTransforms.clear();
  render.npcsRects.clear();

  for (int i = 0; i < compiledGame.totalNpcs; i++) {
    render.npcsTransforms.add(getCharacterTransform(compiledGame.npcs[i]));
    render.npcsRects.add(mapZombieToRect(compiledGame.npcs[i]));
  }

  drawAtlases(images.zombie, render.npcsTransforms, render.npcsRects);
}

void drawCharacterList(List<dynamic> characters) {
  globalCanvas.drawAtlas(
      images.imageCharacter,
      characters.map(getCharacterTransform).toList(),
      characters.map(mapHumanToRect).toList(),
      null,
      null,
      null,
      globalPaint);
}

void drawTileList() {
  drawAtlases(images.imageTiles, render.tileTransforms, render.tileRects);
}

void drawAtlases(
    ui.Image image, List<RSTransform> transforms, List<Rect> rects) {
  globalCanvas.drawAtlas(
      image, transforms, rects, null, null, null, globalPaint);
}

void renderTiles(List<List<Tile>> tiles) {
  _processTileTransforms(tiles);
  _loadTileRects(tiles);
}

void _processTileTransforms(List<List<Tile>> tiles) {
  render.tileTransforms.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      render.tileTransforms.add(getTileTransform(x, y));
    }
  }
}

void _loadTileRects(List<List<Tile>> tiles) {
  render.tileRects.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      render.tileRects.add(mapTileToRect(tiles[x][y]));
    }
  }
}

void drawPlayers() {
  render.playersTransforms.clear();
  render.playersRects.clear();
  for (int i = 0; i < compiledGame.totalPlayers; i++) {
    render.playersTransforms
        .add(getCharacterTransform(compiledGame.players[i]));
    render.playersRects.add(mapHumanToRect(compiledGame.players[i]));
  }
  drawAtlases(images.imageCharacter, render.playersTransforms, render.playersRects);
}

void _drawTeamMemberCircles() {
  if (state.player.squad == -1) return;

  for (dynamic player in compiledGame.players) {
    if (player[squad] != state.player.squad) continue;
    if (player[x] == compiledGame.playerX) continue;
    drawCircle(player[x], player[y], 10, Colors.blue);
  }
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
      rects.add(mapHumanToRect(values[i]));
    } else {
      rects[i] = mapHumanToRect(values[i]);
    }
  }
  while (transforms.length > values.length) {
    transforms.removeLast();
  }
  while (rects.length > values.length) {
    rects.removeLast();
  }

  drawAtlases(images.imageCharacter, transforms, rects);
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

void drawPaths() {
  setColor(Colors.blue);
  for (List<Vector2> path in render.paths) {
    for (int i = 0; i < path.length - 1; i++) {
      drawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
    }
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
            yellow, green, (player.health - halfMaxHealth) / halfMaxHealth));
  } else {
    drawCharacterCircle(compiledGame.playerX, compiledGame.playerY,
        Color.lerp(blood, yellow, player.health / halfMaxHealth));
  }
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

void drawCircleOutline(
    {int sides = 6, double radius, double x, double y, Color color}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  setColor(color);

  globalPaint.strokeWidth = 3;

  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points.add(Offset(cos(a1) * radius, sin(a1) * radius));
  }
  for (int i = 0; i < points.length - 1; i++) {
    globalCanvas.drawLine(points[i] + z, points[i + 1] + z, globalPaint);
  }
}

void drawTiles() {
  // TODO Optimization: Null checks are expensive
  if (images.imageTiles == null) return;
  if (compiledGame.tiles == null || compiledGame.tiles.isEmpty) return;
  if (render.tileTransforms.length != render.tileRects.length) return;
  drawTileList();
}

void setColor(Color value) {
  globalPaint.color = value;
}

// void drawBulletRange() {
//   if (!playerAssigned) return;
//   dynamic player = getPlayerCharacter();
//   drawCircleOutline(
//       radius: bulletRange, x: player[x], y: player[y], color: white);
// }

void drawBulletHoles(List<Vector2> bulletHoles) {
  for(Vector2 bulletHole in bulletHoles){
    if(bulletHole.x == 0 && bulletHole.y == 0) return;
    drawCircle(bulletHole.x, bulletHole.y, 2, Colors.black);
  }
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
