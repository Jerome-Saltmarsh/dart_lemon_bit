import 'dart:ui';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:intl/intl.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

double getMouseRotation() {
  return getAngleBetween(Game.player.x, Game.player.y, mouseWorldX, mouseWorldY);
}

void snapToGrid(Vector2 value){
  value.x = (value.x - value.x % tileSize) + tileSizeHalf;
  value.y = value.y - value.y % tileSize;
}

void drawLine(double x1, double y1, double x2, double y2) {
  Engine.canvas.drawLine(offset(x1, y1), offset(x2, y2), Engine.paint);
}

Offset offset(double x, double y) {
  return Offset(x, y);
}

void copy(String value){
  // FlutterClipboard.copy(value);
}

void openLink(String value, {bool newTab = true}){
  // html.window.open(value, 'new tab');
}

final _dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);

String formatDate(DateTime value){
  return _dateFormat.format(value.toLocal());
}