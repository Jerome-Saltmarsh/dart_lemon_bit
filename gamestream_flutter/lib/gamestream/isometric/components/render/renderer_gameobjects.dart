import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';

class SurfaceIndex {
  static const east = 0;
  static const north = 1;
  static const solid = 2;
  static const south = 3;
  static const top = 4;
  static const west = 5;
}

class RendererGameObjects extends RenderGroup {


  late GameObject gameObject;

  @override
  int getTotal() => scene.gameObjects.length;

  @override
  void renderFunction(LemonEngine engine, IsometricImages images) {
    final gameObject = this.gameObject;
    final type = gameObject.type;
    final subType = gameObject.subType;
    final render = this.render;
    final scene = this.scene;

    if (type == ItemType.Object && subType == GameObjectType.Barrel){
      renderBarrel(scene, gameObject, images, render);
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Crate_Wooden){

      final gameObjectIndex = scene.getIndexPosition(gameObject);
      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;

      const scale = goldenRatio_0618;
      const anchorY = 0.8;

      const srcX = 1.0;
      const srcY = 601.0;
      const width = 48.0;
      const height = 73.0;
      final image = images.atlas_gameobjects;

      engine.renderSprite(
        image: image,
        srcX: srcX,
        srcY: srcY,
        srcWidth: width,
        srcHeight: height,
        dstX: dstX,
        dstY: dstY,
        color: scene.colorSouth(gameObjectIndex),
        scale: scale,
        anchorY: anchorY,
      );

      engine.renderSprite(
        image: image,
        srcX: srcX + width,
        srcY: srcY,
        srcWidth: width,
        srcHeight: height,
        dstX: dstX,
        dstY: dstY,
        color: scene.colorAbove(gameObjectIndex),
        scale: scale,
        anchorY: anchorY,
      );

      engine.renderSprite(
        image: image,
        srcX: srcX + width + width,
        srcY: srcY,
        srcWidth: width,
        srcHeight: height,
        dstX: dstX,
        dstY: dstY,
        color: scene.colorWest(gameObjectIndex),
        scale: scale,
        anchorY: anchorY,
      );

      return;
    }


    if (
      type == ItemType.Object &&
      const [
        GameObjectType.Crystal_Glowing_False,
        GameObjectType.Crystal_Glowing_True,
      ].contains(subType)
    ){
      final scene = this.scene;
      final gameObjectIndex = scene.getIndexPosition(gameObject);
      const scale = 0.35;

      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;
      const anchorY = 0.66;

      final sprite = images.crystal;

      engine.setBlendModeModulate();

      final color = (subType == GameObjectType.Crystal_Glowing_False ? colors.purple_3 : colors.aqua_2).value;

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 0),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
      );

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 1),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
      );

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 2),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 3),
          color: color,
          scale: scale,
          dstX: dstX,
          dstY: dstY,
        anchorY: anchorY,
      );

      if (subType == GameObjectType.Crystal_Glowing_False){
        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 0),
          color: scene.colorEast(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );

        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 1),
          color: scene.colorNorth(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );

        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 2),
          color: scene.colorSouth(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );

        render.sprite(
          sprite: sprite,
          frame: sprite.getFrame(row: 0, column: 3),
          color: scene.colorWest(gameObjectIndex),
          scale: scale,
          dstX: dstX,
          dstY: dstY,
          anchorY: anchorY,
        );
      }

      engine.setBlendModeDstATop();
      return;
    }

    if (
      type == ItemType.Object &&
      const [
        GameObjectType.Rock1,
      ].contains(subType)
    ){
      const scale = 0.15;
      final scene = this.scene;
      final gameObjectIndex = scene.getIndexPosition(gameObject);
      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;
      const anchorY = 0.66;
      final sprite = images.rock1;


      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.south),
        color: scene.colorSouth(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.top),
        color: scene.nodeColors[gameObjectIndex],
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.west),
        color: scene.colorWest(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.north),
        color: scene.colorNorth(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.east),
        color: scene.colorEast(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      // engine.setBlendModeDstATop();
      return;
    }

    if (
      type == ItemType.Object &&
      const [
        GameObjectType.Tree1,
      ].contains(subType)
    ){
      const scale = 0.3;
      final scene = this.scene;
      final gameObjectIndex = scene.getIndexPosition(gameObject);
      final dstX = gameObject.renderX;
      final dstY = gameObject.renderY;
      const anchorY = 0.66;
      final sprite = images.tree1;


      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.south),
        color: scene.colorSouth(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.top),
        color: scene.nodeColors[gameObjectIndex],
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.west),
        color: scene.colorWest(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.north),
        color: scene.colorNorth(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: SurfaceIndex.east),
        color: scene.colorEast(gameObjectIndex),
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      // engine.setBlendModeDstATop();
      return;
    }

    final isCollectable = const [
      ItemType.Weapon,
      ItemType.Helm,
      ItemType.Body,
      ItemType.Legs,
      ItemType.Consumable,
      ItemType.Spell,
    ].contains(type);

    if (isCollectable){
      renderBouncingGameObjectShadow(gameObject);
    }

    final image = getImageForGameObjectType(type);
    final src = Atlas.getSrc(type, subType);

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
      color: switch (gameObject.emissionType){
         EmissionType.None => scene.getRenderColorPosition(gameObject),
         EmissionType.Ambient => scene.getRenderColorPosition(gameObject),
         EmissionType.Color => gameObject.emissionColor,
         EmissionType.Zero => 0,
         _ => throw Exception()
      }
    );

    // if (gameObject.maxHealth > 0) {
    //   render.healthBarPosition(
    //       position: gameObject,
    //       percentage: gameObject.healthPercentage,
    //     );
    //   render.textPosition(gameObject, formatPercentage(gameObject.healthPercentage));
    // }
  }

  void renderBarrel(
      IsometricScene scene,
      GameObject gameObject,
      IsometricImages images,
      IsometricRender render,
  ) {
    final gameObjectIndex = scene.getIndexPosition(gameObject);
    final dstX = gameObject.renderX;
    final dstY = gameObject.renderY;
    final sprite = images.barrelWooden;
    const scale = goldenRatio_0381;
    const anchorY = 0.8;

    render.sprite(
      sprite: sprite,
      frame: sprite.getFrame(row: 0, column: 2),
      dstX: dstX,
      dstY: dstY,
      color: scene.getColor(gameObjectIndex),
      scale: scale,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: sprite,
      frame: sprite.getFrame(row: 0, column: 3),
      dstX: dstX,
      dstY: dstY,
      color: scene.colorSouth(gameObjectIndex),
      scale: scale,
      anchorY: anchorY,
    );

    render.sprite(
      sprite: sprite,
      frame: sprite.getFrame(row: 0, column: 5),
      dstX: dstX,
      dstY: dstY,
      color: scene.colorWest(gameObjectIndex),
      scale: scale,
      anchorY: anchorY,
    );

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 0),
        dstX: dstX,
        dstY: dstY,
        color: scene.colorEast(gameObjectIndex),
        scale: scale,
        anchorY: anchorY,
    );

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 1),
        dstX: dstX,
        dstY: dstY,
        color: scene.colorNorth(gameObjectIndex),
        scale: scale,
        anchorY: anchorY,
    );

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 4),
        dstX: dstX,
        dstY: dstY,
        color: scene.colorAbove(gameObjectIndex),
        scale: scale,
        anchorY: anchorY,
    );

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

  Image getImageForGameObjectType(int type) =>
      images.itemTypeAtlases[type] ?? (
          throw Exception(
              'getImageForGameObjectType(type: ${ItemType.getName(type)}})'
          )
      );
}
