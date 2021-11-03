import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/enums/EditTool.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/editor/render/buildEnvironmentObjects.dart';
import 'package:bleed_client/editor/render/buildTiles.dart';
import 'package:bleed_client/editor/state/editTool.dart';
import 'package:bleed_client/editor/state/mouseDragClickProcess.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/mouseDragging.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/material.dart';

import 'state/editState.dart';


Widget buildEnv(EnvironmentObject env){
  return button(parseEnvironmentObjectTypeToString(env.type), (){
    editState.selectedObject = env;
  });
}

Widget _buildObjectList(){
  return Positioned(
      right: 0,
      top: 50,
      child: Container(
        height: screenHeight - 50,
        child: SingleChildScrollView(
            child:Column(
            children: environmentObjects.map(buildEnv).toList(),
          )
        ),
  ));
}

Widget _buildTools(){
  return Positioned(
    left: 0,
    top: 0,
    child: Container(
      height: screenHeight,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: cross.start,
          children: [
            buildTiles(),
            buildEnvironmentObjects(),
            button("Save Scene", saveScene),
            button("Reset Tiles", resetTiles),
            button("Increase Tiles X", () {
              for (List<Tile> row in game.tiles) {
                row.add(Tile.Grass);
              }
              renderTiles(game.tiles);
            }),
            button("Increase Tiles Y", () {
              List<Tile> row = [];
              for (int i = 0; i < game.tiles[0].length; i++) {
                row.add(Tile.Grass);
              }
              game.tiles.add(row);
              renderTiles(game.tiles);
            }),
          ],
        ),
      ),
    ),
  );
}

Widget buildEditorUI() {
  return Container(
    width: globalSize.width,
    height: globalSize.height,
    alignment: Alignment.center,
    child: Stack(
      children: [
        _buildTools(),
        // _buildObjectList(),
      ],
    ),
  );
}
void updateEditMode() {
  _onMouseLeftClick();
  _handleMouseDrag();
  redrawCanvas();

  if (panning) {
    Offset mouseWorldDiff = mouseWorldStart - mouseWorld;
    camera.y += mouseWorldDiff.dy * zoom;
    camera.x += mouseWorldDiff.dx * zoom;
  }
}

void _handleMouseDrag() {
  if (!mouseDragging) {
    mouseDragClickProcess = false;
    return;
  }

  if (!mouseDragClickProcess) {
    mouseDragClickProcess = true;
    _onMouseLeftClick(true);
    return;
  }

  if (selectedCollectable > -1) {
    game.collectables[selectedCollectable + 1] = mouseWorldX.toInt();
    game.collectables[selectedCollectable + 2] = mouseWorldY.toInt();
    return;
  }

  setTileAtMouse(editState.tile);
}

void _onMouseLeftClick([bool drag = false]) {
  if (!drag && !mouseClicked) return;
  selectedCollectable = -1;

  double r = 50;

  for (int i = 0; i < game.collectables.length; i += 3) {
    double x = game.collectables[i + 1].toDouble();
    double y = game.collectables[i + 2].toDouble();
    if (diff(x, mouseWorldX) < r && diff(y, mouseWorldY) < r) {
      selectedCollectable = i;
      return;
    }
  }

  double selectRadius = 25;
  for (EnvironmentObject environmentObject in environmentObjects) {
    if (diffOver(environmentObject.x, mouseWorldX, selectRadius)) continue;
    if (diffOver(environmentObject.y, mouseWorldY, selectRadius)) continue;
    editState.selectedObject = environmentObject;
    redrawCanvas();
    return;
  }

  setTileAtMouse(editState.tile);
}

Tile get tileAtMouse {
  try {
    return game.tiles[mouseTileY][mouseTileX];
  } catch(e){
    return Tile.Boundary;
  }
}

void setTileAtMouse(Tile tile) {
  int row = mouseTileY;
  int column = mouseTileX;
  if (row < 0) return;
  if (column < 0) return;

  switch (tool) {
    case EditTool.Tile:
      game.tiles[row][column] = tile;
      renderTiles(game.tiles);
      break;
    case EditTool.EnvironmentObject:
      environmentObjects.add(
          EnvironmentObject(
            x: mouseWorldX,
            y: mouseWorldY,
            type: editState.environmentObjectType
          )
      );
      print("added house");
      redrawCanvas();
      break;
  }
}
