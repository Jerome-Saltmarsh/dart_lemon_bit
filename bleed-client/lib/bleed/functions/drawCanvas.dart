import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/functions/drawBullet.dart';
import 'package:flutter_game_engine/bleed/functions/drawGrenade.dart';
import 'package:flutter_game_engine/bleed/images.dart';

import '../connection.dart';
import '../draw.dart';
import '../keys.dart';
import '../rects.dart';
import '../state.dart';
import 'drawAnimations.dart';
import 'drawParticles.dart';

void drawCanvas(Canvas canvass, Size _size) {
  if (!connected) return;

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
  _drawBullets();
  drawBulletHoles();
  drawBlood();
  _drawGrenades();
  drawAnimations();
  drawParticles();
  drawParticles2();
  drawCharacters();
  drawMouse();
}

void _drawGrenades() {
  for (int i = 0; i < grenades.length; i += 2) {
    drawGrenade(grenades[i], grenades[i + 1]);
  }
}

void _drawBullets() {
  bullets.forEach((bullet) {
    drawBullet(bullet[x], bullet[y]);
  });
}