import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/EditorTool.dart';
import 'package:bleed_client/enums/CollectableType.dart';
import 'package:bleed_client/functions/drawCanvas.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/game_engine/engine_draw.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../classes/Block.dart';
import '../connection.dart';
import '../enums.dart';
import '../ui.dart';
import 'EditMode.dart';
import '../game_engine/engine_state.dart';
import '../game_engine/game_input.dart';
import '../game_engine/game_widget.dart';
import '../instances/editState.dart';
import '../settings.dart';
import '../state.dart';

Offset _translateOffset;
bool _panning = false;
Offset _mouseWorldStart;

void initEditor() {
  RawKeyboard.instance.addListener(_handleKeyPressed);
}

void _addCollectable(CollectableType type) {
  game.collectables.add(type.index);
  game.collectables.add(mouseWorldX.toInt());
  game.collectables.add(mouseWorldY.toInt());
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
              text(
                  "Mouse X: ${mouseWorldX.toInt()}, mouse Y: ${mouseWorldY.toInt()}"),
              text(
                  "MousePro X: ${mouseUnprojectPositionX.toInt()}, mouseProY: ${mouseUnprojectPositionY.toInt()}"),
              text("Tile X: $mouseTileX, Tile Y: $mouseTileY"),
              button("GRASS", () {
                editState.tool = EditorTool.TileGrass;
              }),
              button("BLOCK", () {
                editState.tool = EditorTool.Block;
              }),
              button("Save Scene", saveScene),
              button("Increase Tiles X", () {
                for (List<Tile> row in game.tiles) {
                  row.add(Tile.Grass);
                }
                updateTiles();
              }),
              button("Increase Tiles Y", () {
                List<Tile> row = [];
                for (int i = 0; i < game.tiles[0].length; i++) {
                  row.add(Tile.Grass);
                }
                game.tiles.add(row);
                updateTiles();
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
    if (event.logicalKey == LogicalKeyboardKey.keyO) {
      _addCollectable(CollectableType.Health);
    }
    if (event.logicalKey == LogicalKeyboardKey.keyI) {
      _addCollectable(CollectableType.Handgun_Ammo);
    }
    if (event.logicalKey == LogicalKeyboardKey.keyP) {
      game.playerSpawnPoints.add(mouseWorld);
    }
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      if(editState.selectedBlock != null){
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
  redrawGame();

  if (_panning) {
    Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
    cameraY += mouseWorldDiff.dy * zoom;
    cameraX += mouseWorldDiff.dx * zoom;
  }
}

void drawEditMode() {
  if (!editMode) return;

  for (Offset offset in game.playerSpawnPoints) {
    drawCircleOffset(offset, 10, Colors.yellow);
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
  if (!mouseDragging) return;
  if (editState.selectedBlock == null) return;

  Block block = editState.selectedBlock;

  if (editState.editMode == EditMode.Translate) {
    Offset currentMouseOffset = block.top - mouseWorld;
    Offset difference = _translateOffset - currentMouseOffset;
    _translateBlock(block, difference);
    return;
  }

  Offset off = _translateOffset - mouseWorld;
  double distance = magnitude(off.dx, off.dy);

  switch (editState.editMode) {
    case EditMode.AdjustTop:
      double ad = adj(piQuarter, distance);
      double op = opp(piQuarter, distance);
      Offset o = Offset(ad, op);
      block.top = block.left + o;
      block.right = block.bottom + o;
      break;
    case EditMode.AdjustLeft:
      double ad = adj(pi2 - piQuarter, distance);
      double op = opp(pi2 - piQuarter, distance);
      Offset o = Offset(ad, op);
      block.top = block.right + o;
      block.left = block.bottom + o;
      break;
    case EditMode.AdjustRight:
      double ad = adj(piQuarter + piHalf, distance);
      double op = opp(piQuarter + piHalf, distance);
      Offset o = Offset(ad, op);
      block.right = block.top + o;
      block.bottom = block.left + o;
      break;
    case EditMode.AdjustBottom:
      double ad = adj(piQuarter + pi, distance);
      double op = opp(piQuarter + pi, distance);
      Offset o = Offset(ad, op);
      block.left = block.top + o;
      block.bottom = block.right + o;
      break;
  }
}

void _handleMouseClick() {
  if (!mouseClicked) return;

  switch (editState.tool) {
    case EditorTool.Block:
      _getBlockAt(mouseWorldX, mouseWorldY);
      break;
    case EditorTool.TileGrass:
      // get the tile at the mouse position

      int row = mouseTileY;
      int column = mouseTileX;

      if (row < 0) return;
      if (column < 0) return;

      if (row < game.tiles.length && row < game.tiles[0].length) {
        game.tiles[row][column] = Tile.Grass;
        updateTiles();
      }
  }
}

void _getBlockAt(double x, double y) {
  for (Block block in blockHouses) {
    if (block.right.dx < x) continue;
    if (block.left.dx > x) continue;
    if (block.top.dy > y) continue;
    if (block.bottom.dy < y) continue;

    double r = 15;

    if (x < block.top.dx && y < block.left.dy) {
      double xd = block.top.dx - x;
      double yd = y - block.top.dy;
      if (yd > xd) {
        if (yd - xd < r) {
          editState.editMode = EditMode.AdjustLeft;
          _translateOffset = block.bottom;
          editState.selectedBlock = block;
        } else {
          _selectTransferBlock(block);
          return;
        }
        return;
      }
      continue;
    }

    if (x < block.bottom.dx && y > block.left.dy) {
      double xd = x - block.left.dx;
      double yd = y - block.left.dy;
      if (xd > yd) {
        if (xd - yd < r) {
          editState.editMode = EditMode.AdjustBottom;
          _translateOffset = block.top;
          editState.selectedBlock = block;
        } else {
          _selectTransferBlock(block);
        }
        return;
      }
      continue;
    }
    if (x > block.top.dx && y < block.right.dy) {
      double xd = x - block.top.dx;
      double yd = y - block.top.dy;

      if (yd > xd) {
        if (yd - xd < r) {
          editState.editMode = EditMode.AdjustTop;
          _translateOffset = block.left;
          editState.selectedBlock = block;
        } else {
          _selectTransferBlock(block);
        }

        return;
      }
      continue;
    }

    if (x > block.bottom.dx && y > block.right.dy) {
      double xd = block.right.dx - x;
      double yd = y - block.right.dy;
      if (xd > yd) {
        if (xd - yd < r) {
          _translateOffset = block.left;
          editState.selectedBlock = block;
          editState.editMode = EditMode.AdjustRight;
        } else {
          _selectTransferBlock(block);
        }
        return;
      }
      continue;
    }
  }
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

void _selectTransferBlock(Block block) {
  editState.editMode = EditMode.Translate;
  _translateOffset = block.top - mouseWorld;
  editState.selectedBlock = block;
}

void _translateBlock(Block block, Offset value) {
  block.top += value;
  block.right += value;
  block.bottom += value;
  block.left += value;
}

void _drawLine(Offset a, Offset b, Color color) {
  globalPaint.color = color;
  globalCanvas.drawLine(a, b, globalPaint);
}
