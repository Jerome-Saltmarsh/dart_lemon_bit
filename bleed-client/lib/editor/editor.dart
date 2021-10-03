import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/functions/drawCanvas.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/game_engine/global_paint.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../classes/Block.dart';
import '../connection.dart';
import '../game_engine/engine_state.dart';
import '../game_engine/game_input.dart';
import '../game_engine/game_widget.dart';
import '../instances/editState.dart';
import '../settings.dart';
import '../state.dart';
import '../ui.dart';
import 'EditMode.dart';

bool _panning = false;
Offset _mouseWorldStart;
int selectedCollectable = -1;
bool _mouseDragClickProcess = false;

void initEditor() {
  RawKeyboard.instance.addListener(_handleKeyPressed);
}

Widget buildEditorUI() {
  return Container(
    width: globalSize.width,
    height: globalSize.height,
    alignment: Alignment.center,
    child: Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              column(Tile.values.map((tile) {
                return button(tile.toString(), () {
                  editState.tile = tile;
                });
              }).toList()),
              button("Save Scene", saveScene),
              button("Reset Tiles", () {
                for (int row = 0; row < compiledGame.tiles.length; row++) {
                  for (int column = 0;
                      column < compiledGame.tiles[0].length;
                      column++) {
                    compiledGame.tiles[row][column] = Tile.Grass;
                  }
                }
                renderTiles(compiledGame.tiles);
              }),
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
        )
      ],
    ),
  );
}

void _handleKeyPressed(RawKeyEvent event) {
  if (!editMode) return;

  if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      for (Vector2 position in compiledGame.crates) {
        if (!position.isZero) continue;
        position.x = mouseWorldX;
        position.y = mouseWorldY;
        redrawCanvas();
        return;
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
    }
    if (event.logicalKey == LogicalKeyboardKey.space && !_panning) {
      _panning = true;
      _mouseWorldStart = mouseWorld;
    }
  }
  if (event is RawKeyUpEvent) {
    if (event.logicalKey == LogicalKeyboardKey.space) {
      _panning = false;
    }
  }
}

void updateEditMode() {
  onKeyPressed(LogicalKeyboardKey.escape, disconnect);

  _controlCameraEditMode();
  _handleMouseClick();
  _handleMouseDrag();
  redrawCanvas();

  if (_panning) {
    Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
    cameraY += mouseWorldDiff.dy * zoom;
    cameraX += mouseWorldDiff.dx * zoom;
  }
}

void drawEditMode() {
  if (!editMode) return;

  for (Offset offset in compiledGame.playerSpawnPoints) {
    drawCircleOffset(offset, 10, Colors.yellow);
  }

  for (Offset offset in compiledGame.zombieSpawnPoints) {
    drawCircleOffset(offset, 10, Colors.deepPurple);
  }

  if (selectedCollectable > 0) {
    double x = compiledGame.collectables[selectedCollectable + 1].toDouble();
    double y = compiledGame.collectables[selectedCollectable + 2].toDouble();

    drawCircleOutline(x: x, y: y, radius: 50, color: white, sides: 10);
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
  }
}

void _handleMouseDrag() {
  if (!mouseDragging) {
    _mouseDragClickProcess = false;
    return;
  }

  if (!_mouseDragClickProcess) {
    _mouseDragClickProcess = true;
    _handleMouseClick(true);
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

void _handleMouseClick([bool drag = false]) {
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

  setTileAtMouse(editState.tile);
  // switch (editState.tool) {
  //   case EditorTool.Block:
  //     _getBlockAt(mouseWorldX, mouseWorldY);
  //     break;
  //   case EditorTool.TileGrass:
  //     setTileAtMouse(Tile.Grass);
  //     break;
  //   case EditorTool.TileConcrete:
  //     setTileAtMouse(Tile.Concrete);
  //     break;
  //   case EditorTool.TileFortress:
  //     setTileAtMouse(Tile.Fortress);
  //     break;
  //   case EditorTool.ZombieSpawn:
  //     setTileAtMouse(Tile.ZombieSpawn);
  //     break;
  //   case EditorTool.PlayerSpawn:
  //     setTileAtMouse(Tile.PlayerSpawn);
  //     break;
  //   default:
  //     throw Exception("No implementation for ${editState.tool}");
  // }
}

void setTileAtMouse(Tile tile) {
  int row = mouseTileY;
  int column = mouseTileX;
  if (row < 0) return;
  if (column < 0) return;
  // if (row < compiledGame.tiles.length && row < compiledGame.tiles[0].length) {
  //   gameEdit.tiles[row][column] = tile;
  compiledGame.tiles[row][column] = tile;
  renderTiles(compiledGame.tiles);
  // }
}

void _controlCameraEditMode() {
  if (keyPressedA) {
    cameraX -= cameraSpeed;
  }
  if (keyPressedD) {
    cameraX += cameraSpeed;
  }
  if (keyPressedS) {
    cameraY += cameraSpeed;
  }
  if (keyPressedW) {
    cameraY -= cameraSpeed;
  }
}

void _drawLine(Offset a, Offset b, Color color) {
  globalPaint.color = color;
  globalCanvas.drawLine(a, b, globalPaint);
}
