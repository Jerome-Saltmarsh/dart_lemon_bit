import 'dart:ui';

import 'package:bleed_client/game_engine/engine_state.dart';
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
  drawAnimations();
  _drawParticles();
  // drawParticles2();
  drawCharacters();
  drawMouse();
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