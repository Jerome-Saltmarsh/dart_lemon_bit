import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends IsometricRenderer {
  static late IsometricGameObject gameObject;

  static final gameObjects = gamestream.isometric.serverState.gameObjects;
  final IsometricNodes nodes;

  RendererGameObjects(this.nodes);

  @override
  int getTotal() {
    return gameObjects.length;
  }

  @override
  void renderFunction() {
    final type = gameObject.type;

    if (type == ItemType.Resource_Credit) {
      const srcY = 125.0 * 6;
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: srcY,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.3
      );
      return;
    }

    if (ItemType.isTypeGameObject(type)) {
      engine.renderSprite(
        image: GameImages.atlas_gameobjects,
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: AtlasItems.getSrcX(type),
        srcY: AtlasItems.getSrcY(type),
        anchorY: AtlasItems.getAnchorY(type),
        srcWidth: AtlasItems.getSrcWidth(type),
        srcHeight: AtlasItems.getSrcHeight(type),
        scale: AtlasItems.getSrcScale(type),
        color: gameObject.emission_type != IsometricEmissionType.Color
            ? nodes.getV3RenderColor(gameObject)
            : gameObject.emission_col,
      );
      if (gamestream.isometric.renderer.renderDebug) {
        renderGameObjectRadius(gameObject);
      }

      return;
    }

    if (type == ItemType.Weapon_Ranged_Plasma_Rifle) {
      engine.renderSprite(
        image: GameImages.atlas_weapons,
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: gamestream.animation.animationFrame16 * 125.0,
        srcY: 125,
        srcWidth: 125,
        srcHeight: 125,
        color: nodes.getV3RenderColor(gameObject),
        scale: 0.3
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Plasma_Pistol) {
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: 0,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Shotgun) {
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: 250,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Bazooka) {
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: 375,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Flamethrower) {
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: 500,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.4
      );
      return;
    }

    if (type == ItemType.Weapon_Ranged_Sniper_Rifle) {
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: 625,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.4
      );
      return;
    }
    if (type == ItemType.Weapon_Ranged_Teleport) {
      engine.renderSprite(
          image: GameImages.atlas_weapons,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: gamestream.animation.animationFrame16 * 125.0,
          srcY: 875,
          srcWidth: 125,
          srcHeight: 125,
          color: nodes.getV3RenderColor(gameObject),
          scale: 0.5
      );
      return;
    }

    assert (ItemType.isTypeItem(type));

    renderBouncingGameObjectShadow(gameObject);
    engine.renderSprite(
      image: GameImages.atlas_items,
      dstX: gameObject.renderX,
      dstY: getRenderYBouncing(gameObject),
      srcX: AtlasItems.getSrcX(type),
      srcY: AtlasItems.getSrcY(type),
      srcWidth: AtlasItems.getSrcWidth(type),
      srcHeight: AtlasItems.getSrcHeight(type),
      scale: AtlasItems.getSrcScale(gameObject.type),
      color: nodes.getV3RenderColor(gameObject),
    );
  }

  void renderGameObjectRadius(IsometricGameObject gameObject) {
    gamestream.isometric.renderer.renderCircle(
        gameObject.x,
        gameObject.y,
        gameObject.z, ItemType.getRadius(gameObject.type),
    );
  }

  @override
  void updateFunction() {
    gameObject = gameObjects[index];

    while (!gameObject.active || !gameObject.onscreenPadded || !gameObject.nodePerceptible) {
      index++;
      if (!remaining) return;
      gameObject = gameObjects[index];
    }

    orderZ = gameObject.indexZ;
    orderRowColumn = gameObject.indexSum;
  }

  static double getRenderYBouncing(IsometricPosition v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + gamestream.animation.animationFrameWaterHeight;

  static void renderBouncingGameObjectShadow(IsometricPosition gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;
    renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * gamestream.animation.animationFrameWaterHeight.toDouble())
    );
  }
}
