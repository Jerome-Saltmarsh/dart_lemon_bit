import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/editor/render/buildTiles.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/mouseDragging.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/material.dart';

import '../state.dart';
import '../state/editState.dart';

int selectedCollectable = -1;
bool _mouseDragClickProcess = false;

EditTool tool = EditTool.Tile;

enum EditTool { Tile, EnvironmentObject }

Widget buildEnvironmentObjects() {
  return Column(
      children:
          EnvironmentObjectType.values.map(buildEnvironmentType).toList());
}

Widget buildEnvironmentType(EnvironmentObjectType type) {
  return button(type.toString(), () {
    tool = EditTool.EnvironmentObject;
    editState.environmentObjectType = type;
  });
}

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
            children: compiledGame.environmentObjects.map(buildEnv).toList(),
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
              for (List<Tile> row in compiledGame.tiles) {
                row.add(Tile.Grass);
              }
              renderTiles(compiledGame.tiles);
            }),
            button("Increase Tiles Y", () {
              List<Tile> row = [];
              for (int i = 0; i < compiledGame.tiles[0].length; i++) {
                row.add(Tile.Grass);
              }
              compiledGame.tiles.add(row);
              renderTiles(compiledGame.tiles);
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
        _buildObjectList(),
      ],
    ),
  );
}
void updateEditMode() {
  // onKeyPressed(LogicalKeyboardKey.escape, disconnect);

  // _controlCameraEditMode();
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
    _mouseDragClickProcess = false;
    return;
  }

  if (!_mouseDragClickProcess) {
    _mouseDragClickProcess = true;
    _onMouseLeftClick(true);
    return;
  }

  if (selectedCollectable > -1) {
    compiledGame.collectables[selectedCollectable + 1] = mouseWorldX.toInt();
    compiledGame.collectables[selectedCollectable + 2] = mouseWorldY.toInt();
    return;
  }

  setTileAtMouse(editState.tile);
  // switch (editState.tool) {
  //   case EditorTool.Block:
  //     _handleDragBlock();
  //     break;
  //   case EditorTool.TileGrass:
  //     setTileAtMouse(Tile.Grass);
  //     break;
  //   case EditorTool.TileConcrete:
  //     setTileAtMouse(Tile.Concrete);
  //     break;
  // }
}

void _onMouseLeftClick([bool drag = false]) {
  if (!drag && !mouseClicked) return;
  selectedCollectable = -1;

  double r = 50;

  for (int i = 0; i < compiledGame.collectables.length; i += 3) {
    double x = compiledGame.collectables[i + 1].toDouble();
    double y = compiledGame.collectables[i + 2].toDouble();
    if (diff(x, mouseWorldX) < r && diff(y, mouseWorldY) < r) {
      selectedCollectable = i;
      return;
    }
  }

  double selectRadius = 25;
  for (EnvironmentObject environmentObject in compiledGame.environmentObjects) {
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
    return compiledGame.tiles[mouseTileY][mouseTileX];
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
      compiledGame.tiles[row][column] = tile;
      renderTiles(compiledGame.tiles);
      break;
    case EditTool.EnvironmentObject:
      compiledGame.environmentObjects.add(
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
