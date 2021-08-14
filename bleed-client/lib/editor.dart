import 'dart:ui';

import 'classes/Block.dart';
import 'enums/EditMode.dart';
import 'game_engine/engine_state.dart';
import 'game_engine/game_input.dart';
import 'game_engine/game_widget.dart';
import 'instances/editState.dart';
import 'settings.dart';
import 'state.dart';

Offset get _mouseOffset => Offset(mouseWorldX, mouseWorldY);
Offset translateOffset;


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

  if (editState.editMode == EditMode.Translate){
    Offset currentMouseOffset = block.top - _mouseOffset;
    Offset difference =  translateOffset - currentMouseOffset;
    translateBlock(block, difference);
    return;
  }


  Offset mouseVel = mousePosition - previousMousePosition;
  Offset mouseWorldVelocity = Offset(mouseVel.dx / zoom, mouseVel.dy / zoom);


  switch (editState.editMode) {
    case EditMode.Translate:
      block.top += mouseWorldVelocity;
      block.right += mouseWorldVelocity;
      block.bottom += mouseWorldVelocity;
      block.left += mouseWorldVelocity;
      break;
    case EditMode.AdjustTop:
      // double radionDiff = piQuarter - radions;
      // double angleDiff = radionDiff * radionsToDegrees;
      // double distance = adj(angleDiff, hyp);
      // double translateX = adj(piQuarter, distance);
      // double translateY = opp(piQuarter, distance);
      // Offset translation = Offset(translateX, translateY);
      // editState.selectedBlock.top -= translation;
      // editState.selectedBlock.right -= translation;
      double xd = block.top.dx - mouseWorldX;
      double yd = block.top.dy - mouseWorldY;

      double d = xd - yd;

      // if(yd > xd){
      Offset translation = Offset(d, d);
      block.top += translation;
      block.right += translation;
      // }

      break;
  }
}

void _handleMouseClick() {
  if (!mouseClicked) return;
  // spawn block at mouse
  _getBlockAt(mouseWorldX, mouseWorldY);
  // if (block == null) {
  //   if (editState.selectedBlock == null) {
  //     editState.selectedBlock =
  //         createBlock2(mouseWorldX, mouseWorldY, 200, 300);
  //   } else {
  //     editState.selectedBlock = null;
  //   }
  // } else {
  //   if (editState.selectedBlock != block) {
  //     editState.selectedBlock = block;
  //   } else {
  //     editState.selectedBlock = null;
  //   }
  // }
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
        } else {
          selectTransferBlock(block);
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
        } else {
          selectTransferBlock(block);
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
        } else {
          selectTransferBlock(block);
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
          editState.editMode = EditMode.AdjustBottom;
        } else {
          selectTransferBlock(block);
        }
        return;
      }
      continue;
    }
  }
  return null;
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

void selectTransferBlock(Block block){
  editState.editMode = EditMode.Translate;
  translateOffset = block.top - _mouseOffset;
  editState.selectedBlock = block;
}

void translateBlock(Block block, Offset value){
  block.top += value;
  block.right += value;
  block.bottom += value;
  block.left += value;
}
