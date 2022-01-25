import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/pi2.dart';

import 'common/Tile.dart';

double getMouseRotation() {
  return angleBetween(game.player.x, game.player.y, mouseWorldX, mouseWorldY);
}

bool get playerAssigned => game.player.id >= 0;

void drawLine(double x1, double y1, double x2, double y2) {
  globalCanvas.drawLine(offset(x1, y1), offset(x2, y2), paint);
}


Offset offset(double x, double y) {
  return Offset(x, y);
}

const double _piEighth = pi / 8.0;
const double _piQuarter = pi / 4.0;

double convertDirectionToAngle(Direction direction){
  return -direction.index * _piQuarter;
}

Direction convertAngleToDirection(double angle) {
  angle = angle % pi2;
  if (angle < _piEighth) {
    return Direction.Up;
  }
  if (angle < _piEighth + (_piQuarter * 1)) {
    return Direction.UpRight;
  }
  if (angle < _piEighth + (_piQuarter * 2)) {
    return Direction.Right;
  }
  if (angle < _piEighth + (_piQuarter * 3)) {
    return Direction.DownRight;
  }
  if (angle < _piEighth + (_piQuarter * 4)) {
    return Direction.Down;
  }
  if (angle < _piEighth + (_piQuarter * 5)) {
    return Direction.DownLeft;
  }
  if (angle < _piEighth + (_piQuarter * 6)) {
    return Direction.Left;
  }
  if (angle < _piEighth + (_piQuarter * 7)) {
    return Direction.UpLeft;
  }
  return Direction.Up;
}

void cameraCenter(double x, double y) {
  camera.x = x - (screenCenterX / engine.state.zoom);
  camera.y = y - (screenCenterY / engine.state.zoom);
}

Tile get tileAtMouse {
  if (mouseRow < 0) return Tile.Boundary;
  if (mouseColumn < 0) return Tile.Boundary;
  if (mouseRow >= game.totalRows) return Tile.Boundary;
  if (mouseColumn >= game.totalColumns) return Tile.Boundary;
  return game.tiles[mouseRow][mouseColumn];
}


void setTileAtMouse(Tile tile) {
  setTile(row: mouseRow, column: mouseColumn, tile: tile);
}

void setTile({
  required int row,
  required int column,
  required Tile tile,
}) {
  if (row < 0) return;
  if (column < 0) return;
  if (row >= game.totalRows) return;
  if (column >= game.totalColumns) return;
  game.tiles[row][column] = tile;
  mapTilesToSrcAndDst();
}

double distanceFromMouse(double x, double y) {
  return distanceBetween(mouseWorldX, mouseWorldY, x, y);
}

