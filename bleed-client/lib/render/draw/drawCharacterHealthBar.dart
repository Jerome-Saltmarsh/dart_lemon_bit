

import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/golden_ratio.dart';

const _width = 40.0;
const _widthHalf = _width * 0.5;
const _height = _width * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse;
const _marginBottom = 50;

void drawCharacterHealthBar(Character character){
  setColorWhite();
  globalCanvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width, _height), paint);
  setColor(colours.red);
  globalCanvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width * character.health, _height), paint);
}