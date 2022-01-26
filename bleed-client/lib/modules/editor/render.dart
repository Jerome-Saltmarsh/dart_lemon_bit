import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

void renderEditor(Canvas canvas, Size size) {
  // applyLighting();
  drawTiles();
  drawSprites();
  final state = editor.state;

  _drawSelectedObject();

  for(Character character in state.characters){
    drawCharacter(character);
  }

}

void _drawSelectedObject() {
  final Vector2? selectedObject = editor.state.selected.value;
  if (selectedObject == null) return;

  drawCircleOutline(x: selectedObject.x, y: selectedObject.y, radius: 50, color: Colors.white, sides: 10);
  engine.draw.circle(selectedObject.x, selectedObject.y,
        15, Colors.white70);

}
