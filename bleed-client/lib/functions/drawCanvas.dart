import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/GunshotFlash.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/common/CollectableType.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../connection.dart';
import '../draw.dart';
import '../images.dart';
import '../keys.dart';
import '../state.dart';
import 'drawBullet.dart';
import 'drawGrenade.dart';
import 'drawParticle.dart';

void drawCanvas(Canvas canvass, Size _size) {
  canvass.scale(zoom, zoom);
  canvass.translate(-cameraX, -cameraY);

  if (editMode) {
    drawTiles();
    return;
  }

  _drawCompiledGame();
}

void _drawCompiledGame() {
  if (!connected) return;
  if (compiledGame.gameId < 0) return;

  frameRateValue++;
  if (frameRateValue % frameRate == 0) {
    drawFrame++;
  }

  drawTiles();
  try {
    drawPlayerHealth();
  } catch (error) {
    print("draw player health error");
  }
  _drawBullets(compiledGame.bullets);
  drawBulletHoles(compiledGame.bulletHoles);
  _drawGrenades(compiledGame.grenades);
  _drawBlocks();
  _drawParticles(compiledGame.particles);
  drawCharacters();
  drawEditMode();
  _drawCollectables();

  if (settings.compilePaths) {
    drawPaths();
  }

  _drawGunShotFlashes();

  for (FloatingText floatingText in render.floatingText){
    if(floatingText.duration == 0) continue;
    floatingText.duration--;
    floatingText.y -= 0.5;
    drawText(floatingText.value, floatingText.x, floatingText.y);
  }

  try {
    _drawPlayerNames();
  } catch (e) {
    print(e);
  }

  if (playerReady) {
    dynamic player = getPlayer;
    if (player != null) {
      Weapon weapons = player[weapon];
      if (weapons == Weapon.SniperRifle || weapons == Weapon.AssaultRifle) {
        _drawMouseAim(weapons);
      }
    }
  }

  drawText(player.equippedRounds.toString(), playerX - 10, playerY - 35);
}

void _drawGunShotFlashes() {
  List<RSTransform> gunShotTransforms = [];
  List<Rect> rects = [];

  for(GunShotFlash gunShotFlash in render.gunShotFlashes){
    // globalCanvas.drawCircle(Offset(gunShotFlash.x, gunShotFlash.y), 5, globalPaint);
    gunShotTransforms.add(RSTransform.fromComponents(
      rotation: gunShotFlash.rotation,
      scale: 1,
      anchorX: 8,
      anchorY: 0,
      translateX: gunShotFlash.x,
      translateY: gunShotFlash.y,
    ));
    rects.add(rectGunShotFlash);
  }
}

double nameRadius = 100;

void _drawPlayerNames() {
  for (int i = 0; i < compiledGame.totalPlayers; i++) {
    dynamic player = compiledGame.players[i];
    if (player[x] == compiledGame.playerX) continue;
    if (diff(mouseWorldX, player[x]) > nameRadius) continue;
    if (diff(mouseWorldY, player[y]) > nameRadius) continue;
    drawText(player[indexName], player[x], player[y]);
  }
}

void _drawMouseAim(Weapon weapon) {
  if (!mouseAvailable) return;
  globalPaint.strokeWidth = 3;
  double rot = radionsBetween(
      mouseWorldX, mouseWorldY, compiledGame.playerX, compiledGame.playerY);

  double mouseDistance = distance(mouseWorldX, mouseWorldY, playerX, playerY);
  double d = min(mouseDistance, weapon == Weapon.SniperRifle ? 150 : 35);
  double vX = velX(rot, d);
  double vY = velY(rot, d);
  Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
  Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
  _drawLine(mouseOffset, aimOffset, Colors.white);
}

void _drawCollectables() {
  for (int i = 0; i < compiledGame.collectables.length; i += 3) {
    CollectableType type = CollectableType.values[compiledGame.collectables[i]];
    int x = compiledGame.collectables[i + 1];
    int y = compiledGame.collectables[i + 2];
    drawCollectable(type, x.toDouble(), y.toDouble());
  }
}

// TODO Optimize
void drawCollectable(CollectableType type, double x, double y) {
  switch (type) {
    case CollectableType.Handgun_Ammo:
      drawSprite(images.imageItems, 4, 1, x, y);
      break;
    case CollectableType.Health:
      drawSprite(images.imageItems, 4, 2, x, y);
      break;
    case CollectableType.Grenade:
      drawSprite(images.imageItems, 4, 3, x, y);
      break;
    case CollectableType.Shotgun_Ammo:
      drawSprite(images.imageItems, 4, 4, x, y);
      break;
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

void _drawGrenades(List<double> grenades) {
  for (int i = 0; i < grenades.length; i += 3) {
    drawGrenade(grenades[i], grenades[i + 1], grenades[i + 2]);
  }
}

void _drawParticles(List<Particle> particles) {
  particles.forEach(drawParticle);
}

void _drawBullets(List bullets) {
  for (int i = 0; i < compiledGame.totalBullets * 2; i += 2) {
    drawBullet(bullets[i], bullets[i + 1]);
  }
}
