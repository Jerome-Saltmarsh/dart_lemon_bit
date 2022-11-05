
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
      renderCursor(canvas);
    }


    if (GameState.showAllItems) {
       for (var i = 0; i < GameState.totalGameObjects; i++){
         final gameObject = GameState.gameObjects[i];
         if (gameObject.type != GameObjectType.Item) continue;
         renderForegroundText(gameObject, ItemType.getName(gameObject.subType));
       }
    }

    const style = TextStyle(color: Colors.white, fontSize: 18);
    switch (GamePlayer.aimTargetCategory) {
      case TargetCategory.GameObject:
        break;
      case TargetCategory.Item:
        Engine.renderText(
          ItemType.getName(GamePlayer.aimTargetType),
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
          style: style,
        );
        break;
      case TargetCategory.Allie:
        Engine.renderText(
          GameState.player.aimTargetText,
          Engine.worldToScreenX(GameState.player.aimTargetPosition.renderX),
          Engine.worldToScreenY(GameState.player.aimTargetPosition.renderY),
          style: style,
        );
        break;
      case TargetCategory.Enemy:
        break;
    }
  }


  static void renderCursor(Canvas canvas) {
    switch (GamePlayer.aimTargetCategory) {
      case TargetCategory.Nothing:
        GameRender.canvasRenderCursorCrossHair(canvas, 5 + GameState.player.weaponCooldown.value * 10);
        break;
      case TargetCategory.Item:
        GameRender.canvasRenderCursorHand(canvas);
        return;
      case TargetCategory.Allie:
        GameRender.canvasRenderCursorTalk(canvas);
        return;
      case TargetCategory.Enemy:
        GameRender.canvasRenderCursorCrossHairRed(canvas, 5 + GameState.player.weaponCooldown.value * 10);
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
      GameRender.renderCircle32(GamePlayer.targetPosition.x, GamePlayer.targetPosition.y, GamePlayer.targetPosition.z);
    }
  }
}