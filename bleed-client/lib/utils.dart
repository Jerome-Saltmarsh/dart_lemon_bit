import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/pi2.dart';

import 'common/Tile.dart';
import 'modules/isometric/utilities.dart';

double getMouseRotation() {
  return angleBetween(game.player.x, game.player.y, mouseWorldX, mouseWorldY);
}

bool get playerAssigned => game.player.id >= 0;

void drawLine(double x1, double y1, double x2, double y2) {
  engine.state.canvas.drawLine(offset(x1, y1), offset(x2, y2), engine.state.paint);
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
  engine.state.camera.x = x - (screenCenterX / engine.state.zoom);
  engine.state.camera.y = y - (screenCenterY / engine.state.zoom);
}

void setTileAtMouse(Tile tile) {
  isometric.actions.setTile(row: mouseRow, column: mouseColumn, tile: tile);
}
