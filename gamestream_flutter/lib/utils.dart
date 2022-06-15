import 'dart:ui';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:intl/intl.dart';
import 'package:lemon_engine/canvas.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:universal_html/html.dart';

import 'isometric/state/player.dart';

double getMouseRotation() {
  return getAngleBetween(player.x, player.y, mouseWorldX, mouseWorldY);
}

void snapToGrid(Vector2 value){
  value.x = (value.x - value.x % tileSize) + tileSizeHalf;
  value.y = value.y - value.y % tileSize;
  if (value is GameObject){
    value.refreshRowAndColumn();
  }
}

void drawLine(double x1, double y1, double x2, double y2) {
  canvas.drawLine(offset(x1, y1), offset(x2, y2), engine.paint);
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

void refreshPage(){
  document.window!.location.href = document.domain!;
}

double getMouseSnapX() => snapX(mouseWorldX, mouseWorldY);
double getMouseSnapY() => snapY(mouseWorldX, mouseWorldY);

final _dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);

String formatDate(DateTime value){
  return _dateFormat.format(value.toLocal());
}