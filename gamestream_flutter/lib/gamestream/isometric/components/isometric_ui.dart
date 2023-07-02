import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricUI {
  final windowOpenMenu = WatchBool(false);
  final mouseOverDialog = WatchBool(false);

  Widget buildImageGameObject(int objectType) =>
      buildImageFromSrc(
          GameImages.atlas_gameobjects,
          AtlasSrc.getSrc(GameObjectType.Object, objectType),
      );

  Widget buildImageFromSrc(ui.Image image, List<double> src) => engine.buildAtlasImage(
      image: image,
      srcX: src[AtlasSrc.SrcX],
      srcY: src[AtlasSrc.SrcY],
      srcWidth: src[AtlasSrc.SrcWidth],
      srcHeight: src[AtlasSrc.SrcHeight],
    );
}