import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/library.dart';

import '../functions/format_percentage.dart';

class RendererGameObjects extends RenderGroup {

  late final Map<int, Image> mapGameObjectTypeToImage;

  @override
  void onComponentReady() {
    mapGameObjectTypeToImage = {
      GameObjectType.Weapon: images.atlas_weapons,
      GameObjectType.Object: images.atlas_gameobjects,
      GameObjectType.Head: images.atlas_head,
      GameObjectType.Body: images.atlas_body,
      GameObjectType.Legs: images.atlas_legs,
      GameObjectType.Item: images.atlas_items,
      GameObjectType.Hand: images.atlas_hands,
    };
  }

  Image getImageForGameObjectType(int type) =>
      mapGameObjectTypeToImage [type] ?? (
          throw Exception(
              'getImageForGameObjectType(type: ${GameObjectType.getName(type)}})'
          )
      );

  late GameObject gameObject;

  @override
  int getTotal() => scene.gameObjects.length;

  @override
  void renderFunction() {
    final type = gameObject.type;
    final image = getImageForGameObjectType(type);
    final src = Atlas.getSrc(type, gameObject.subType);

    final isCollectable = const [
      GameObjectType.Weapon,
      GameObjectType.Head,
      GameObjectType.Body,
      GameObjectType.Legs,
      GameObjectType.Item,
    ].contains(type);

    if (isCollectable){
      renderBouncingGameObjectShadow(gameObject);
    }

    engine.renderSprite(
      image: image,
      dstX: gameObject.renderX,
      dstY: isCollectable ? getRenderYBouncing(gameObject) : gameObject.renderY,
      srcX: src[Atlas.SrcX],
      srcY: src[Atlas.SrcY],
      anchorY: src[Atlas.SrcAnchorY],
      srcWidth: src[Atlas.SrcWidth],
      srcHeight: src[Atlas.SrcHeight],
      scale: src[Atlas.SrcScale],
      color: switch (gameObject.colorType){
         EmissionType.Ambient => scene.getRenderColorPosition(gameObject),
         EmissionType.None => scene.getRenderColorPosition(gameObject),
         EmissionType.Color => gameObject.emissionColor,
         _ => throw Exception()
      }
    );

    if (gameObject.maxHealth > 0) {
      render.healthBarPosition(
          position: gameObject,
          percentage: gameObject.healthPercentage,
        );
      render.textPosition(gameObject, formatPercentage(gameObject.healthPercentage));
    }
  }

  @override
  void updateFunction() {
    gameObject = scene.gameObjects[index];

    while (!gameObject.active || !screen.contains(gameObject) || !scene.isPerceptiblePosition(gameObject)) {
      index++;
      if (!remaining) return;
      gameObject = scene.gameObjects[index];
    }

    order = gameObject.sortOrder;
  }

  double getRenderYBouncing(Position v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + animation.frameWaterHeight;

  void renderBouncingGameObjectShadow(Position gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;

    render.renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * animation.frameWaterHeight.toDouble())
    );
  }
}
