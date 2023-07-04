import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/game_isometric_constants.dart';
import 'isometric_mouse.dart';
import 'render/renderer_characters.dart';
import 'render/renderer_gameobjects.dart';
import 'render/renderer_nodes.dart';
import 'render/renderer_particles.dart';
import 'render/renderer_projectiles.dart';

class IsometricRender {
  var totalRemaining = 0;
  var totalIndex = 0;
  final RendererNodes rendererNodes;
  final RendererProjectiles rendererProjectiles;
  final RendererCharacters rendererCharacters;
  final RendererParticles rendererParticles;
  final RendererGameObjects rendererGameObjects;
  late IsometricRenderer next = rendererNodes;
  var renderDebug = false;

  IsometricRender({
    required this.rendererCharacters,
    required this.rendererGameObjects,
    required this.rendererParticles,
    required this.rendererNodes,
    required this.rendererProjectiles
  });

  void renderCircleAtIsometricPosition({
    required IsometricPosition position,
    required double radius,
    int sections = 12,
  })=> renderCircle(position.x, position.y, position.z, radius, sections: sections);

  void renderCircle(double x, double y, double z, double radius, {int sections = 12}){
    if (radius <= 0) return;
    if (sections < 3) return;

    engine.paint.color = Colors.white;
    final anglePerSection = pi2 / sections;
    var lineX1 = adj(0, radius);
    var lineY1 = opp(0, radius);
    var lineX2 = lineX1;
    var lineY2 = lineY1;
    for (var i = 1; i <= sections; i++){
      final a = i * anglePerSection;
      lineX2 = adj(a, radius);
      lineY2 = opp(a, radius);
      renderLine(
        x + lineX1,
        y + lineY1,
        z,
        x + lineX2,
        y + lineY2,
        z,
      );
      lineX1 = lineX2;
      lineY1 = lineY2;
    }
  }

  void renderLine(double x1, double y1, double z1, double x2, double y2, double z2) =>
      engine.renderLine(
        renderX(x1, y1, z1),
        renderY(x1, y1, z1),
        renderX(x2, y2, z2),
        renderY(x2, y2, z2),
      );

  void resetRenderOrder(IsometricRenderer value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }

  void renderMouseWireFrame() {
    gamestream.io.mouseRaycast(renderWireFrameBlue);
  }

  void renderMouseTargetName() {
    if (!gamestream.isometric.player.mouseTargetAllie.value) return;
    final mouseTargetName = gamestream.isometric.player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: gamestream.isometric.player.aimTargetPosition.renderX,
        y: gamestream.isometric.player.aimTargetPosition.renderY - 55);
  }

  void checkNext(IsometricRenderer renderer){
    if (!renderer.remaining) return;
    if (renderer.orderRowColumn > next.orderRowColumn) return;
    if (renderer.orderZ > next.orderZ) return;
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
    engine.renderSprite(
      image: Images.atlas_nodes,
      dstX: rowColumnToRenderX(row, column),
      dstY: rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Blue,
      srcY: AtlasNodeY.Wireframe_Blue,
      srcWidth: GameIsometricConstants.Sprite_Width,
      srcHeight: GameIsometricConstants.Sprite_Height,
      anchorY: GameIsometricConstants.Sprite_Anchor_Y,
    );
    return;
  }

  void renderWireFrameRed(int row, int column, int z) {
    engine.renderSprite(
      image: Images.atlas_nodes,
      dstX: rowColumnToRenderX(row, column),
      dstY: rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Red,
      srcY: AtlasNodeY.Wireframe_Red,
      srcWidth: GameIsometricConstants.Sprite_Width,
      srcHeight: GameIsometricConstants.Sprite_Height,
      anchorY: GameIsometricConstants.Sprite_Anchor_Y,
    );
  }

  void canvasRenderCursorHand(ui.Canvas canvas){
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderExternalCanvas(
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
    engine.renderSprite(
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
      engine.renderSprite(
        image: Images.sprite_stars,
        srcX: 125.0 * gamestream.isometric.animation.animationFrame16,
        srcY: 0,
        srcWidth: 125,
        srcHeight: 125,
        dstX: x,
        dstY: y,
        scale: 0.4,
      );




  void renderForeground(Canvas canvas, Size size) {

    if (gamestream.io.inputModeKeyboard){
      if (!gamestream.isometric.ui.mouseOverDialog.value){
        renderCursor(canvas);
      }
    }

    if (gamestream.io.inputModeTouch) {
      gamestream.io.touchController.render(canvas);
    }

    playerAimTargetNameText();
  }

  void playerAimTargetNameText(){
    if (gamestream.isometric.player.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (gamestream.isometric.player.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    engine.renderText(
      gamestream.isometric.player.aimTargetName,
      engine.worldToScreenX(gamestream.isometric.player.aimTargetPosition.renderX),
      engine.worldToScreenY(gamestream.isometric.player.aimTargetPosition.renderY),
      style: style,
    );
  }

  void renderCursor(Canvas canvas) {
    final cooldown = gamestream.isometric.player.weaponCooldown.value;
    final accuracy = gamestream.isometric.player.accuracy.value;
    final distance = (cooldown + accuracy) * 10.0 + 5;

    switch (gamestream.isometric.client.cursorType) {
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
    if (gamestream.isometric.player.dead) return;
    if (!gamestream.isometric.player.active.value) return;
    renderBarBlue(
      gamestream.isometric.player.position.x,
      gamestream.isometric.player.position.y,
      gamestream.isometric.player.position.z,
      gamestream.isometric.player.energyPercentage,
    );
  }

  void debugRenderHeightMapValues() {
    var i = 0;
    for (var row = 0; row < gamestream.isometric.scene.totalRows; row++){
      for (var column = 0; column < gamestream.isometric.scene.totalColumns; column++){
        gamestream.isometric.renderer.renderTextXYZ(
          x: row * Node_Size,
          y: column * Node_Size,
          z: 5,
          text: gamestream.isometric.scene.heightMap[i].toString(),
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
    for (var i = 0; i < gamestream.isometric.server.totalCharacters; i++) {
      final character = gamestream.isometric.server.characters[i];
      engine.renderCircle(character.renderX, character.renderY, CharacterType.getRadius(character.characterType), Colors.yellow);
    }
  }

  void drawMouse() {
    final mouseAngle = IsometricMouse.playerAngle;
    final mouseDistance = min(200.0, IsometricMouse.playerDistance);

    final jumps = mouseDistance ~/ Node_Height_Half;

    var x1 = gamestream.isometric.player.position.x;
    var y1 = gamestream.isometric.player.position.y;
    var i1 = gamestream.isometric.player.nodeIndex;
    final z = gamestream.isometric.player.position.z + Node_Height_Half;

    final tX = adj(mouseAngle, Node_Height_Half);
    final tY = opp(mouseAngle, Node_Height_Half);

    for (var i = 0; i < jumps; i++) {
      final x2 = x1 - tX;
      final y2 = y1 - tY;
      final i2 = gamestream.isometric.scene.getIndexXYZ(x2, y2, z);
      if (!NodeType.isTransient(gamestream.isometric.scene.nodeTypes[i2])) break;
      x1 = x2;
      y1 = y2;
      i1 = i2;
    }
    gamestream.isometric.renderer.renderCircle32(x1, y1, z);
  }

  void renderCharacterHealthBar(IsometricCharacter character) =>
      renderHealthBarPosition(
          position: character,
          percentage: character.health,
      );

  void renderHealthBarPosition({
    required IsometricPosition position,
    required double percentage,
  }) => engine.renderSprite(
      image: Images.atlas_gameobjects,
      dstX: IsometricRender.getPositionRenderX(position) - 26,
      dstY: IsometricRender.getPositionRenderY(position) - 45,
      srcX: 171,
      srcY: 16,
      srcWidth: 51.0 * percentage,
      srcHeight: 8,
      anchorX: 0.0,
      color: 1,
    );

  void renderBarBlue(double x, double y, double z, double percentage) {
    engine.renderSprite(
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

  void renderEditMode() {
    if (gamestream.isometric.client.playMode) return;
    if (gamestream.isometric.editor.gameObjectSelected.value){
      engine.renderCircleOutline(
        sides: 24,
        // radius: ItemType.getRadius(gamestream.isometric.editor.gameObjectSelectedType.value),
        radius: 30,
        x: gamestream.isometric.editor.gameObject.value!.renderX,
        y: gamestream.isometric.editor.gameObject.value!.renderY,
        color: Colors.white,
      );
      renderCircleAtIsometricPosition(position: gamestream.isometric.editor.gameObject.value!, radius: 50);
      return;
    }

    renderEditWireFrames();
    gamestream.isometric.renderer.renderMouseWireFrame();
  }

  void renderEditWireFrames() {
    for (var z = 0; z < gamestream.isometric.editor.z; z++) {
      gamestream.isometric.renderer.renderWireFrameBlue(z, gamestream.isometric.editor.row, gamestream.isometric.editor.column);
    }
    gamestream.isometric.renderer.renderWireFrameRed(gamestream.isometric.editor.row, gamestream.isometric.editor.column, gamestream.isometric.editor.z);
  }

  void renderText({required String text, required double x, required double y}){
    const charWidth = 4.5;
    engine.writeText(text, x - charWidth * text.length, y);
  }

  static double rowColumnZToRenderX(int row, int column) =>
      (row - column) * Node_Size_Half;

  static double rowColumnToRenderX(int row, int column) =>
      (row - column) * Node_Size_Half;

  static double rowColumnZToRenderY(int row, int column, int z) =>
      (row + column - z) * Node_Size_Half;

  static double rowColumnToRenderY(int row, int column) =>
      (row + column) * Node_Size_Half;


  static double renderX(double x, double y, double z) => (x - y) * 0.5;
  static double renderY(double x, double y, double z) => ((x + y) * 0.5) - z;

  static double getPositionRenderX(IsometricPosition v3) => getRenderX(v3.x, v3.y, v3.z);
  static double getPositionRenderY(IsometricPosition v3) => getRenderY(v3.x, v3.y, v3.z);

  static double getRenderX(double x, double y, double z) => (x - y) * 0.5;
  static double getRenderY(double x, double y, double z) => ((x + y) * 0.5) - z;

  static double convertWorldToGridX(double x, double y) => x + y;
  static double convertWorldToGridY(double x, double y) => y - x;

  static int convertWorldToRow(double x, double y, double z) => (x + y + z) ~/ Node_Size;
  static int convertWorldToColumn(double x, double y, double z) => (y - x + z) ~/ Node_Size;

  /// converts grid coordinates to screen space
  double getScreenX(double x, double y, double z) => engine.worldToScreenX(getRenderX(x, y, z));
  /// converts grid coordinates to screen space
  double getScreenY(double x, double y, double z) => engine.worldToScreenX(getRenderY(x, y, z));

}


