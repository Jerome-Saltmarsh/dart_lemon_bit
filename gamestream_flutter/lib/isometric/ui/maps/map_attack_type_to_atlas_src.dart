
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/isometric/ui/classes/atlas_src.dart';

const mapAttackTypeToAtlasSrc = {
  AttackType.Blade          : AtlasSrc (srcX: 11859, srcY: 164, width: 25, height: 25),
  AttackType.Fireball       : AtlasSrc (srcX: 12117, srcY: 004, width: 22, height: 25),
  AttackType.Handgun        : AtlasSrc (srcX: 11824, srcY: 726, width: 12, height: 10),
  AttackType.Shotgun        : AtlasSrc (srcX: 11888, srcY: 693, width: 32, height: 11),
  AttackType.Assault_Rifle  : AtlasSrc (srcX: 11824, srcY: 691, width: 31, height: 13),
  AttackType.Bow            : AtlasSrc (srcX: 11920, srcY: 192, width: 32, height: 32),
  AttackType.Rifle          : AtlasSrc (srcX: 11984, srcY: 658, width: 48, height: 14),
  AttackType.Revolver       : AtlasSrc (srcX: 11920, srcY: 726, width: 16, height: 10),
};
