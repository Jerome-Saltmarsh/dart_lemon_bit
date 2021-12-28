import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrcWitch.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';

void drawCanvas(Canvas canvas, Size size) {
  if (editMode) {
    renderCanvasEdit();
    return;
  }

  if (game.region.value == Region.None) {
    renderCanvasSelectRegion();
    return;
  }
  if (game.type.value == GameType.None) {
    renderCanvasSelectGame();
    ;
    return;
  }
  if (!webSocket.connected) return;
  if (game.player.uuid.value.isEmpty) return;
  if (game.status.value != GameStatus.In_Progress) return;
  renderGame(canvas, size);
}

int direction = 0;
final Duration _frameRate = Duration(milliseconds: 80);

double x = 50;
double y = 50;
int frame = 0;

void renderCanvasSelectGame() {
  frame++;
  final double angle = angleBetween(x, y, mouseWorldX, mouseWorldY);
  Direction direction = convertAngleToDirection(angle);

  // direction = (direction + 1) % directions.length;
  // drawArcher(x: x, y: y, state: CharacterState.Idle, direction: directions[direction], frame: 1, scale: 1);
  final distance = distanceBetween(x, y, mouseWorldX, mouseWorldY);

  CharacterState state = CharacterState.Idle;
  // if (distance > 100){
  //   final double speed = 8;
  //   x += adjacent(angle, speed);
  //   y += opposite(angle, speed);
  //   state = CharacterState.Running;
  // }

  double yDiff = y - mouseWorldY;
  double speed = 5;

  if (yDiff < -speed) {
    state = CharacterState.Running;
    direction = Direction.Down;
    y += speed;
  } else if (yDiff > speed) {
    state = CharacterState.Running;
    direction = Direction.Up;
    y -= speed;
  } else {
    state = CharacterState.Idle;
    direction = Direction.Right;
  }

  drawArcher(
      x: x, y: y, state: state, direction: direction, frame: frame, scale: 1);
  _redraw();
}

void renderCanvasSelectRegion() {
  frame++;
  direction = (direction + 1) % directions.length;
  drawWitch(
      x: 50,
      y: 100,
      state: CharacterState.Idle,
      direction: directions[direction],
      frame: 1,
      scale: 1);
  _redraw();
}

void _redraw() {
  Future.delayed(_frameRate, redrawCanvas);
}

void drawArcher({
  required double x,
  required double y,
  required CharacterState state,
  required Direction direction,
  required int frame,
  double scale = 1,
}) {
  drawAtlas(mapDst(x: x, y: y, scale: scale),
      mapSrcArcher(state: state, direction: direction, frame: frame));
}

void drawWitch({
  required double x,
  required double y,
  required CharacterState state,
  required Direction direction,
  required int frame,
  double scale = 1,
}) {
  drawAtlas(mapDst(x: x, y: y, scale: scale),
      mapSrcWitch(state: state, direction: direction, frame: frame));
}
