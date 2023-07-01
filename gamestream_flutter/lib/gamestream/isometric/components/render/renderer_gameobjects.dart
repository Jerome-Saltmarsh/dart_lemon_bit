import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_gameobject.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends IsometricRenderer {
  static late IsometricGameObject gameObject;

  static final gameObjects = gamestream.isometric.server.gameObjects;
  final IsometricScene nodes;

  RendererGameObjects(this.nodes);

  @override
  int getTotal() {
    return gameObjects.length;
  }

  @override
  void renderFunction() {
    final type = gameObject.type;
    final subType = gameObject.subType;

    switch (type) {

      case GameObjectType.Object:
        engine.renderSprite(
          image: GameImages.atlas_gameobjects,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          srcX: AtlasItems.getSrcX(type, subType),
          srcY: AtlasItems.getSrcY(type, subType),
          anchorY: AtlasItems.getAnchorY(type, subType),
          srcWidth: AtlasItems.getSrcWidth(type, subType),
          srcHeight: AtlasItems.getSrcHeight(type, subType),
          scale: AtlasItems.getSrcScale(type, subType),
          color: gameObject.emission_type != IsometricEmissionType.Color
              ? nodes.getV3RenderColor(gameObject)
              : gameObject.emission_col,
        );

      default:
        renderBouncingGameObjectShadow(gameObject);
        engine.renderSprite(
          image: GameImages.atlas_items,
          dstX: gameObject.renderX,
          dstY: getRenderYBouncing(gameObject),
          srcX: AtlasItems.getSrcX(type, subType),
          srcY: AtlasItems.getSrcY(type, subType),
          srcWidth: AtlasItems.getSrcWidth(type, subType),
          srcHeight: AtlasItems.getSrcHeight(type, subType),
          scale: AtlasItems.getSrcScale(type, subType),
          color: nodes.getV3RenderColor(gameObject),
        );
        break;
    }

    // if (type == ItemType.Weapon_Ranged_Plasma_Rifle) {
    //   engine.renderSprite(
    //     image: GameImages.atlas_weapons,
    //     dstX: gameObject.renderX,
    //     dstY: gameObject.renderY,
    //     srcX: gamestream.animation.animationFrame16 * 125.0,
    //     srcY: 125,
    //     srcWidth: 125,
    //     srcHeight: 125,
    //     color: nodes.getV3RenderColor(gameObject),
    //     scale: 0.3
    //   );
    //   return;
    // }

    // if (type == ItemType.Weapon_Ranged_Plasma_Pistol) {
    //   engine.renderSprite(
    //       image: GameImages.atlas_weapons,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: gamestream.animation.animationFrame16 * 125.0,
    //       srcY: 0,
    //       srcWidth: 125,
    //       srcHeight: 125,
    //       color: nodes.getV3RenderColor(gameObject),
    //       scale: 0.5
    //   );
    //   return;
    // }
    //
    // if (type == ItemType.Weapon_Ranged_Shotgun) {
    //   engine.renderSprite(
    //       image: GameImages.atlas_weapons,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: gamestream.animation.animationFrame16 * 125.0,
    //       srcY: 250,
    //       srcWidth: 125,
    //       srcHeight: 125,
    //       color: nodes.getV3RenderColor(gameObject),
    //       scale: 0.5
    //   );
    //   return;
    // }
    //
    // if (type == ItemType.Weapon_Ranged_Bazooka) {
    //   engine.renderSprite(
    //       image: GameImages.atlas_weapons,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: gamestream.animation.animationFrame16 * 125.0,
    //       srcY: 375,
    //       srcWidth: 125,
    //       srcHeight: 125,
    //       color: nodes.getV3RenderColor(gameObject),
    //       scale: 0.5
    //   );
    //   return;
    // }
    //
    // if (type == ItemType.Weapon_Ranged_Flamethrower) {
    //   engine.renderSprite(
    //       image: GameImages.atlas_weapons,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: gamestream.animation.animationFrame16 * 125.0,
    //       srcY: 500,
    //       srcWidth: 125,
    //       srcHeight: 125,
    //       color: nodes.getV3RenderColor(gameObject),
    //       scale: 0.4
    //   );
    //   return;
    // }
    //
    // if (type == ItemType.Weapon_Ranged_Sniper_Rifle) {
    //   engine.renderSprite(
    //       image: GameImages.atlas_weapons,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: gamestream.animation.animationFrame16 * 125.0,
    //       srcY: 625,
    //       srcWidth: 125,
    //       srcHeight: 125,
    //       color: nodes.getV3RenderColor(gameObject),
    //       scale: 0.4
    //   );
    //   return;
    // }
    // if (type == ItemType.Weapon_Ranged_Teleport) {
    //   engine.renderSprite(
    //       image: GameImages.atlas_weapons,
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       srcX: gamestream.animation.animationFrame16 * 125.0,
    //       srcY: 875,
    //       srcWidth: 125,
    //       srcHeight: 125,
    //       color: nodes.getV3RenderColor(gameObject),
    //       scale: 0.5
    //   );
    //   return;
    // }

    // assert (ItemType.isTypeItem(type));


  }

  // void renderGameObjectRadius(IsometricGameObject gameObject) {
  //   gamestream.isometric.renderer.renderCircle(
  //       gameObject.x,
  //       gameObject.y,
  //       gameObject.z, ItemType.getRadius(gameObject.type),
  //   );
  // }

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
