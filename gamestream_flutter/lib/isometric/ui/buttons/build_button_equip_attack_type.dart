
import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/classes/atlas_src.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_attack_type_to_atlas_src.dart';

import '../../../game_library.dart';



Widget buildIconAttackType(int type) {
  const unknown = AtlasSrc(srcX: 11827, srcY: 133, width: 26, height: 20);
  return buildAtlasSrc(mapAttackTypeToAtlasSrc[type] ?? unknown);
}

Widget buildAtlasSrc(AtlasSrc atlasSrc) =>
  buildAtlasImage(
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
