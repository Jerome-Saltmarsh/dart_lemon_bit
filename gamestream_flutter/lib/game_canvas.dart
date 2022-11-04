
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';

class GameCanvas {
  static bool cursorVisible = true;

  static void renderForeground(Canvas canvas, Size size) {
    if (cursorVisible){
      GameRender.canvasRenderCrossHair(canvas, 5 + GameState.player.weaponCooldown.value * 10);
    }

    switch(GameState.player.aimTargetCategory){
      case AimTargetCategory.GameObject:
        Engine.renderText(
          ItemType.getName(GameState.player.aimTargetSubType),
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
        );
        break;
      case AimTargetCategory.Allie:
        Engine.renderText(
          GameState.player.aimTargetName,
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
        );
        break;
      case AimTargetCategory.Enemy:
        Engine.renderText(
          GameState.player.aimTargetName,
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
        );
        break;
    }
  }


  static void renderCanvas(Canvas canvas, Size size) {
    /// particles are only on the ui and thus can update every frame
    /// this makes them much smoother as they don't freeze
    GameState.updateParticles();
    GameState.renderFrame.value++;
    GameState.interpolatePlayer();
    GameCamera.update();
    GameRender.renderSprites();
    GameState.renderEditMode();
    GameRender.renderMouseTargetName();
    GameState.rendersSinceUpdate.value++;
    renderPlayerRunTarget();
  }

  static void renderPlayerRunTarget(){
    if (GamePlayer.runningToTarget){
      GameRender.renderCircle32(GamePlayer.target.x, GamePlayer.target.y, GamePlayer.target.z);
    }
  }
}