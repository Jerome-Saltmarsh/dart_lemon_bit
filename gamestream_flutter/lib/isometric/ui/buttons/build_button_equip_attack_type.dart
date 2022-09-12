
import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/classes/atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_attack_type_to_atlas_image.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';


Widget buildButtonEquipAttackType(int weaponType, int activeWeaponType) {
  const unknown = AtlasImage(srcX: 11827, srcY: 133, width: 26, height: 20);
  final weaponTypeAtlasImage = mapAttackTypeToAtlasImage[weaponType] ?? unknown;

  return onPressed(
    action: () => sendClientRequestPlayerEquipAttackType1(weaponType),
    onRightClick: () => sendClientRequestPlayerEquipAttackType2(weaponType),
    child: Container(
      width: 100,
      height: 75,
      child: Column(
        children: [
          buildCanvasImageButton(
            action: () => sendClientRequestPlayerEquipAttackType1(weaponType),
            srcX: weaponTypeAtlasImage.srcX,
            srcY: weaponTypeAtlasImage.srcY,
            srcWidth: weaponTypeAtlasImage.width,
            srcHeight: weaponTypeAtlasImage.height,
          ),
          height4,
          text(
              AttackType.getName(weaponType),
              bold: weaponType == activeWeaponType,
              size: 15
          ),
        ],
      ),
    ),
  );
}
