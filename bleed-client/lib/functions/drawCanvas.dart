import 'dart:ui';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/enums/EditMode.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/instances/editState.dart';
import 'package:bleed_client/properties.dart';
import 'package:flutter/material.dart';

import '../../keys.dart';
import '../connection.dart';
import '../draw.dart';
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

  canvass.scale(zoom, zoom);
  canvass.translate(-cameraX / zoom, -cameraY * zoom);
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
  drawEditMode();
  drawMouse();
}

void drawEditMode() {
  if (!editMode) return;

  if (editState.selectedBlock != null) {
    if (editState.editMode == EditMode.Translate) {
      drawBlockSelected(editState.selectedBlock);
    } else {
      if (editState.editMode == EditMode.AdjustTop) {
        _drawLine(editState.selectedBlock.top, editState.selectedBlock.right,
            Colors.red);
      }
    }
  }
}

final Paint paintRed = Paint()
  ..color = Colors.red
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 1;

final Paint paintGreen = Paint()
  ..color = Colors.green
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 1;

final Paint paintDeepPurple = Paint()
  ..color = Colors.deepPurple
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.fill
  ..isAntiAlias = false
  ..strokeWidth = 1;

void _drawBlocks() {
  blockHouses.forEach(drawBlock);
}

void drawBlock(Block block) {
  // globalCanvas.drawPath(block.wall1, _blockBlueGrey);
  // globalCanvas.drawPath(block.wall2, _blockBlue);
  // globalCanvas.drawPath(block.wall3, _blockGrey);
  // _drawLine(block.center, block.a, Colors.red);
  // _drawLine(block.center, block.b, Colors.green);
  // _drawLine(block.center, block.top, Colors.deepPurple);
  // _drawLine(block.center, block.right, Colors.orange);

  globalPaint.strokeWidth = 2;
  _drawLine(block.top, block.right, Colors.white);
  _drawLine(block.right, block.bottom, Colors.white);
  _drawLine(block.bottom, block.left, Colors.white);
  _drawLine(block.left, block.top, Colors.white);
}

void drawBlockSelected(Block block) {
  // globalCanvas.drawPath(block.wall1, _blockBlueGrey);
  // globalCanvas.drawPath(block.wall2, _blockBlue);
  // globalCanvas.drawPath(block.wall3, _blockGrey);
  // _drawLine(block.center, block.a, Colors.red);
  // _drawLine(block.center, block.b, Colors.green);
  // _drawLine(block.center, block.top, Colors.deepPurple);
  // _drawLine(block.center, block.right, Colors.orange);

  globalPaint.strokeWidth = 3;
  _drawLine(block.top, block.right, Colors.red);
  _drawLine(block.right, block.bottom, Colors.red);
  _drawLine(block.bottom, block.left, Colors.red);
  _drawLine(block.left, block.top, Colors.red);
}

void _drawLine(Offset a, Offset b, Color color) {
  globalPaint.color = color;
  globalCanvas.drawLine(a, b, globalPaint);
}

Block createBlock(double topX, double topY, double rightX, double rightY,
    double bottomX, double bottomY, double leftX, double leftY) {
  // width *= 0.5;
  // length *= 0.5;
  //
  // Path path1 = Path();
  // path1.moveTo(x, y + length - height);
  // path1.lineTo(x - width, y - height);
  // path1.lineTo(x, y - length - height);
  // path1.lineTo(x + width, y - height);
  //
  // Path path2 = Path();
  // path2.moveTo(x, y + length);
  // path2.lineTo(x, y + length - height);
  // path2.lineTo(x - width, y - height);
  // path2.lineTo(x - width, y);
  //
  // Path path3 = Path();
  // path3.moveTo(x, y + length);
  // path3.lineTo(x, y + length - height);
  // path3.lineTo(x + width, y - height);
  // path3.lineTo(x + width, y);

  Offset top = Offset(topX, topY);
  Offset right = Offset(rightX, rightY);
  Offset bottom = Offset(bottomX, bottomY);
  Offset left = Offset(leftX, leftY);

  return Block(top, right, bottom, left);
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
