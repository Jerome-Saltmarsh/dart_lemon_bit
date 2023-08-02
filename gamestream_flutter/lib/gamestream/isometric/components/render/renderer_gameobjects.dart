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
  void onImagesLoaded() {
    mapGameObjectTypeToImage = {
      GameObjectType.Weapon: images.atlas_weapons,
      GameObjectType.Object: images.atlas_gameobjects,
      GameObjectType.Head: images.atlas_head,
      GameObjectType.Body: images.atlas_body,
      GameObjectType.Legs: images.atlas_legs,
      GameObjectType.Item: images.atlas_items,
    };
  }

  Image getImageForGameObjectType(int type) =>
      mapGameObjectTypeToImage [type] ?? (
          throw Exception(
              'isometric.getImageForGameObjectType(type: ${GameObjectType.getName(type)}})'
          )
      );

  late GameObject gameObject;

  @override
  int getTotal() => isometric.scene.gameObjects.length;

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

    isometric.engine.renderSprite(
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
         EmissionType.Ambient => isometric.scene.getRenderColorPosition(gameObject),
         EmissionType.None => isometric.scene.getRenderColorPosition(gameObject),
         EmissionType.Color => gameObject.emissionColor,
         _ => throw Exception()
      }
    );

    if (gameObject.maxHealth > 0) {
      isometric.render.healthBarPosition(
          position: gameObject,
          percentage: gameObject.healthPercentage,
        );
      isometric.render.textPosition(gameObject, formatPercentage(gameObject.healthPercentage));
    }
  }

  @override
  void updateFunction() {
    gameObject = isometric.scene.gameObjects[index];

    while (!gameObject.active || !screen.contains(gameObject) || !scene.isPerceptiblePosition(gameObject)) {
      index++;
      if (!remaining) return;
      gameObject = isometric.scene.gameObjects[index];
    }

    order = gameObject.sortOrder;
  }

  double getRenderYBouncing(Position v3) =>
      ((v3.y + v3.x) * 0.5) - v3.z + isometric.animation.frameWaterHeight;

  void renderBouncingGameObjectShadow(Position gameObject){
    const shadowScale = 1.5;
    const shadowScaleHeight = 0.15;

    render.renderShadow(
        gameObject.x,
        gameObject.y,
        gameObject.z - 15,
        scale: shadowScale + (shadowScaleHeight * isometric.animation.frameWaterHeight.toDouble())
    );
  }
}
