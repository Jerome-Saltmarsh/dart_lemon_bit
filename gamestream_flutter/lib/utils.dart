import 'dart:ui';

import 'package:bleed_common/Tile.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:clipboard/clipboard.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:universal_html/html.dart';

import 'modules/isometric/utilities.dart';

double getMouseRotation() {
  return angleBetween(modules.game.state.player.x, modules.game.state.player.y, mouseWorldX, mouseWorldY);
}

bool get playerAssigned => modules.game.state.player.id >= 0;

void drawLine(double x1, double y1, double x2, double y2) {
  engine.canvas.drawLine(offset(x1, y1), offset(x2, y2), engine.paint);
}

Offset offset(double x, double y) {
  return Offset(x, y);
}

void setTileAtMouse(Tile tile) {
  isometric.actions.setTile(row: mouseRow, column: mouseColumn, tile: tile);
}

void copy(String value){
  FlutterClipboard.copy(value);
}

void openLink(String value, {bool newTab = true}){
  // html.window.open(value, 'new tab');
}

void refreshPage(){
  document.window!.location.href = document.domain!;
}

