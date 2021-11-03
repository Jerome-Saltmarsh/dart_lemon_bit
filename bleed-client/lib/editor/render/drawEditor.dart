import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/engine/functions/drawCircle.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/editState.dart';
import 'package:flutter/material.dart';

void drawEditor() {
  if (selectedCollectable > 0) {
    double x = compiledGame.collectables[selectedCollectable + 1].toDouble();
    double y = compiledGame.collectables[selectedCollectable + 2].toDouble();
    drawCircleOutline(x: x, y: y, radius: 50, color: Colors.white, sides: 10);
  }

  if (editState.selectedObject != null){
    drawCircleOutline(x: editState.selectedObject.x, y: editState.selectedObject.y, radius: 50, color: Colors.white, sides: 10);
    drawCircle(editState.selectedObject.x, editState.selectedObject.y,
        15, Colors.white70);
  }

}
