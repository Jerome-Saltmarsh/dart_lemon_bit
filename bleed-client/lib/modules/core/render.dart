import 'dart:ui';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/editor/render.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';
import 'package:bleed_client/render/mappers/mapSrcWitch.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_math/angle_between.dart';

final _Timeline timeline = _Timeline();

class _Timeline {
  int _frame = 0;
  int rate = 8;
  int frame = 1;

  void update(){
    _frame++;
    if (_frame % rate == 0){
      frame++;
    }
  }
}

void drawCanvas2(Canvas canvas, Size size) {
  timeline.update();

  if (editMode) {
    renderEditor();
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

void drawFish({
  required double x,
  required double y,
  required int frame,
  required Direction direction,
}){
    drawAtlas(
        dst: mapDst(x: x, y: y),
        src: srcLoop(
            atlas: atlas.fish.swimming,
            direction: direction,
            frame: frame,
            size: 80,
        )
    );
}

void drawStar({
  required double x,
  required double y,
  double rotation = 0,
  double scale = 1.0,
}){
  drawAtlas(
      dst: mapDst(x: x, y: y, scale: scale, rotation: rotation),
      src: mapSrc(x: atlas.star.x, y: atlas.star.y, width: 128, height: 128),
  );
}

void drawArcher({
  required double x,
  required double y,
  required CharacterState state,
  required Direction direction,
  required int frame,
  double scale = 1,
}) {
  drawAtlas(
      dst: mapDst(x: x, y: y, scale: scale),
      src: mapSrcArcher(state: state, direction: direction, frame: frame)
  );
}

void drawWitch({
  required double x,
  required double y,
  required CharacterState state,
  required Direction direction,
  required int frame,
  double scale = 1,
}) {
  drawAtlas(
      dst: mapDst(x: x, y: y, scale: scale),
      src: mapSrcWitch(state: state, direction: direction, frame: frame)
  );
}


double angleBetweenMouse(double x, double y){
  return angleBetween(x, y, mouseWorldX, mouseWorldY);
}