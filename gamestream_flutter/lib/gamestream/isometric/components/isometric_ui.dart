import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricUI {
  final windowOpenMenu = WatchBool(false);

  Widget buildImageGameObject(int objectType) =>
      buildImageFromSrc(
          Images.atlas_gameobjects,
          Atlas.getSrc(GameObjectType.Object, objectType),
      );

  Widget buildImageFromSrc(ui.Image image, List<double> src) => gamestream.engine.buildAtlasImage(
      image: image,
      srcX: src[Atlas.SrcX],
      srcY: src[Atlas.SrcY],
      srcWidth: src[Atlas.SrcWidth],
      srcHeight: src[Atlas.SrcHeight],
    );
}