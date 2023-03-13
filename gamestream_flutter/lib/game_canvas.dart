
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/render/renderer_nodes.dart';

import 'isometric/render/render_character_health_bar.dart';

class GameCanvas {
  static void renderForegroundText(Vector3 position, String text){
    Engine.renderText(
      text,
      Engine.worldToScreenX(position.renderX),
      Engine.worldToScreenY(position.renderY),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  static void renderText({required double x, required double y, required double z, required String text}){
    Engine.renderText(
      text,
      Engine.worldToScreenX(GameConvert.getRenderX(x, y, z)),
      Engine.worldToScreenY(GameConvert.getRenderY(x, y, z)),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  static void renderForeground(Canvas canvas, Size size) {
    if (ClientState.hoverDialogType.value == DialogType.None){
      renderCursor(canvas);
    }

     renderGamePlayerAimTargetNameText();
  }

  static void renderGamePlayerAimTargetNameText(){
    if (GamePlayer.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (GamePlayer.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    Engine.renderText(
      GamePlayer.aimTargetName,
      Engine.worldToScreenX(GamePlayer.aimTargetPosition.renderX),
      Engine.worldToScreenY(GamePlayer.aimTargetPosition.renderY),
      style: style,
    );
  }

  static void renderCursor(Canvas canvas) {
    final cooldown = GamePlayer.weaponCooldown.value;
    final accuracy = ServerState.playerAccuracy.value;
    final distance = (cooldown + accuracy) * 10.0 + 5;

    switch (GamePlayer.aimTargetCategory) {
      case TargetCategory.Nothing:
        GameRender.canvasRenderCursorCrossHair(canvas, distance);

        if (ServerQuery.getEquippedWeaponConsumeType() != ItemType.Empty){
           if (ServerQuery.getEquippedWeaponQuantity() <= 0){
             Engine.renderExternalCanvas(
               canvas: canvas,
               image: GameImages.atlas_icons,
               srcX: 272,
               srcY: 0,
               srcWidth: 128,
               srcHeight: 32,
               dstX: Engine.mousePosition.x,
               dstY: Engine.mousePosition.y - 70,
             );
           }
        }

        break;
      case TargetCategory.Collect:
        GameRender.canvasRenderCursorHand(canvas);
        return;
      case TargetCategory.Allie:
        GameRender.canvasRenderCursorTalk(canvas);
        return;
      case TargetCategory.Enemy:
        GameRender.canvasRenderCursorCrossHairRed(canvas, distance);

        if (ServerQuery.getEquippedWeaponConsumeType() != ItemType.Empty){
          if (ServerQuery.getEquippedWeaponQuantity() <= 0){
            Engine.renderExternalCanvas(
              canvas: canvas,
              image: GameImages.atlas_icons,
              srcX: 272,
              srcY: 0,
              srcWidth: 128,
              srcHeight: 32,
              dstX: Engine.mousePosition.x,
              dstY: Engine.mousePosition.y - 70,
            );
          }
        }


        break;
    }
  }


  static void renderCanvas(Canvas canvas, Size size) {

    if (ServerState.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      GameState.updateParticles();
    }
    GameState.interpolatePlayer();
    GameCamera.update();
    GameRender.render3D();
    GameState.renderEditMode();
    GameRender.renderMouseTargetName();
    ClientState.rendersSinceUpdate.value++;
    renderPlayerRunTarget();

    renderBarBlue(
        GamePlayer.position.x,
        GamePlayer.position.y,
        GamePlayer.position.z,
        GamePlayer.energyPercentage,
    );

    if (ClientState.debugMode.value){
      debugRenderIsland();
    }
  }

  static void debugRenderHeightMapValues() {
    var i = 0;
    for (var row = 0; row < GameNodes.totalRows; row++){
      for (var column = 0; column < GameNodes.totalColumns; column++){
         GameRender.renderTextXYZ(
             x: row * Node_Size,
             y: column * Node_Size,
             z: 5,
             text: GameNodes.heightMap[i].toString(),
         );
         i++;
      }
    }
  }

  static void debugRenderIsland() {
    var i = 0;
    for (var row = 0; row < GameNodes.totalRows; row++){
      for (var column = 0; column < GameNodes.totalColumns; column++){
        if (!RendererNodes.island[i]) {
          i++;
          continue;
        }
        GameRender.renderTextXYZ(
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
      Engine.renderCircle(character.renderX, character.renderY, CharacterType.getRadius(character.characterType), Colors.yellow);
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

    final tX = Engine.calculateAdjacent(mouseAngle, Node_Height_Half);
    final tY = Engine.calculateOpposite(mouseAngle, Node_Height_Half);

    for (var i = 0; i < jumps; i++) {
      final x2 = x1 - tX;
      final y2 = y1 - tY;
      final i2 = GameQueries.getNodeIndex(x2, y2, z);
      if (!NodeType.isTransient(GameNodes.nodeTypes[i2])) break;
      x1 = x2;
      y1 = y2;
      i1 = i2;
    }
    GameRender.renderCircle32(x1, y1, z);
  }

  static void renderPlayerRunTarget(){
    if (GamePlayer.targetCategory == TargetCategory.Run){
      GameRender.renderCircle32(GamePlayer.targetPosition.x, GamePlayer.targetPosition.y, GamePlayer.targetPosition.z);
    }
  }
}