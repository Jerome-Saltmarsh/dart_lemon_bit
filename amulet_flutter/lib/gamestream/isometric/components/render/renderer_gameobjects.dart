import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/gamestream/isometric/atlases/atlas_src_amulet_item.dart';
import 'package:amulet_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:amulet_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:amulet_flutter/isometric/classes/gameobject.dart';
import 'package:amulet_flutter/isometric/classes/position.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_sprite/lib.dart';

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

    if (type == ItemType.Object && subType == GameObjectType.Crate_Wooden){
      renderCrateWooden(scene, gameObject, images, engine);
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Rune){
      render.circleOutlineAtPosition(position: gameObject, radius: 10);
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Wooden_Cart){
      render.renderSpriteAutoIndexed(
          sprite: images.woodenCart,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.75,
          scale: 0.6,
      );
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Firewood){
      render.renderSpriteAutoIndexed(
          sprite: images.firewood,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.75,
          scale: 1,
      );
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Barrel){
      render.renderSpriteAutoIndexed(
          sprite: images.woodenBarrel,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.75,
          scale: 1,
      );
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Pumpkin){
      render.renderSpriteAutoIndexed(
          sprite: images.pumpkin,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.75,
          scale: 0.6,
      );
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Wooden_Chest){
      render.renderSpriteAutoIndexed(
          sprite: images.woodenChest,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.75,
          scale: 0.5,
      );
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Broom){
      render.renderSpriteAutoIndexed(
          sprite: images.broom,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.5,
          scale: 0.35,
      );
      return;
    }

    if (type == ItemType.Object && subType == GameObjectType.Bed){
      render.renderSpriteAutoIndexed(
          sprite: images.bed,
          dstX: gameObject.renderX,
          dstY: gameObject.renderY,
          index: scene.getIndexPosition(gameObject),
          anchorY: 0.75,
          scale: 0.8,
      );
      return;
    }

    // if (
    //   type == ItemType.Object &&
    //   const [
    //     GameObjectType.Crystal_Glowing_False,
    //     GameObjectType.Crystal_Glowing_True,
    //   ].contains(subType)
    // ){
    //   renderCrystal(
    //       dstX: gameObject.renderX,
    //       dstY: gameObject.renderY,
    //       colorEast: colorEast,
    //       glowing: subType == GameObjectType.Crystal_Glowing_True,
    //
    //   );
    // }

    final isAmuletItem = type == ItemType.Amulet_Item;

    if (isAmuletItem){
      renderBouncingGameObjectShadow(gameObject);

      final src = atlasSrcAmuletItem[AmuletItem.values[subType]] ?? const[0, 0];

      engine.renderSprite(
          image: images.atlas_amulet_items,
          dstX: gameObject.renderX,
          dstY: isAmuletItem ? getRenderYBouncing(gameObject) : gameObject.renderY,
          srcX: src[0],
          srcY: src[1],
          srcWidth: 32,
          srcHeight: 32,
          scale: 1.0,
          color: switch (gameObject.emissionType){
            EmissionType.None => scene.getRenderColorPosition(gameObject),
            EmissionType.Ambient => scene.getRenderColorPosition(gameObject),
            EmissionType.Color => gameObject.emissionColor,
            EmissionType.Zero => 0,
            _ => throw Exception()
          }
      );
      return;
    }
    // throw Exception('rendererGameObjects.')
  }

  void renderCrystal({
    required dstX,
    required dstY,
    required bool glowing,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
  }) {
    const scale = 0.35;
    const anchorY = 0.66;
    final sprite = images.crystal;

    engine.setBlendModeModulate();

    final color = (glowing ? colors.purple_3 : colors.aqua_2).value;

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 0, mode: AnimationMode.single),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
    );

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 1, mode: AnimationMode.single),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
    );

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 2, mode: AnimationMode.single),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
      anchorY: anchorY,
    );

    render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 3, mode: AnimationMode.single),
        color: color,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
      anchorY: anchorY,
    );

    if (!glowing){
      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 0, mode: AnimationMode.single),
        color: colorEast,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 1, mode: AnimationMode.single),
        color: colorNorth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 2, mode: AnimationMode.single),
        color: colorSouth,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );

      render.sprite(
        sprite: sprite,
        frame: sprite.getFrame(row: 0, column: 3, mode: AnimationMode.single),
        color: colorWest,
        scale: scale,
        dstX: dstX,
        dstY: dstY,
        anchorY: anchorY,
      );
    }

    engine.setBlendModeDstATop();
    return;
  }

  void renderCrateWooden(
      IsometricScene scene,
      GameObject gameObject,
      IsometricImages images,
      LemonEngine engine,
  ) {
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

    // shadow
    engine.renderSprite(
      image: image,
      srcX: srcX + width * 3,
      srcY: srcY,
      srcWidth: width,
      srcHeight: height,
      dstX: dstX,
      dstY: dstY,
      color: scene.getColor(gameObjectIndex),
      scale: scale,
      anchorY: anchorY,
    );

    // south
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

    // top
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

    // west
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
  }

  @override
  void updateFunction() {
    gameObject = scene.gameObjects[index];

    while (!screen.contains(gameObject) || !scene.isPerceptiblePosition(gameObject)) {
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
