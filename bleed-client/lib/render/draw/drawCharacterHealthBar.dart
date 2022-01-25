

import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_math/golden_ratio.dart';

const _width = 35.0;
const _widthHalf = _width * 0.5;
const _height = _width * goldenRatioInverse * goldenRatioInverse * goldenRatioInverse;
const _marginBottom = 50;

void drawCharacterHealthBar(Character character){
  engine.actions.setPaintColorWhite();
  globalCanvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width, _height), engine.state.paint);
  engine.actions.setPaintColor(colours.red);
  globalCanvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width * character.health, _height), engine.state.paint);
}

void drawCharacterMagicBar(Character character){
  engine.actions.setPaintColorWhite();
  globalCanvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom + _height, _width, _height), engine.state.paint);
  engine.actions.setPaintColor(colours.blue);
  globalCanvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom + _height, _width * character.magic, _height), engine.state.paint);
}