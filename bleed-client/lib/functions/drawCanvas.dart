import 'dart:ui';

import 'package:bleed_client/enums.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/images.dart';
import 'package:flutter/material.dart';

import '../connection.dart';
import '../draw.dart';
import '../../keys.dart';
import '../state.dart';
import 'drawAnimations.dart';
import 'drawBullet.dart';
import 'drawGrenade.dart';
import 'drawParticle.dart';



void drawCanvas(Canvas canvass, Size _size) {
  if (!connected) return;

  if (gameId < 0) return;

  frameRateValue++;
  if (frameRateValue % frameRate == 0) {
    drawFrame++;
  }

  canvass.translate(-cameraX, -cameraY);
  canvass.scale(zoom, zoom);
  drawTiles();
  try {
    drawPlayerHealth();
  } catch (error) {
    print("draw player health error");
  }
  _drawBullets();
  drawBulletHoles();
  _drawGrenades();
  _drawObjects();
  drawAnimations();
  _drawParticles();
  // drawParticles2();
  drawCharacters();
  drawMouse();


  // globalCanvas.drawPath(path, globalPaint);
}


void _drawObjects(){
  List<RSTransform> transforms = [];
  List<Rect> rects = [];
  for(int i = 0; i < gameObjects.length; i += 2){
    // double x = gameObjects[i].toDouble();
    // double y = gameObjects[i + 1].toDouble();

    transforms.add(rsTransform(x: gameObjects[i].toDouble(), y: gameObjects[i + 1].toDouble(), anchorX: 24, anchorY: 24));
    rects.add(getTileSpriteRect(Tile.Grass));

    // Path path = Path();
    // path.moveTo(gameOb, y);
    // path.lineTo(0, 0 + y);
    // path.lineTo(25, 25 + y);
    // path.lineTo(50, 0 + y);
    // path.lineTo(25, -25 + y);

  }
  drawAtlases(imageTiles, transforms, rects);



}

void _drawGrenades() {
  for (int i = 0; i < grenades.length; i += 3) {
    drawGrenade(grenades[i], grenades[i + 1], grenades[i + 2]);
  }
}

void _drawParticles() {
  particles.forEach(drawParticle);
}

void _drawBullets() {
  bullets.forEach((bullet) {
    drawBullet(bullet[x], bullet[y]);
  });
}