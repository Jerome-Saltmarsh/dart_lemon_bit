import "dart:html" as html;
import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:clipboard/clipboard.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/pi2.dart';
import 'package:universal_html/html.dart';

import 'common/Tile.dart';
import 'modules/isometric/utilities.dart';

double getMouseRotation() {
  return angleBetween(modules.game.state.player.x, modules.game.state.player.y, mouseWorldX, mouseWorldY);
}

bool get playerAssigned => modules.game.state.player.id >= 0;

void drawLine(double x1, double y1, double x2, double y2) {
  engine.state.canvas.drawLine(offset(x1, y1), offset(x2, y2), engine.state.paint);
}

Offset offset(double x, double y) {
  return Offset(x, y);
}

const _piEighth = pi / 8.0;
const _piQuarter = pi / 4.0;

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

void setTileAtMouse(Tile tile) {
  isometric.actions.setTile(row: mouseRow, column: mouseColumn, tile: tile);
}

void copy(String value){
  FlutterClipboard.copy(value);
}

void openLink(String value, {bool newTab = true}){
  html.window.open(value, 'new tab');
}

void refreshPage(){
  document.window!.location.href = document.domain!;
}

