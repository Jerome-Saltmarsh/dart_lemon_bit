
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/classes/atlas_src.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_attack_type_to_atlas_src.dart';

import '../../../library.dart';

Widget buildIconAttackType(int type) =>
  buildAtlasImage(
    image: GameImages.atlasIcons,
    srcX: AtlasIconsX.getWeaponType(type),
    srcY: AtlasIconsY.getWeaponType(type),
    srcWidth: AtlasIconSize.getWeaponType(type),
    srcHeight: AtlasIconSize.getWeaponType(type),
  );

Widget buildAtlasSrc(AtlasSrc atlasSrc) =>
  buildAtlasImage(
    image: GameImages.atlasIcons,
    srcX: atlasSrc.srcX,
    srcY: atlasSrc.srcY,
    srcWidth: atlasSrc.width,
    srcHeight: atlasSrc.height,
  );

Widget buildButtonWeapon(Weapon weapon, int activeWeaponType) {
  const unknown = AtlasSrc(srcX: 11827, srcY: 133, width: 26, height: 20);
  final weaponTypeAtlasImage = mapAttackTypeToAtlasSrc[weapon.type] ?? unknown;

  return onPressed(
    child: Container(
      width: 100,
      height: 75,
      child: Column(
        children: [
          buildAtlasImageButton(
            image: GameImages.atlasIcons,
            // action: () => sendClientRequestPlayerEquipAttackType1(weapon.uuid),
            action: () => {},
            srcX: weaponTypeAtlasImage.srcX,
            srcY: weaponTypeAtlasImage.srcY,
            srcWidth: weaponTypeAtlasImage.width,
            srcHeight: weaponTypeAtlasImage.height,
          ),
          height4,
          text(
              AttackType.getName(weapon.type),
              bold: weapon.type == activeWeaponType,
              size: 15
          ),
        ],
      ),
    ),
  );
}
