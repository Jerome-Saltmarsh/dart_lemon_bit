
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/render/renderer_nodes.dart';

import 'isometric/render/render_character_health_bar.dart';
import 'touch_controller.dart';

class GameCanvas {



  static void renderForegroundText(Vector3 position, String text){
    engine.renderText(
      text,
      engine.worldToScreenX(position.renderX),
      engine.worldToScreenY(position.renderY),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  static void renderText({required double x, required double y, required double z, required String text}){
    engine.renderText(
      text,
      engine.worldToScreenX(GameConvert.getRenderX(x, y, z)),
      engine.worldToScreenY(GameConvert.getRenderY(x, y, z)),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  static void renderForeground(Canvas canvas, Size size) {

    if (gamestream.io.inputModeKeyboard){
      if (ClientState.hoverDialogType.value == DialogType.None){
        renderCursor(canvas);
      }
    }

    if (gamestream.io.inputModeTouch) {
      TouchController.render(canvas);
    }

     renderGamePlayerAimTargetNameText();
  }

  static void renderGamePlayerAimTargetNameText(){
    if (GamePlayer.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (GamePlayer.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    engine.renderText(
      GamePlayer.aimTargetName,
      engine.worldToScreenX(GamePlayer.aimTargetPosition.renderX),
      engine.worldToScreenY(GamePlayer.aimTargetPosition.renderY),
      style: style,
    );
  }

  static void renderCursor(Canvas canvas) {
    final cooldown = GamePlayer.weaponCooldown.value;
    final accuracy = ServerState.playerAccuracy.value;
    final distance = (cooldown + accuracy) * 10.0 + 5;

    switch (GamePlayer.aimTargetCategory) {
      case TargetCategory.Nothing:
        gamestream.games.isometric.renderer.canvasRenderCursorCrossHair(canvas, distance);

        if (ServerQuery.getEquippedWeaponConsumeType() != ItemType.Empty){
           if (ServerQuery.getEquippedWeaponQuantity() <= 0){
             engine.renderExternalCanvas(
               canvas: canvas,
               image: GameImages.atlas_icons,
               srcX: 272,
               srcY: 0,
               srcWidth: 128,
               srcHeight: 32,
               dstX: engine.mousePositionX,
               dstY: engine.mousePositionY - 70,
             );
           }
        }

        break;
      case TargetCategory.Collect:
        gamestream.games.isometric.renderer.canvasRenderCursorHand(canvas);
        return;
      case TargetCategory.Allie:
        gamestream.games.isometric.renderer.canvasRenderCursorTalk(canvas);
        return;
      case TargetCategory.Enemy:
        gamestream.games.isometric.renderer.canvasRenderCursorCrossHairRed(canvas, distance);

        if (ServerQuery.getEquippedWeaponConsumeType() != ItemType.Empty){
          if (ServerQuery.getEquippedWeaponQuantity() <= 0){
            engine.renderExternalCanvas(
              canvas: canvas,
              image: GameImages.atlas_icons,
              srcX: 272,
              srcY: 0,
              srcWidth: 128,
              srcHeight: 32,
              dstX: engine.mousePositionX,
              dstY: engine.mousePositionY - 70,
            );
          }
        }


        break;
    }
  }

  static void renderPlayerEnergy() {
    if (GamePlayer.dead) return;
    if (!GamePlayer.active.value) return;
    renderBarBlue(
        GamePlayer.position.x,
        GamePlayer.position.y,
        GamePlayer.position.z,
        GamePlayer.energyPercentage,
    );
  }

  static void debugRenderHeightMapValues() {
    var i = 0;
    for (var row = 0; row < gamestream.games.isometric.nodes.totalRows; row++){
      for (var column = 0; column < gamestream.games.isometric.nodes.totalColumns; column++){
        gamestream.games.isometric.renderer.renderTextXYZ(
             x: row * Node_Size,
             y: column * Node_Size,
             z: 5,
             text: gamestream.games.isometric.nodes.heightMap[i].toString(),
         );
         i++;
      }
    }
  }

  static void debugRenderIsland() {
    var i = 0;
    for (var row = 0; row < gamestream.games.isometric.nodes.totalRows; row++){
      for (var column = 0; column < gamestream.games.isometric.nodes.totalColumns; column++){
        if (!RendererNodes.island[i]) {
          i++;
          continue;
        }
        gamestream.games.isometric.renderer.renderTextXYZ(
          x: row * Node_Size,
          y: column * Node_Size,
          z: 5,
          text: RendererNodes.island[i].toString(),
        );
        i++;
      }
    }
  }


  static void renderObjectRadius() {
    for (var i = 0; i < ServerState.totalCharacters; i++) {
      final character = ServerState.characters[i];
      engine.renderCircle(character.renderX, character.renderY, CharacterType.getRadius(character.characterType), Colors.yellow);
    }
  }

  static void drawMouse() {
    final mouseAngle = GameMouse.playerAngle;
    final mouseDistance = min(200.0, GameMouse.playerDistance);

    final jumps = mouseDistance ~/ Node_Height_Half;

    var x1 = GamePlayer.position.x;
    var y1 = GamePlayer.position.y;
    var i1 = GamePlayer.position.nodeIndex;
    final z = GamePlayer.position.z + Node_Height_Half;

    final tX = adj(mouseAngle, Node_Height_Half);
    final tY = opp(mouseAngle, Node_Height_Half);

    for (var i = 0; i < jumps; i++) {
      final x2 = x1 - tX;
      final y2 = y1 - tY;
      final i2 = gamestream.games.isometric.nodes.getNodeIndex(x2, y2, z);
      if (!NodeType.isTransient(gamestream.games.isometric.nodes.nodeTypes[i2])) break;
      x1 = x2;
      y1 = y2;
      i1 = i2;
    }
    gamestream.games.isometric.renderer.renderCircle32(x1, y1, z);
  }

  static void renderPlayerRunTarget(){
    if (GamePlayer.dead) return;
    if (GamePlayer.targetCategory == TargetCategory.Run){
      gamestream.games.isometric.renderer.renderCircle32(GamePlayer.targetPosition.x, GamePlayer.targetPosition.y, GamePlayer.targetPosition.z);
    }
  }
}