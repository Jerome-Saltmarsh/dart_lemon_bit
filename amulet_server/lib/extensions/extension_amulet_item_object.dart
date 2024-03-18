

import 'package:amulet_common/src.dart';

extension AmuletItemObjectExtension on AmuletItemObject {

  double? get maxHealth => amuletItem.getMaxHealth(level);

  double? get maxMagic => amuletItem.getMaxMagic(level);

  int getSkillLevel(SkillType skillType) =>
      amuletItem.getSkillTypeLevel(
        skillType: skillType,
        level: level,
      );
}