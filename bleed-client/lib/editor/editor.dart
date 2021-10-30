import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/engine/functions/drawCircle.dart';
import 'package:bleed_client/engine/properties/keyPressed.dart';
import 'package:bleed_client/engine/render/game_widget.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/mouseDragging.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/state/canvas.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../classes/Block.dart';
import '../connection.dart';
import '../state/editState.dart';
import '../settings.dart';
import '../state.dart';
import 'EditMode.dart';

bool _panning = false;
Offset _mouseWorldStart;
int selectedCollectable = -1;
bool _mouseDragClickProcess = false;

EditTool tool = EditTool.Tile;

_Keys _keys = _Keys();

class _Keys {
  LogicalKeyboardKey selectTileType = LogicalKeyboardKey.keyQ;
  LogicalKeyboardKey pan = LogicalKeyboardKey.space;
}

enum EditTool { Tile, EnvironmentObject }

void initEditor() {
  RawKeyboard.instance.addListener(_onKeyEvent);
}

void _resetTiles() {
  for (int row = 0; row < compiledGame.tiles.length; row++) {
    for (int column = 0; column < compiledGame.tiles[0].length; column++) {
      compiledGame.tiles[row][column] = Tile.Grass;
    }
  }
  compiledGame.crates.clear();
  compiledGame.collectables.clear();
  compiledGame.items.clear();
  renderTiles(compiledGame.tiles);
}

Widget buildTiles() {
  return Column(
      children: Tile.values.map((tile) {
    return button(tile.toString(), () {
      tool = EditTool.Tile;
      editState.tile = tile;
    });
  }).toList());
}

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
            button("Reset Tiles", _resetTiles),
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

void _onKeyEvent(RawKeyEvent event) {
  if (!editMode) return;

  if (event is RawKeyDownEvent) {
    _onKeyDownEvent(event);
    return;
  }
  if (event is RawKeyUpEvent) {
    if (event.logicalKey == _keys.pan) {
      _panning = false;
    }
    if (event.logicalKey == _keys.selectTileType) {
      editState.tile = tileAtMouse;
    }
  }
}

void _onKeyDownEvent(RawKeyDownEvent event){
  if (event.logicalKey == LogicalKeyboardKey.keyC) {
    for (Vector2 position in compiledGame.crates) {
      if (!position.isZero) continue;
      position.x = mouseWorldX;
      position.y = mouseWorldY;
      redrawCanvas();
      return;
    }
  }

  double v = 1.5;
  if (event.logicalKey == LogicalKeyboardKey.keyW) {
    if(editState.selectedObject != null) {
      editState.selectedObject.y -= v;
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.keyS) {
    if(editState.selectedObject != null) {
      editState.selectedObject.y += v;
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.keyA) {
    if(editState.selectedObject != null) {
      editState.selectedObject.x -= v;
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.keyD) {
    if(editState.selectedObject != null) {
      editState.selectedObject.x += v;
    }
  }

  if (event.logicalKey == LogicalKeyboardKey.keyP) {
    compiledGame.playerSpawnPoints.add(mouseWorld);
  }
  if (event.logicalKey == LogicalKeyboardKey.delete) {
    if (editState.selectedBlock != null) {
      blockHouses.remove(editState.selectedBlock);
      editState.selectedBlock = null;
    }

    if(editState.selectedObject != null){
      compiledGame.environmentObjects.remove(editState.selectedObject);
      editState.selectedObject = null;
      redrawCanvas();
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.space && !_panning) {
    _panning = true;
    _mouseWorldStart = mouseWorld;
  }
}



void updateEditMode() {
  // onKeyPressed(LogicalKeyboardKey.escape, disconnect);

  // _controlCameraEditMode();
  _onMouseLeftClick();
  _handleMouseDrag();
  redrawCanvas();

  if (_panning) {
    Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
    camera.y += mouseWorldDiff.dy * zoom;
    camera.x += mouseWorldDiff.dx * zoom;
  }
}

void drawEditor() {
  if (!editMode) return;

  // print("drawEditMode()");

  for (Offset offset in compiledGame.playerSpawnPoints) {
    drawCircleOffset(offset, 10, Colors.yellow);
  }

  for (Offset offset in compiledGame.zombieSpawnPoints) {
    drawCircleOffset(offset, 10, Colors.deepPurple);
  }

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

  if (editState.selectedBlock == null) return;
  if (editState.editMode == EditMode.Translate) {
    drawBlockSelected(editState.selectedBlock);
    return;
  }
  Block block = editState.selectedBlock;
  switch (editState.editMode) {
    case EditMode.AdjustTop:
      _drawLine(block.top, block.right, Colors.red);
      break;
    case EditMode.AdjustLeft:
      _drawLine(block.top, block.left, Colors.red);
      break;
    case EditMode.AdjustBottom:
      _drawLine(block.left, block.bottom, Colors.red);
      break;
    case EditMode.AdjustRight:
      _drawLine(block.bottom, block.right, Colors.red);
      break;
    case EditMode.Translate:
      // TODO: Handle this case.
      break;
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

void _drawLine(Offset a, Offset b, Color color) {
  paint.color = color;
  canvas.drawLine(a, b, paint);
}
