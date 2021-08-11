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
  // _drawObjects();
  _drawBlocks();
  drawAnimations();
  _drawParticles();
  // drawParticles2();
  drawCharacters();
  drawMouse();


  // globalCanvas.drawPath(path, globalPaint);
}

final Paint _blockPaint = Paint()
  ..color = white
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 0.1;

final Paint _blockGrey = Paint()
  ..color = Colors.grey
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 0.1;

final Paint _blockBlue = Paint()
  ..color = Colors.blueAccent
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 0.1;

final Paint _blockBlueGrey = Paint()
  ..color = Colors.blueGrey
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 0.1;

void _drawBlocks(){
  for(int i = 0; i < blocks.length; i += 4){
    double x = blocks[i];
    double y = blocks[i + 1];
    double width = blocks[i + 2] * 0.5;
    double height = blocks[i + 3] * 0.5;

    double h = -80;
    Path path2 = Path();
    path2.moveTo(x, y + height + h);
    path2.lineTo(x - width, y + h);
    path2.lineTo(x, y - height + h);
    path2.lineTo(x + width, y + h);
    globalCanvas.drawPath(path2, _blockBlueGrey);

    Path path3 = Path();
    path3.moveTo(x, y + height + h);
    path3.lineTo(x - width, y + h);
    path3.lineTo(x - width, y);
    path3.lineTo(x, y + height);
    globalCanvas.drawPath(path3, _blockGrey);

    Path path4 = Path();
    path4.moveTo(x, y + height + h);
    path4.lineTo(x + width, y + h);
    path4.lineTo(x + width, y);
    path4.lineTo(x, y + height);
    globalCanvas.drawPath(path4, _blockPaint);
  }
}

void _drawObjects(){
  // List<RSTransform> transforms = [];
  // List<Rect> rects = [];
  for(int i = 0; i < gameObjects.length; i += 2){
    double x = gameObjects[i].toDouble();
    double y = gameObjects[i + 1].toDouble();
    // transforms.add(rsTransform(x: gameObjects[i].toDouble(), y: gameObjects[i + 1].toDouble(), anchorX: 24, anchorY: 24));
    // rects.add(getTileSpriteRect(Tile.Grass));

    globalPaint.color = Colors.white;
    Path path = Path();
    path.moveTo(x, y);
    path.lineTo(x, y + 25);
    path.lineTo(x + 25, y + 25);
    path.lineTo(x + 50, y);
    path.lineTo(x + 25, -25 + y);
    globalCanvas.drawPath(path, globalPaint);
  }
  // drawAtlases(imageTiles, transforms, rects);



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