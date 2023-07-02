import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricUI {
  final windowOpenMenu = WatchBool(false);
  final mouseOverDialog = WatchBool(false);

  Widget buildImageGameObject(int objectType) => engine.buildAtlasImage(
    image: GameImages.atlas_gameobjects,
    // image: ItemType.isTypeGameObject(gameObjectType)
    //     ? GameImages.atlas_gameobjects
    //     : GameImages.atlas_items,
    srcX: AtlasItems.getSrcX(GameObjectType.Object, objectType),
    srcY: AtlasItems.getSrcY(GameObjectType.Object, objectType),
    srcWidth: AtlasItems.getSrcWidth(GameObjectType.Object, objectType),
    srcHeight: AtlasItems.getSrcHeight(GameObjectType.Object, objectType),
  );
}