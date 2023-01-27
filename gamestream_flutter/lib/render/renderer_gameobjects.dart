import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererGameObjects extends Renderer {
  static late GameObject gameObject;

  static final gameObjects = ServerState.gameObjects;

  @override
  int getTotal() => ServerState.totalGameObjects;

  static void renderLine(double x1, double y1, double z1, double x2, double y2, double z2) =>
    Engine.renderLine(
        renderX(x1, y1, z1),
        renderY(x1, y1, z1),
        renderX(x2, y2, z2),
        renderY(x2, y2, z2),
    );

  @override
  void renderFunction() {
    final type = gameObject.type;
    if (ItemType.isTypeGameObject(type)) {

      if (ClientState.debugMode.value) {
        renderGameObjectRadius(gameObject);
      }

      Engine.renderSprite(
        image: GameImages.atlas_gameobjects,
        dstX: gameObject.renderX,
        dstY: gameObject.renderY,
        srcX: AtlasItems.getSrcX(type),
        srcY: AtlasItems.getSrcY(type),
        anchorY: AtlasItems.getAnchorY(type),
        srcWidth: AtlasItems.getSrcWidth(type),
        srcHeight: AtlasItems.getSrcHeight(type),
        scale: AtlasItems.getSrcScale(type),
        color: GameState.getV3RenderColor(gameObject),
      );

      if (ClientState.debugMode.value) {
        renderGameObjectRadius(gameObject);
      }
      return;
    }

    assert (ItemType.isTypeItem(type));

    renderBouncingGameObjectShadow(gameObject);
    Engine.renderSprite(
      image: GameImages.atlas_items,
      dstX: GameConvert.convertV3ToRenderX(gameObject),
      dstY: getRenderYBouncing(gameObject),
      srcX: AtlasItems.getSrcX(type),
      srcY: AtlasItems.getSrcY(type),
      srcWidth: AtlasItems.size,
      srcHeight: AtlasItems.size,
      color: GameState.getV3RenderColor(gameObject),
    );
  }

  void renderGameObjectRadius(GameObject gameObject) {
    Engine.paint.color = Colors.white;
    final sections = 12;
    final anglePerSection = pi2 / sections;
    final radius = ItemType.getRadius(gameObject.type);
    var lineX1 = getAdjacent(0, radius);
    var lineY1 = getOpposite(0, radius);
    var lineX2 = lineX1;
    var lineY2 = lineY1;
    final z = gameObject.z;

    for (var i = 1; i < sections; i++){
      final a = i * anglePerSection;
      lineX2 = getAdjacent(a, radius);
      lineY2 = getOpposite(a, radius);
      renderLine(
        gameObject.x + lineX1,
        gameObject.y + lineY1,
        z,
        gameObject.x + lineX2,
        gameObject.y + lineY2,
        z,
      );
      lineX1 = lineX2;
      lineY1 = lineY2;
    }
  }

  @override
  void updateFunction() {
    gameObject = gameObjects[index];


    while (!gameObject.nodePerceptible) {
      index++;
      if (!remaining) return;
      gameObject = gameObjects[index];
    }
    order = gameObject.renderOrder;
    orderZ = gameObject.indexZ;
  }

  static double getRenderYBouncing(Vector3 v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + GameAnimation.animationFrameWaterHeight;

  static void renderBouncingGameObjectShadow(Vector3 gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;
    renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * GameAnimation.animationFrameWaterHeight.toDouble())
    );
  }
}
