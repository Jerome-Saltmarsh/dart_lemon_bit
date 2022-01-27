

import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';

const _width = 35.0;
const _widthHalf = _width * 0.5;
const _height = _width * goldenRatio_0381 * goldenRatio_0381 * goldenRatio_0381;
const _marginBottom = 50;

void drawCharacterHealthBar(Character character){
  engine.actions.setPaintColorWhite();
  engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width, _height), engine.state.paint);
  engine.actions.setPaintColor(colours.red);
  engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom, _width * character.health, _height), engine.state.paint);
}

void drawCharacterMagicBar(Character character){
  engine.actions.setPaintColorWhite();
  engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom + _height, _width, _height), engine.state.paint);
  engine.actions.setPaintColor(colours.blue);
  engine.state.canvas.drawRect(Rect.fromLTWH(character.x - _widthHalf, character.y - _marginBottom + _height, _width * character.magic, _height), engine.state.paint);
}