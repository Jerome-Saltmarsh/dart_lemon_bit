import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrcWitch.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';

void drawCanvas(Canvas canvas, Size size) {


  if (editMode) {
    renderCanvasEdit();
    return;
  }

  if (game.region.value == Region.None){
    renderCanvasSelectRegion();
    return;
  }
  if (game.type.value == GameType.None) {
    renderCanvasSelectGame();;
    return;
  }
  if (!webSocket.connected) return;
  if (game.player.uuid.value.isEmpty) return;
  if (game.status.value != GameStatus.In_Progress) return;
  renderGame(canvas, size);
}

int direction = 0;
final Duration _frameRate = Duration(milliseconds: 100);

void renderCanvasSelectGame(){
  direction = (direction + 1) % directions.length;
  drawArcher(x: 50, y: 100, state: CharacterState.Idle, direction: directions[direction], frame: 1, scale: 1);
  _redraw();
}

void renderCanvasSelectRegion(){
  direction = (direction + 1) % directions.length;
  drawWitch(x: 50, y: 100, state: CharacterState.Idle, direction: directions[direction], frame: 1, scale: 1);
  _redraw();
}

void _redraw(){
  Future.delayed(_frameRate, redrawCanvas);
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

void drawWitch({
  required double x,
  required double y,
  required CharacterState state,
  required Direction direction,
  required int frame,
  double scale = 1,
}){
  drawAtlas(mapDst(x: x, y: y, scale: scale), mapSrcWitch(state: state, direction: direction, frame: frame));
}

