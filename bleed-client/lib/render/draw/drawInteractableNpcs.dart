import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/diff_over.dart';

final _textStyle = TextStyle(color: Colors.white);

void drawInteractableNpc(Character npc) {
  drawCharacter(npc);
  if (diffOver(npc.x, mouseWorldX, 50)) return;
  if (diffOver(npc.y, mouseWorldY, 50)) return;
  engine.draw.text(npc.name, npc.x - charWidth * npc.name.length, npc.y, style: _textStyle);
}



