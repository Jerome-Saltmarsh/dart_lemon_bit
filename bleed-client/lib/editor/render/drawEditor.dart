import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/engine/functions/drawCircle.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/drawEnvironmentObjects.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:flutter/material.dart';

void renderCanvasEdit() {
  drawTiles();
  drawEnvironmentObjects();

  if (selectedCollectable > 0) {
    double x = game.collectables[selectedCollectable + 1].toDouble();
    double y = game.collectables[selectedCollectable + 2].toDouble();
    drawCircleOutline(x: x, y: y, radius: 50, color: Colors.white, sides: 10);
  }

  _drawCrates();

  if (editState.selectedObject != null){
    drawCircleOutline(x: editState.selectedObject.x, y: editState.selectedObject.y, radius: 50, color: Colors.white, sides: 10);
    drawCircle(editState.selectedObject.x, editState.selectedObject.y,
        15, Colors.white70);
  }
}

void _drawCrates() {
  for (Vector2 position in game.crates) {
    if (position.isZero) break;
    _drawCrate(position);
  }
}

void _drawCrate(Vector2 position) {
  drawCircle(position.x, position.y, 5, Colors.white);
  globalCanvas.drawImage(images.crate, Offset(position.x, position.y), paint);
}
