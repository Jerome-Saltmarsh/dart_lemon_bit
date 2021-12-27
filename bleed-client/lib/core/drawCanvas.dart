import 'dart:ui';

import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';

void drawCanvas(Canvas canvas, Size size) {


  if (editMode) {
    renderCanvasEdit();
    return;
  }

  if (game.type.value == GameType.None) {
    renderSelectGameCanvas(canvas, size);
    return;
  }
  if (!webSocket.connected) return;
  if (game.player.uuid.value.isEmpty) return;
  if (game.status.value != GameStatus.In_Progress) return;
  renderGame(canvas, size);
}

void renderSelectGameCanvas(Canvas canvas, Size size){
  drawCircle(
    100,
    100,
    50,
    Colors.red
  );
}