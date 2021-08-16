import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/enums/CollectableType.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/properties.dart';
import 'package:flutter/services.dart';

import '../classes/Block.dart';
import 'EditMode.dart';
import '../game_engine/engine_state.dart';
import '../game_engine/game_input.dart';
import '../game_engine/game_widget.dart';
import '../instances/editState.dart';
import '../settings.dart';
import '../state.dart';

Offset _translateOffset;

void initEditor() {
  RawKeyboard.instance.addListener((value) {
    if (!editMode) return;

    if (value is RawKeyDownEvent) {
      if (value.logicalKey == LogicalKeyboardKey.keyH) {
        game.collectables.add(CollectableType.Health.index);
        game.collectables.add(mouseWorldX.toInt());
        game.collectables.add(mouseWorldY.toInt());
      }
    }
  });
}

void updateEditMode() {
  _controlCameraEditMode();
  _handleMouseClick();
  _handleMouseDrag();
  redrawGame();
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

  _getBlockAt(mouseWorldX, mouseWorldY);
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
