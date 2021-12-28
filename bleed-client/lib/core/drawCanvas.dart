import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/state/paint.dart';

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
  drawArcher(x: 50, y: 100, state: CharacterState.Idle, direction: Direction.DownRight, frame: 1, scale: 0.4);
}

void drawArcher({
  required double x,
  required double y,
  required CharacterState state,
  required Direction direction,
  required int frame,
  double scale = 1,
}){
  drawAtlas(mapDst(x: x, y: y, scale: scale), mapSrcArcher(state: state, direction: direction, frame: frame));
}
