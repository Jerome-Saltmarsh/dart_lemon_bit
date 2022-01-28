import 'dart:ui';

import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/angle_between.dart';

void renderCore(Canvas canvas, Size size) {
  core.state.timeline.update();

  if (editMode) {
    // renderEditor();
    return;
  }

  if (!webSocket.connected) {
    renderBackground();
    return;
  }
  if (game.player.uuid.value.isEmpty) return;
  if (game.status.value == GameStatus.Awaiting_Players) return;
  renderGame(canvas, size);
}

void renderBackground(){

}

double angleBetweenMouse(double x, double y){
  return angleBetween(x, y, mouseWorldX, mouseWorldY);
}