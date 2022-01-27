import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/modules/editor/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

class EditorRender {

  void render(Canvas canvas, Size size) {
    isometric.render.tiles();
    isometric.render.sprites();
    _drawSelectedObject();
    _drawCharacters();
  }

  void _drawCharacters() {
    for (Character character in editor.state.characters){
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
}

