import 'dart:ui';

import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/render/mappers/mapArcherToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';
import 'package:bleed_client/render/mappers/mapSrcWitch.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/functions/screen_to_world.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/angle_between.dart';

// TODO floating state
int frame = 0;
// TODO floating state
int animationRate = 8;
// TODO floating state
int animationFrame = 1;

int direction = 0;
double x = 50;
double y = 50;
final Vector2 star = Vector2(100, 100);
double rotation = 0;
double scale = 1;

void drawCanvas(Canvas canvas, Size size) {
  frame++;
  if (frame % animationRate == 0){
    animationFrame++;
  }

  if (editMode) {
    renderCanvasEdit();
    return;
  }

  if (!webSocket.connected) {
    renderBackground();
  }
  if (game.player.uuid.value.isEmpty) return;
  if (game.status.value == GameStatus.Awaiting_Players) return;
  renderGame(canvas, size);
}

void renderBackground(){
  // drawStar(x: star.x, y: star.y, rotation: rotation, scale: scale);
  // rotation += 0.01;
  // scale -= 0.001;

}

void renderCanvasSelectGame() {
  final double angle = angleBetween(x, y, mouseWorldX, mouseWorldY);
  Direction direction = convertAngleToDirection(angle);
  CharacterState state = CharacterState.Idle;
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
      x: x,
      y: y,
      state: state,
      direction: direction,
      frame: animationFrame,
      scale: 1
  );
}

void drawFish({
  required double x,
  required double y,
  required int frame,
  required Direction direction,
}){
    drawAtlas(
        dst: mapDst(x: x, y: y),
        src: loop(
            atlas: atlas.fish.swimming,
            direction: direction,
            frame: frame,
            size: 80,
        )
    );
}

void renderCanvasSelectRegion() {
  final double x = screenToWorldX(screen.width * 0.5) - 32;
  final double y = screenToWorldY(70);
  final double x2 = x + 32;
  final double y2 = y + 32;
  final double angle = angleBetweenMouse(x2, y2);
  final Direction direction = convertAngleToDirection(angle);

  // drawLine(x2, y, mouseWorldX, mouseWorldY);
  // drawCloud(x: mouseWorldX, y: mouseWorldY);
  // drawFish(x: 400, y: 400, direction: Direction.Down, frame: animationFrame);

  drawArcher(
      x: x,
      y: y,
      state: CharacterState.Running,
      direction: direction,
      frame: animationFrame,
      scale: 1);
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