import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'scope.dart';

class EditorRender with EditorScope {

  void render(Canvas canvas, Size size) {
    print("editor.render()");
    isometric.render.renderTiles();
    _drawSelectedObject();
    _characters();
    _environmentObjects();

    state.items.forEach(isometric.render.renderItem);

    for (final playerSpawnPosition in state.teamSpawnPoints){
      engine.draw.drawCircleOutline(
           radius: 25,
           x: playerSpawnPosition.x,
           y: playerSpawnPosition.y,
           color: colours.blue
       );
    }
  }

  void _environmentObjects() {
    state.environmentObjects.forEach(isometric.render.renderEnvironmentObject);
  }

  void _characters() {
    state.characters.forEach(isometric.render.renderCharacter);
  }

  void _drawSelectedObject() {
    final Vector2? selectedObject = state.selected.value;
    if (selectedObject == null) return;

    engine.draw.drawCircleOutline(x: selectedObject.x, y: selectedObject.y, radius: 50, color: Colors.white, sides: 10);
    engine.draw.circle(selectedObject.x, selectedObject.y,
        15, Colors.white70);

  }
}

