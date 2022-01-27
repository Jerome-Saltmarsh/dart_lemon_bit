import 'dart:math';

import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

import 'common/Tile.dart';
import 'rects.dart';
import 'utils.dart';

void drawCharacterCircle(double x, double y, Color color) {
  engine.draw.circle(x, y, 10, color);
}

RSTransform rsTransform({
  required double x,
  required double y,
  required double anchorX,
  required double anchorY,
  double scale = 1
}) {
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
  engine.actions.setPaintColor(colours.blue);
  for (List<Vector2> path in paths) {
    for (int i = 0; i < path.length - 1; i++) {
      drawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
    }
  }
}

void drawDebugNpcs(List<NpcDebug> values){
  engine.actions.setPaintColor(Colors.yellow);

  for (NpcDebug npc in values) {
    drawLine(npc.x, npc.y, npc.targetX, npc.targetY);
  }
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

int get mouseColumn {
  return mouseUnprojectPositionX ~/ tileSize;
}

int get mouseRow {
  return mouseUnprojectPositionY ~/ tileSize;
}

Tile getTile(int row, int column){
  if (row < 0) return Tile.Boundary;
  if (column < 0) return Tile.Boundary;
  if (row >= modules.isometric.state.totalRows) return Tile.Boundary;
  if (column >= modules.isometric.state.totalColumns) return Tile.Boundary;
  return isometric.state.tiles[row][column];
}

void drawCircleOutline({
  required double radius,
  required double x,
  required double y,
  required Color color,
  int sides = 6
}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  engine.actions.setPaintColor(color);

  engine.state.paint.strokeWidth = 3;

  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points.add(Offset(cos(a1) * radius, sin(a1) * radius));
  }
  for (int i = 0; i < points.length - 1; i++) {
    engine.state.canvas.drawLine(points[i] + z, points[i + 1] + z, engine.state.paint);
  }
}

void drawTiles() {
  engine.actions.setPaintColorWhite();
  drawAtlas(
      dst: modules.isometric.state.tilesDst,
      src: modules.isometric.state.tilesSrc,
  );
}

void drawBulletHoles(List<Vector2> bulletHoles) {
  for (Vector2 bulletHole in bulletHoles) {
    if (bulletHole.x == 0) return;
    if (!onScreen(bulletHole.x, bulletHole.y)) continue;
    if (inDarkness(bulletHole.x, bulletHole.y)) continue;
    engine.draw.circle(bulletHole.x, bulletHole.y, 2, Colors.black);
  }
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}
