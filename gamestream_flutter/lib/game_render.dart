import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/render/renderer_particles.dart';
import 'package:gamestream_flutter/render/renderer_projectiles.dart';

import 'library.dart';
import 'render/renderer_characters.dart';
import 'render/renderer_gameobjects.dart';
import 'render/renderer_nodes.dart';

class GameRender {
  static var totalRemaining = 0;
  static var totalIndex = 0;
  static final rendererNodes        = RendererNodes();
  static final rendererParticles    = RendererParticles();
  static final rendererProjectiles  = RendererProjectiles();
  static final rendererCharacters   = RendererCharacters();
  static final rendererGameObjects  = RendererGameObjects();
  static var renderDebug = false;

  // ACTIONS

  static void renderCircle(double x, double y, double z, double radius, {int sections = 12}){
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
      GameRender.renderLine(
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

  static void renderLine(double x1, double y1, double z1, double x2, double y2, double z2) =>
      engine.renderLine(
        renderX(x1, y1, z1),
        renderY(x1, y1, z1),
        renderX(x2, y2, z2),
        renderY(x2, y2, z2),
      );

  static void resetRenderOrder(Renderer value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }

  static void renderMouseWireFrame() {
    gamestream.io.mouseRaycast(renderWireFrameBlue);
  }

  static void renderMouseTargetName() {
    if (!GamePlayer.mouseTargetAllie.value) return;
    final mouseTargetName = GamePlayer.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: GamePlayer.aimTargetPosition.renderX,
        y: GamePlayer.aimTargetPosition.renderY - 55);
  }

  static Renderer next = rendererNodes;

  static void checkNext(Renderer renderer){
    if (!renderer.remaining) return;
    if (renderer.orderRowColumn > next.orderRowColumn) return;
    if (renderer.orderZ > next.orderZ) return;
    next = renderer;
  }

  static void render3D() {
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

  static void renderTextV3(Vector3 v3, dynamic text, {double offsetY = 0}){
    renderText(
      text: text.toString(),
      x: GameConvert.convertV3ToRenderX(v3),
      y: GameConvert.convertV3ToRenderY(v3) + offsetY,
    );
  }

  static void renderTextXYZ({
    required double x,
    required double y,
    required double z,
    required dynamic text,
  }) =>
    renderText(
      text: text.toString(),
      x: GameConvert.getRenderX(x, y, z),
      y: GameConvert.getRenderY(x, y, z),
    );

  static void renderWireFrameBlue(
      int z,
      int row,
      int column,
      ) {
    engine.renderSprite(
      image: GameImages.atlas_nodes,
      dstX: GameConvert.rowColumnToRenderX(row, column),
      dstY: GameConvert.rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Blue,
      srcY: AtlasNodeY.Wireframe_Blue,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      anchorY: GameConstants.Sprite_Anchor_Y,
    );
    return;
  }

  static void renderWireFrameRed(int row, int column, int z) {
    engine.renderSprite(
      image: GameImages.atlas_nodes,
      dstX: GameConvert.rowColumnToRenderX(row, column),
      dstY: GameConvert.rowColumnZToRenderY(row, column,z),
      srcX: AtlasNodeX.Wireframe_Red,
      srcY: AtlasNodeY.Wireframe_Red,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      anchorY: GameConstants.Sprite_Anchor_Y,
    );
  }

  static void canvasRenderCursorHand(ui.Canvas canvas){
    engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: 0,
        srcY: 256,
        srcWidth: 64,
        srcHeight: 64,
        dstX: gamestream.io.getCursorScreenX(),
        dstY: gamestream.io.getCursorScreenY(),
        scale: 0.5,
    );
  }

  static void canvasRenderCursorTalk(ui.Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: GameImages.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: gamestream.io.getCursorScreenX(),
      dstY: gamestream.io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  static void canvasRenderCursorCrossHair(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
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
        image: GameImages.atlas_icons,
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
        image: GameImages.atlas_icons,
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
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: gamestream.io.getCursorScreenX() + range,
        dstY: gamestream.io.getCursorScreenY(),
        anchorX: 0.0
    );
  }

  static void canvasRenderCursorCrossHairRed(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 0;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
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
        image: GameImages.atlas_icons,
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
        image: GameImages.atlas_icons,
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
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: gamestream.io.getCursorScreenX() + range,
        dstY: gamestream.io.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  static void renderCircle32(double x, double y, double z){
    engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      srcX: 16,
      srcY: 48,
      srcWidth: 32,
      srcHeight: 32,
      dstX: GameConvert.getRenderX(x, y, z),
      dstY: GameConvert.getRenderY(x, y, z),
    );
  }

  static void renderStarsV3(Vector3 v3) =>
      renderStars(v3.renderX, v3.renderY - 40);

  static void renderStars(double x, double y) =>
    engine.renderSprite(
      image: GameImages.sprite_stars,
      srcX: 125.0 * GameAnimation.animationFrame16,
      srcY: 0,
      srcWidth: 125,
      srcHeight: 125,
      dstX: x,
      dstY: y,
      scale: 0.4,
    );
}


