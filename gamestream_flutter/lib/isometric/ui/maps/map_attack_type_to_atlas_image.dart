
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/isometric/ui/classes/atlas_image.dart';

const mapAttackTypeToAtlasImage = {
  AttackType.Blade          : AtlasImage (srcX: 11859, srcY: 164, width: 25, height: 25),
  AttackType.Fireball       : AtlasImage (srcX: 12117, srcY: 004, width: 22, height: 25),
  AttackType.Handgun        : AtlasImage (srcX: 11824, srcY: 726, width: 12, height: 10),
  AttackType.Shotgun        : AtlasImage (srcX: 11888, srcY: 693, width: 32, height: 11),
  AttackType.Assault_Rifle  : AtlasImage (srcX: 11824, srcY: 691, width: 31, height: 13),
  AttackType.Bow            : AtlasImage (srcX: 11920, srcY: 192, width: 32, height: 32),
  AttackType.Rifle          : AtlasImage (srcX: 11984, srcY: 658, width: 48, height: 14),
  AttackType.Revolver       : AtlasImage (srcX: 11920, srcY: 726, width: 16, height: 10),
};
