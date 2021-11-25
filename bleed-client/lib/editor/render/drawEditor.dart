import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawEnvironmentObjects.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';

void renderCanvasEdit() {
  drawTiles();
  drawEnvironmentObjects();
  drawSprites();

  if (selectedCollectable > 0) {
    double x = game.collectables[selectedCollectable + 1].toDouble();
    double y = game.collectables[selectedCollectable + 2].toDouble();
    drawCircleOutline(x: x, y: y, radius: 50, color: Colors.white, sides: 10);
  }


  if (editState.selectedObject != null){
    drawCircleOutline(x: editState.selectedObject.x, y: editState.selectedObject.y, radius: 50, color: Colors.white, sides: 10);
    drawCircle(editState.selectedObject.x, editState.selectedObject.y,
        15, Colors.white70);
  }
}
