
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';

import '../../../library.dart';

Widget buildIconAttackType(int type) =>
  buildAtlasImage(
    image: GameImages.atlasIcons,
    srcX: AtlasIconsX.getWeaponType(type),
    srcY: AtlasIconsY.getWeaponType(type),
    srcWidth: AtlasIconSize.getWeaponType(type),
    srcHeight: AtlasIconSize.getWeaponType(type),
    scale: 3.0,
  );

