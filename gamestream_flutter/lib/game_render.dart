import 'dart:ui' as ui;

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
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

  // ACTIONS

  static void resetRenderOrder(Renderer value){
    value.reset();
    if (value.remaining){
      totalRemaining++;
    }
  }

  static void renderMouseWireFrame() {
    GameIO.mouseRaycast(renderWireFrameBlue);
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

  static void render3D() {
    totalRemaining = 0;
    resetRenderOrder(rendererCharacters);
    resetRenderOrder(rendererGameObjects);
    resetRenderOrder(rendererNodes);
    resetRenderOrder(rendererParticles);
    resetRenderOrder(rendererProjectiles);

    var first = rendererNodes;

    if (totalRemaining == 0) return;
    while (true) {
      Renderer next = first;
      if (rendererCharacters.remaining){
        next = next.compare(rendererCharacters);
      }
      if (rendererProjectiles.remaining){
        next = next.compare(rendererProjectiles);
      }
      if (rendererGameObjects.remaining){
        next = next.compare(rendererGameObjects);
      }
      if (rendererParticles.remaining){
        next = next.compare(rendererParticles);
      }
      if (next.remaining){
        next.renderNext();
        continue;
      }
      totalRemaining--;
      if (totalRemaining <= 0) return;

      if (totalRemaining > 1) {
        if (next == rendererNodes) {
          if (rendererCharacters.remaining) {
            next = rendererCharacters;
          }
          if (rendererProjectiles.remaining) {
            next = rendererProjectiles;
          }
          if (rendererGameObjects.remaining) {
            next = rendererGameObjects;
          }
          if (rendererParticles.remaining) {
            next = rendererParticles;
          }
        }
        continue;
      }

      while (rendererNodes.remaining) {
        rendererNodes.renderNext();
      }
      while (rendererCharacters.remaining) {
        rendererCharacters.renderNext();
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

  static void renderWireFrameBlue(
      int z,
      int row,
      int column,
      ) {
    Engine.renderSprite(
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
    Engine.renderSprite(
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
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: 0,
        srcY: 256,
        srcWidth: 64,
        srcHeight: 64,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY(),
        scale: 0.5,
    );
  }

  static void canvasRenderCursorTalk(ui.Canvas canvas){
    Engine.renderExternalCanvas(
      canvas: canvas,
      image: GameImages.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: GameIO.getCursorScreenX(),
      dstY: GameIO.getCursorScreenY(),
      scale: 0.5,
    );
  }

  static void canvasRenderCursorCrossHair(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    const offset = 18.0 * 1.5;
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() - range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() + range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  static void canvasRenderCursorCrossHairRed(ui.Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 18.0 * 1.5;
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: GameIO.getCursorScreenX(),
        dstY: GameIO.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() - range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    Engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: GameIO.getCursorScreenX() + range,
        dstY: GameIO.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  static void renderCircle32(double x, double y, double z){
    Engine.renderSprite(
      image: GameImages.atlas_gameobjects,
      srcX: AtlasGameObjects.Circle32_X,
      srcY: AtlasGameObjects.Circle32_Y,
      srcWidth: 32,
      srcHeight: 32,
      dstX: GameConvert.getRenderX(x, y, z),
      dstY: GameConvert.getRenderY(x, y, z),
    );
  }
}


