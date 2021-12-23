import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';

void renderCanvasEdit() {
  drawTiles();
  drawSprites();

  if (selectedCollectable > 0) {
    double x = game.collectables[selectedCollectable + 1].toDouble();
    double y = game.collectables[selectedCollectable + 2].toDouble();
    drawCircleOutline(x: x, y: y, radius: 50, color: Colors.white, sides: 10);
  }

  EnvironmentObject? selectedObject = editState.selectedObject;

  if (selectedObject != null){
    drawCircleOutline(x: selectedObject.x, y: selectedObject.y, radius: 50, color: Colors.white, sides: 10);
    drawCircle(selectedObject.x, selectedObject.y,
        15, Colors.white70);
  }
}
