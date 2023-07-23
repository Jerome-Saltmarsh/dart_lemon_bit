import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/isometric_constants.dart';
import 'render/renderer_characters.dart';
import 'render/renderer_gameobjects.dart';
import 'render/renderer_nodes.dart';
import 'render/renderer_particles.dart';
import 'render/renderer_projectiles.dart';

mixin IsometricRender {
  var totalRemaining = 0;
  var totalIndex = 0;
  late final RendererNodes rendererNodes;
  late final RendererProjectiles rendererProjectiles;
  late final RendererCharacters rendererCharacters;
  late final RendererParticles rendererParticles;
  late final RendererGameObjects rendererGameObjects;
  late IsometricRenderer next = rendererNodes;

  void resetRenderOrder(IsometricRenderer value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }

  void renderMouseTargetName() {
    if (!gamestream.player.mouseTargetAllie.value) return;
    final mouseTargetName = gamestream.player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: gamestream.player.aimTargetPosition.renderX,
        y: gamestream.player.aimTargetPosition.renderY - 55);
  }

  void checkNext(IsometricRenderer renderer){
    if (
      !renderer.remaining ||
      renderer.order > next.order
    ) return;
    next = renderer;
  }

  void render3D() {
    totalRemaining = 0;
    resetRenderOrder(rendererNodes);
    resetRenderOrder(rendererCharacters);
    resetRenderOrder(rendererGameObjects);
    resetRenderOrder(rendererParticles);
    resetRenderOrder(rendererProjectiles);

    if (totalRemaining == 0) return;

    while (true) {
      next = rendererNodes;
      checkNext(rendererCharacters);
      checkNext(rendererProjectiles);
      checkNext(rendererGameObjects);
      checkNext(rendererParticles);
      if (next.remaining) {
        next.renderNext();
        continue;
      }
      totalRemaining--;
      if (totalRemaining == 0) return;

      if (totalRemaining == 1) {
        while (rendererNodes.remaining) {
          rendererNodes.renderNext();
        }
        while (rendererCharacters.remaining) {
          rendererCharacters.renderNext();
        }
        while (rendererParticles.remaining) {
          rendererParticles.renderNext();
        }
        while (rendererProjectiles.remaining) {
          rendererProjectiles.renderNext();
        }
      }
      return;
    }
  }

  // given a grid coordinate row / column workout the maximum z before it goes above the top of the screen.
  // otherwise use totalZ;
  // calculate the world position Y at row / column, then workout its distance from the top of the screen;

  void renderTextPosition(IsometricPosition v3, dynamic text, {double offsetY = 0}){
    renderText(
      text: text.toString(),
      x: IsometricRender.getPositionRenderX(v3),
      y: IsometricRender.getPositionRenderY(v3) + offsetY,
    );
  }

  void renderTextXYZ({
    required double x,
    required double y,
    required double z,
    required dynamic text,
  }) =>
      renderText(
        text: text.toString(),
        x: IsometricRender.getRenderX(x, y, z),
        y: IsometricRender.getRenderY(x, y, z),
      );

  void renderWireFrameBlue(
      int z,
      int row,
      int column,
      ) {
    gamestream.engine.renderSprite(
      image: Images.atlas_nodes,
      dstX: rowColumnToRenderX(row, column),
      dstY: rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Blue,
      srcY: AtlasNodeY.Wireframe_Blue,
      srcWidth: IsometricConstants.Sprite_Width,
      srcHeight: IsometricConstants.Sprite_Height,
      anchorY: IsometricConstants.Sprite_Anchor_Y,
    );
    return;
  }

  void renderWireFrameRed(int row, int column, int z) {
    gamestream.engine.renderSprite(
      image: Images.atlas_nodes,
      dstX: rowColumnToRenderX(row, column),
      dstY: rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Red,
      srcY: AtlasNodeY.Wireframe_Red,
      srcWidth: IsometricConstants.Sprite_Width,
      srcHeight: IsometricConstants.Sprite_Height,
      anchorY: IsometricConstants.Sprite_Anchor_Y,
    );
  }

  void canvasRenderCursorHand(ui.Canvas canvas){
    gamestream.engine.renderExternalCanvas(
      canvas: canvas,
      image: Images.atlas_icons,
      srcX: 0,
      srcY: 256,
      srcWidth: 64,
      srcHeight: 64,
      dstX: gamestream.io.getCursorScreenX(),
      dstY: gamestream.io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorTalk(ui.Canvas canvas){
    gamestream.engine.renderExternalCanvas(
      canvas: canvas,
      image: Images.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: gamestream.io.getCursorScreenX(),
      dstY: gamestream.io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorCrossHair(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: gamestream.io.getCursorScreenX(),
        dstY: gamestream.io.getCursorScreenY() - range,
        anchorY: 1.0
    );
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: gamestream.io.getCursorScreenX(),
        dstY: gamestream.io.getCursorScreenY() + range,
        anchorY: 0.0
    );
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: gamestream.io.getCursorScreenX() - range,
        dstY: gamestream.io.getCursorScreenY(),
        anchorX: 1.0
    );
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: gamestream.io.getCursorScreenX() + range,
        dstY: gamestream.io.getCursorScreenY(),
        anchorX: 0.0
    );
  }

  void canvasRenderCursorCrossHairRed(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 0;
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: gamestream.io.getCursorScreenX(),
        dstY: gamestream.io.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: gamestream.io.getCursorScreenX(),
        dstY: gamestream.io.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: gamestream.io.getCursorScreenX() - range,
        dstY: gamestream.io.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    gamestream.engine.renderExternalCanvas(
        canvas: canvas,
        image: Images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: gamestream.io.getCursorScreenX() + range,
        dstY: gamestream.io.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  void renderCircle32(double x, double y, double z){
    gamestream.engine.renderSprite(
      image: Images.atlas_gameobjects,
      srcX: 16,
      srcY: 48,
      srcWidth: 32,
      srcHeight: 32,
      dstX: getRenderX(x, y, z),
      dstY: getRenderY(x, y, z),
    );
  }

  void renderStarsV3(IsometricPosition v3) =>
      renderStars(v3.renderX, v3.renderY - 40);

  void renderStars(double x, double y) =>
      gamestream.engine.renderSprite(
        image: Images.sprite_stars,
        srcX: 125.0 * gamestream.animationFrame16,
        srcY: 0,
        srcWidth: 125,
        srcHeight: 125,
        dstX: x,
        dstY: y,
        scale: 0.4,
      );

  void playerAimTargetNameText(){
    if (gamestream.player.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (gamestream.player.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    gamestream.engine.renderText(
      gamestream.player.aimTargetName,
      gamestream.engine.worldToScreenX(gamestream.player.aimTargetPosition.renderX),
      gamestream.engine.worldToScreenY(gamestream.player.aimTargetPosition.renderY),
      style: style,
    );
  }

  void renderCursor(Canvas canvas) {
    final cooldown = gamestream.player.weaponCooldown.value;
    final accuracy = gamestream.player.accuracy.value;
    final distance = ((1.0 - cooldown) + (1.0 - accuracy)) * 10.0 + 5;

    switch (gamestream.cursorType) {
      case IsometricCursorType.CrossHair_White:
        canvasRenderCursorCrossHair(canvas, distance);
        break;
      case IsometricCursorType.Hand:
        canvasRenderCursorHand(canvas);
        return;
      case IsometricCursorType.Talk:
        canvasRenderCursorTalk(canvas);
        return;
      case IsometricCursorType.CrossHair_Red:
        canvasRenderCursorCrossHairRed(canvas, distance);
        break;
    }
  }

  void renderPlayerEnergy() {
    if (gamestream.player.dead) return;
    if (!gamestream.player.active.value) return;
    renderBarBlue(
      gamestream.player.position.x,
      gamestream.player.position.y,
      gamestream.player.position.z,
      gamestream.player.energyPercentage,
    );
  }

  void debugRenderHeightMapValues() {
    var i = 0;
    for (var row = 0; row < gamestream.totalRows; row++){
      for (var column = 0; column < gamestream.totalColumns; column++){
        gamestream.renderTextXYZ(
          x: row * Node_Size,
          y: column * Node_Size,
          z: 5,
          text: gamestream.heightMap[i].toString(),
        );
        i++;
      }
    }
  }

  // void debugRenderIsland() {
  //   var i = 0;
  //   for (var row = 0; row < gamestream.isometric.scene.totalRows; row++){
  //     for (var column = 0; column < gamestream.isometric.scene.totalColumns; column++){
  //       if (!RendererNodes.island[i]) {
  //         i++;
  //         continue;
  //       }
  //       gamestream.isometric.renderer.renderTextXYZ(
  //         x: row * Node_Size,
  //         y: column * Node_Size,
  //         z: 5,
  //         text: RendererNodes.island[i].toString(),
  //       );
  //       i++;
  //     }
  //   }
  // }


  void renderObjectRadius() {
    for (var i = 0; i < gamestream.totalCharacters; i++) {
      final character = gamestream.characters[i];
      gamestream.engine.renderCircle(character.renderX, character.renderY, CharacterType.getRadius(character.characterType), Colors.yellow);
    }
  }

  // void drawMouse() {
  //   final mouseAngle = mouse.playerAngle;
  //   final mouseDistance = min(200.0, IsometricMouse.playerDistance);
  //
  //   final jumps = mouseDistance ~/ Node_Height_Half;
  //
  //   var x1 = gamestream.player.position.x;
  //   var y1 = gamestream.player.position.y;
  //   var i1 = gamestream.player.nodeIndex;
  //   final z = gamestream.player.position.z + Node_Height_Half;
  //
  //   final tX = adj(mouseAngle, Node_Height_Half);
  //   final tY = opp(mouseAngle, Node_Height_Half);
  //
  //   for (var i = 0; i < jumps; i++) {
  //     final x2 = x1 - tX;
  //     final y2 = y1 - tY;
  //     final i2 = gamestream.getIndexXYZ(x2, y2, z);
  //     if (!NodeType.isTransient(gamestream.nodeTypes[i2])) break;
  //     x1 = x2;
  //     y1 = y2;
  //     i1 = i2;
  //   }
  //   gamestream.renderCircle32(x1, y1, z);
  // }

  void renderCharacterHealthBar(IsometricCharacter character) =>
      renderHealthBarPosition(
          position: character,
          percentage: character.health,
          color: character.color,
      );

  void renderHealthBarPosition({
    required IsometricPosition position,
    required double percentage,
    int color = 1,
  }) => gamestream.engine.renderSprite(
      image: Images.atlas_gameobjects,
      dstX: IsometricRender.getPositionRenderX(position) - 26,
      dstY: IsometricRender.getPositionRenderY(position) - 45,
      srcX: 171,
      srcY: 16,
      srcWidth: 51.0 * percentage,
      srcHeight: 8,
      anchorX: 0.0,
      color: color,
    );

  void renderBarBlue(double x, double y, double z, double percentage) {
    gamestream.engine.renderSprite(
      image: Images.atlas_gameobjects,
      dstX: getRenderX(x, y, z) - 26,
      dstY: getRenderY(x, y, z) - 55,
      srcX: 171,
      srcY: 48,
      srcWidth: 51.0 * percentage,
      srcHeight: 8,
      anchorX: 0.0,
      color: 1,
    );
  }

  void renderEditWireFrames() {
    for (var z = 0; z < gamestream.editor.z; z++) {
      gamestream.renderWireFrameBlue(z, gamestream.editor.row, gamestream.editor.column);
    }
    gamestream.renderWireFrameRed(gamestream.editor.row, gamestream.editor.column, gamestream.editor.z);
  }

  void renderText({required String text, required double x, required double y}){
    const charWidth = 4.5;
    gamestream.engine.writeText(text, x - charWidth * text.length, y);
  }

  static double rowColumnZToRenderX(int row, int column) =>
      (row - column) * Node_Size_Half;

  static double rowColumnToRenderX(int row, int column) =>
      (row - column) * Node_Size_Half;

  static double rowColumnZToRenderY(int row, int column, int z) =>
      (row + column - z) * Node_Size_Half;

  static double rowColumnToRenderY(int row, int column) =>
      (row + column) * Node_Size_Half;


  static double getPositionRenderX(IsometricPosition v3) => getRenderX(v3.x, v3.y, v3.z);
  static double getPositionRenderY(IsometricPosition v3) => getRenderY(v3.x, v3.y, v3.z);

  static double getRenderX(double x, double y, double z) => (x - y) * 0.5;
  static double getRenderY(double x, double y, double z) => ((x + y) * 0.5) - z;

  static double convertWorldToGridX(double x, double y) => x + y;
  static double convertWorldToGridY(double x, double y) => y - x;

  static int convertWorldToRow(double x, double y, double z) => (x + y + z) ~/ Node_Size;
  static int convertWorldToColumn(double x, double y, double z) => (y - x + z) ~/ Node_Size;

  /// converts grid coordinates to screen space
  double getScreenX(double x, double y, double z) => gamestream.engine.worldToScreenX(getRenderX(x, y, z));
  /// converts grid coordinates to screen space
  double getScreenY(double x, double y, double z) => gamestream.engine.worldToScreenX(getRenderY(x, y, z));

  void renderForeground(Canvas canvas, Size size) {

    renderCursor(canvas);
    // if (gamestream.io.inputModeKeyboard){
    //   if (gamestream.engine.mouseOverCanvas){
    //     renderCursor(canvas);
    //   }
    // }

    if (gamestream.io.inputModeTouch) {
      gamestream.io.touchController.render(canvas);
    }

    playerAimTargetNameText();
  }

}


