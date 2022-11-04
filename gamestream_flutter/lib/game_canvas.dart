
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

class GameCanvas {
  static bool cursorVisible = true;

  static void renderForegroundText(Vector3 position, String text){
    Engine.renderText(
      text,
      Engine.worldToScreenX(position.renderX),
      Engine.worldToScreenY(position.renderY),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  static void renderForeground(Canvas canvas, Size size) {
    if (cursorVisible){
      if (GameState.player.aimTargetCategory == AimTargetCategory.GameObject){

      } else {
        GameRender.canvasRenderCrossHair(canvas, 5 + GameState.player.weaponCooldown.value * 10);
      }

    }

    if (GameState.showAllItems) {
       for (var i = 0; i < GameState.totalGameObjects; i++){
         final gameObject = GameState.gameObjects[i];
         if (gameObject.type != GameObjectType.Item) continue;
         renderForegroundText(gameObject, ItemType.getName(gameObject.subType));
       }
    }

    const style = TextStyle(color: Colors.white, fontSize: 18);
    switch(GameState.player.aimTargetCategory){
      case AimTargetCategory.GameObject:
        Engine.renderText(
          ItemType.getName(GameState.player.aimTargetSubType),
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
          style: style,
        );
        break;
      case AimTargetCategory.Allie:
        Engine.renderText(
          GameState.player.aimTargetText,
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
          style: style,
        );
        break;
      case AimTargetCategory.Enemy:
        // Engine.renderText(
        //   GameState.player.aimTargetText,
        //   Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
        //   Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
        //   style: style,
        // );
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