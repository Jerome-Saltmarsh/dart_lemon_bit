import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/render/state/tileRects.dart';
import 'package:bleed_client/render/state/tileTransforms.dart';
import 'package:bleed_client/render/state/tilesRstTransforms.dart';
import 'package:bleed_client/render/state/tilesSrcRects.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

import 'common/Tile.dart';
import 'common/classes/Vector2.dart';
import 'constants/colours.dart';
import 'rects.dart';
import 'state.dart';
import 'utils.dart';

void drawCharacterCircle(double x, double y, Color color) {
  drawCircle(x, y, 10, color);
}

void drawTileList() {
  globalCanvas.drawRawAtlas(
      images.tiles,
      tilesRstTransforms,
      tileSrcRects,
      null,
      null,
      null,
      paint
  );
}

void renderTiles(List<List<Tile>> tiles) {
  _processTileTransforms(tiles);
  _loadTileRects(tiles);

  int total = tileRects.length * 4;
  tilesRstTransforms = Float32List(total);
  tileSrcRects = Float32List(total);

  for (int i = 0; i < tileRects.length; ++i) {
    final int index0 = i * 4;
    final int index1 = index0 + 1;
    final int index2 = index0 + 2;
    final int index3 = index0 + 3;
    final RSTransform rstTransform = tileTransforms[i];
    final Rect rect = tileRects[i];
    tilesRstTransforms[index0] = rstTransform.scos;
    tilesRstTransforms[index1] = rstTransform.ssin;
    tilesRstTransforms[index2] = rstTransform.tx;
    tilesRstTransforms[index3] = rstTransform.ty + 24;
    tileSrcRects[index0] = rect.left;
    tileSrcRects[index1] = 0; // top
    tileSrcRects[index2] = rect.right;
    tileSrcRects[index3] = 48; // bottom
  }
}

void _processTileTransforms(List<List<Tile>> tiles) {
  tileTransforms.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      tileTransforms.add(getTileTransform(x, y));
    }
  }
}

void _loadTileRects(List<List<Tile>> tiles) {
  tileRects.clear();
  for (int row = 0; row < tiles.length; row++) {
    for (int column = 0; column < tiles[0].length; column++) {
        tileRects.add(mapTileToSrcRect(tiles[row][column]));
    }
  }
}

List<Rect> mapTilesToSrcRects(List<List<Tile>> tiles) {
  List<Rect> srcRects = [];
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      if (!isBlock(tiles[x][y])){
        srcRects.add(mapTileToSrcRect(tiles[x][y]));
      }
    }
  }
  return srcRects;
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
  for (List<Vector2> path in paths) {
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

  double health = player.health.value / player.maxHealth;
  double halfMaxHealth = player.maxHealth * 0.5;
  if (health > 0.5) {
    drawCharacterCircle(
        game.playerX,
        game.playerY,
        Color.lerp(
            colours.yellow, colours.green, (player.health.value - halfMaxHealth) / halfMaxHealth));
  } else {
    drawCharacterCircle(game.playerX, game.playerY,
        Color.lerp(colours.blood, colours.yellow, player.health.value / halfMaxHealth));
  }
}

Color get healthColor {
  double health = player.health.value / player.maxHealth;
  double halfMaxHealth = player.maxHealth * 0.5;
  if (health > 0.5) {
    return Color.lerp(
        colours.orange, colours.green, (player.health.value - halfMaxHealth) / halfMaxHealth);
  }
  return Color.lerp(colours.blood, colours.orange, player.health.value / halfMaxHealth);
}

RSTransform getTileTransform(int x, int y) {
  return RSTransform.fromComponents(
      rotation: 0.0,
      scale: 1.0,
      anchorX: halfTileSize,
      anchorY: halfTileSize,
      translateX: getTileWorldX(x, y),
      translateY: getTileWorldY(x, y));
}

double getTileWorldX(int row, int column){
  return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
}

double getTileWorldY(int row, int column){
  return perspectiveProjectY(row * halfTileSize, column * halfTileSize);
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
  if (row >= game.totalRows) return Tile.Boundary;
  if (column >= game.totalColumns) return Tile.Boundary;
  return game.tiles[row][column];
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
  if (game.tiles == null || game.tiles.isEmpty) return;
  drawTileList();
}

void drawBulletHoles(List<Vector2> bulletHoles) {
  for (Vector2 bulletHole in bulletHoles) {
    if (bulletHole.x == 0) return;
    if (!onScreen(bulletHole.x, bulletHole.y)) continue;
    if (inDarkness(bulletHole.x, bulletHole.y)) continue;
    drawCircle(bulletHole.x, bulletHole.y, 2, Colors.black);
  }
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
